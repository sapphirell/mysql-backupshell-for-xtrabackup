#!/bin/bash
today=`date "+%Y-%m-%d-%H:%M:%S"`
#include config file
project_path=$(cd `dirname $0`; pwd)
source ${project_path}/backup.config.sh

print() {
    echo -e "\033[33mINFO:${1}\033[0m"
}

cmd() {
    echo -e "\033[36mCOMMAND:${1} \033[0m"
    $1
}
print "Database backup manager shell start,now time is ${today}";

usage() {
    print "input $1"
    print "Usage:"
    print "  mysql-backup.sh "
    print "   [-a backup:backup mysql recover:recover mysql clear:clear history dir] "
    print "   [-s oss:AliyunOss\`default\` local:Storage to local] "
    print "   [-p Mysql password]"
    print "   [-u Mysql user]"
    print "   [-r Retained number of backup package ]"
    print "   [-b The shell runing dir and backup dir,default /home/root]"
    print "   [-g recover package url]"
    print "   [-m MysqlData Dir url ,default /var/lib/mysql]"
    print "   [-d Databackup fileName prefix]"
    exit -1
}

init() {
    base_dir=$1
    back_up_dir="${base_dir}/mysql-backup"
    output_file="${base_dir}/${file_name}"
    upload_dir="${base_dir}/backup-history"
    upload_config="${base_dir}/upload.conf"
    log_file="${base_dir}/sql-backup.log"
}



file_name="${backup_data_prefix}-${today}.tar"

#init
init ${base_dir}

while getopts 'u:r:a:s:p:m:g:d:b:h:' OPT; do
    case $OPT in
        u) user="$OPTARG";;
        r) retain="$OPTARG";;
        a) action="$OPTARG" ;;
        s) storage="$OPTARG";;
        p) password="$OPTARG";;
        m) mysql_data_dir="$OPTARG";;
        g) selected_package="$OPTARG";;
        d) backup_data_prefix="$OPTARG";;
        b) init $OPTARG;;
        h) usage "help";;
        ?) usage $OPT;;
    esac
done

#checking require params
if [[ ${user} == "" ]]; then
    print "missing param user!"
    usage
fi
if [[ ${password} == ""  ]]; then
    print "missing param password!"
    usage
fi

clearHistoryDir() {
    #count num of retained backup
    print "clear ${upload_dir}"
    find ${upload_dir}/* -type f -mtime +${retain} -exec rm -f {} \;
    print "clear ok!"
}

fileWriter() {
    path=$1
    text=$2
    if [[ !$1 || !$2 ]]; then
        print "function [fileWriter] missing params"
        return
    fi
    if [ ! -f "$path" ]; then
		print "${path} not exists,creating file."
		touch ${path}
		echo ${text} > ${path}
    else
        echo ${text} > ${path}
	fi

}
#
backupQiniu() {
	which "qshell" > /dev/null
	if [ $? -eq 0 ]
	then
	    print "qshell exists,starting upload.."
	else
	    print "ERROR:qshell not exists,please install qshell into this server."
	    exit -1
	fi

	touch ${upload_config}
	echo ${qiniu_config} > ${upload_config}
	rm -rf .qshell
	qshell account ${qiniu_access_key} ${qiniu_secret_key} default
	qshell qupload upload.conf
	print "moving ${output_file} to ${upload_dir}.";
	mv ${output_file} ${upload_dir}
	print "move ok"
	rm -rf ${upload_config}
}

backupAliyun() {
    print "start upload aliyun oss "
    oss_tool="./ossutil64"
    if [ ! -f ${oss_tool} ]; then
        print "ERROR:${oss_tool} not exists,upload failed."
        exit -1
    fi

    if [[ ${aliyun_oss_access_key_id} == "" || ${aliyun_oss_access_key_secret} == "" ]]; then
        oss_config="/root/.ossutilconfig"
        if [ ! -f ${oss_config} ]; then
            print "ERROR:${oss_config} not exists,upload failed."
            exit -1
        fi
        print "use ${oss_config}"
        cmd "${oss_tool} cp ${upload_dir}/${file_name} ${aliyun_oss_upload_path}"
    else
        cmd "${oss_tool} cp ${upload_dir}/${file_name} ${aliyun_oss_upload_path} -i ${aliyun_oss_access_key_id} -k ${aliyun_oss_access_key_secret}"
    fi




}

backupMysql() {
    print "backup start.";
    print "remove ${back_up_dir}"
    rm -rf ${back_up_dir}
    mkdir ${back_up_dir}

    if [ ! -d ${upload_dir} ];then
        mkdir ${upload_dir}
    fi

    cmd "innobackupex --user=${user} --password=${password} --socket=/var/run/mysqld/mysqld.sock "${base_dir}/mysql-backup/" --no-timestamp"

    print "database backup success!";
    cmd "tar -cPf ${output_file} -C ${base_dir} mysql-backup"
    if [[ "$?" -eq "0" ]]; then
        print "tar success!";
    else
        exit -1
    fi
    print "moving ${output_file} to ${upload_dir}"
    mv ${output_file} ${upload_dir}

    #upload to aliyun oss
    if [[ ${storage} == "oss" ]]; then
        backupAliyun
    fi
     if [[ ${storage} == "qiniu" ]]; then
        print "upload qiniu"
    fi
    if [[ ${storage} == "local" ]]; then
        print "Storage local done"
    fi

    rm -rf ${back_up_dir}
    clearHistoryDir
}

recover() {
    if [[ ${selected_package} == "" ]]; then
        print "missing param -g"
        usage
        exit -1
    fi

    print "Mysql data-backup recover start..."
    if [ ! -f ${selected_package} ]; then
        print "ERROR:${selected_package} not exists,recover failed."
        exit -1
    fi
    #move to base dir
    cmd "mv ${selected_package} ./recover.tar"
    cmd "tar -xvf recover.tar"


    print "service mysql stop"
    service mysql stop

    if [[ "$?" -eq "0" ]]; then
        print "mysql stop success";
    else
        exit -1
    fi



    cmd "rm -rf ${mysql_data_dir}-old"
    cmd "mv ${mysql_data_dir} ${mysql_data_dir}-old"

    cmd "innobackupex --copy-back mysql-backup"
    cmd "chown -R mysql:mysql ${mysql_data_dir}"
    cmd "service mysql start"
}


if [[ ${action} == "" ]]; then
    print "please input action, for example \"-a backup\""
fi

if [[ ${action} == "backup" ]]; then
    backupMysql
fi

if [[ ${action} == "recover" ]]; then
    recover
fi

if [[ ${action} == "clear" ]]; then
    clearHistoryDir
fi
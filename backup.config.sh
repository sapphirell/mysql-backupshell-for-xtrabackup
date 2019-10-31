#!/bin/bash
# [BaseConfig]

# action
#       -a backup(default) : selected this options will run backup action.
#       -a recover : danger options, they will
#                    stop mysql service
#                    remove old data dir
#                    unzip backup packpage and opy to mysql data dir later.
#                    restart
#       -a clear  : refer param "-r" to clear old package in backup-history dir
action="backup"

# retain
#       -r [number] : how much days for retained mysql backup data packages. default 3days
retain=3

# storage
#       -s oss  : store to aliyun oss, and require oss config and oss tool.
#       -s qiniu : store to qiniu, don't forget setting qiniu config .
#                  if upload failed , you can manual run `rm -rf .qshell`
#       -s local : if you want store to local disk, you can selected this option
storage="oss"

# user  -u
#       -u [mysql username] username for XtraBackup connect to mysql.
user=""

# password
#       -p [mysql password]
password=""

#mysql_data_dir
#       -m [path]  : path of mysql data dir, you can find `datadir` in "my.cnf"
#                    default /var/lib/mysql
mysql_data_dir="/var/lib/mysql"

#mysql_data_backup
#       -d [string prefix] : when backup suceess, backup data will packed as `{prefiexName}-{date}.tar`
#                            default mysql-backup
backup_data_prefix="mysql-backup"

#selected_package
#       -g [path]  : it's necessary params to recover action, pelease input package path as this option .
selected_package=""

#base_dir
#       -b [path] : shell runing dir.
base_dir="/home/root"

#aliyun
#       if aliyun_oss_access_key_id or aliyun_oss_access_key_secret is empty,
#       shell will find default config in /root/.ossutilconfig
aliyun_oss_access_key_id="LTAI4FosZAR9Ayr3jdquhhHM"
aliyun_oss_access_key_secret="9nHPjDiZ2Yb1z0tUeSRhYiIE5OBYC8"
aliyun_oss_upload_path="oss://vedata/mysql-backup/"


#qiniuyun
#       sample: {\"src_dir\" : \"${base_dir}/backup-history\",\"ignore_dir\" : true,\"bucket\" : \"static\"}
#       src_dir will upload to qiniu
qiniu_config=""
qiniu_access_key=""
qiniu_secret_key=""
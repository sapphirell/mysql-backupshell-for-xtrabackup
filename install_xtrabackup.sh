#!/bin/bash
today=`date "+%Y-%m-%d-%H:%M:%S"`
usage() {
    print "input $1"
    print "Usage:"
    print "  install_xtrabackup.sh "
    print "   [-a install:install Xtrabackup] "
    print "   [-v 24:install percona-xtrabackup-24 (for mysql 5.7)] "
    print "Description:"
    print "     Ruing this shell will install xtrabackup to your server."
    print "     Require ubuntu system."
    exit -1
}

while getopts 'h:a:s:p:u:r:b:r:g:' OPT; do
    case $OPT in
        a) action="$OPTARG" ;;
        v) version="$OPTARG";;
        h) usage "help";;
        ?) usage $OPT;;
    esac
done

wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb

dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb

apt-get update

apt-get install percona-xtrabackup
# mysql-backupshell-for-xtrabackup
+ -Usage:
+   [-a backup:backup mysql recover:recover mysql clear:clear history dir] 
+   [-s oss:AliyunOss(default) local:Storage to local disk] 
+   [-p Mysql password]
+   [-u Mysql user]
+   [-r Retained number of backup package ]
+   [-b The shell runing dir and backup dir,default /home/root]
+   [-g recover package url]
+   [-m MysqlData Dir url ,default /var/lib/mysql]
+   [-d Databackup fileName prefix]

# example
- For example if you want to backup to local disk, you can run:

    ` bash main.sh -abackup -b/var/www -uroot -ppassword -slocal  `
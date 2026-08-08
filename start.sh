#!/usr/bin/env bash
# Start the local portable MySQL instance (port 3306).
MYSQL_HOME="C:/Users/DecVens/Desktop/programs/mysql-8.4.11-winx64"
cd "$MYSQL_HOME" && ./bin/mysqld.exe --defaults-file=./my.ini --console > mysqld.log 2>&1 &
echo "mysqld starting (pid $!), log: $MYSQL_HOME/mysqld.log"

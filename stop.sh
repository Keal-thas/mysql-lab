#!/usr/bin/env bash
# Stop the local portable MySQL instance.
MYSQL_HOME="C:/Users/DecVens/Desktop/programs/mysql-8.4.11-winx64"
"$MYSQL_HOME/bin/mysqladmin.exe" -h 127.0.0.1 -P 3306 -u root shutdown

#!/usr/bin/env bash
# shellcheck disable=SC2181

#
# Load a SQL file into eshop
#
function loadSqlIntoLab
{
    echo ">>> $4 ($3)"
    mysql "-u$1" "-p$2" lab < "$3" > /dev/null
    if [ $? -ne 0 ]; then
        echo "The command failed, you may have issues with your SQL code."
        echo "Verify that all SQL commands can be exeucted in sequence in the file:"
        echo " '$3'"
        exit 1
    fi
}

#
# Recreate and reset the database.
#
echo ">>> Reset eshop to beginning of part 3"
loadSqlIntoLab "root" "Iluulm2!" "setup.sql" "Initiera database and users"
loadSqlIntoLab "user" "pass" "ddl.sql" "Create tables, views, stored procedures and triggers"
loadSqlIntoLab "user" "pass" "insert.sql" "Insert data"

echo ">>> Now we back up database lab."
#mysqldump -u root -p --routines lab > backup.sql

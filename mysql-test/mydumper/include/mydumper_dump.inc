if (!$targetdir)
{
  --let $targetdir=$MYSQLTEST_VARDIR/tmp/mydumper
}
--mkdir $targetdir
if (!$databases)
{
  --let $databases=test
}

SET @old__sql_mode= @@sql_mode;
SET sql_mode= '';
--let $db_args= `select quote(replace('$databases', ' ', ','))`
SET @sql_mode= @old__sql_mode;

--let $mydumper_args= -B $db_args $mydumper_args
--replace_result $MYSQL_TMP_DIR MYSQL_TMP_DIR
--let out= `select "# Dumping $databases $mydumper_args"`
--echo $out
--replace_regex /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}(\.\d+)?/TIMESTAMP/
--exec $MYDUMPER -o $targetdir --verbose 3 -L $targetdir/../mydumper.log --routines $mydumper_args
--let $mydumper_args=

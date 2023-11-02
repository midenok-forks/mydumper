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
--echo # Dumping $databases $mydumper_args
--replace_regex /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}(\.\d+)?/TIMESTAMP/
--exec $MYDUMPER -o $targetdir --no-locks --routines $mydumper_args --checksum-all
--let $mydumper_args=

if (!$targetdir)
{
  --let $targetdir=$MYSQLTEST_VARDIR/tmp/mydumper
}
--mkdir $targetdir
if (!$databases)
{
  --let $databases=test
}
--let $db_args= `select replace('$databases', ' ', ',')`
--let $mydumper_args= -B $db_args $mydumper_args
--echo # Dumping $databases $mydumper_args
--replace_regex /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}(\.\d+)?/TIMESTAMP/
--exec $MYDUMPER -o $targetdir --no-locks --routines $mydumper_args
--let $mydumper_args=

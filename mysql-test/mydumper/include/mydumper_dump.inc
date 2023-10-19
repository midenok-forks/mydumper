if (!$targetdir)
{
  --let $targetdir=$MYSQLTEST_VARDIR/tmp/mydumper
}
--mkdir $targetdir
if (!$databases)
{
  --let $databases=test
}
--exec $MYDUMPER -o $targetdir -B '$databases' --no-locks

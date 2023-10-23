let $i= 1;
--let $db_args= `select replace('$databases', ' ', "','")`
let $db= `select elt($i, '$db_args')`;
while ($db)
{
  if ($db != mysql)
  {
    eval drop database `$db`;
  }
  inc $i;
  let $db= `select elt($i, '$db_args')`;
}
--echo # Restoring...
--exec $MYLOADER -d $targetdir --debug -L $targetdir/myloader.log $myloader_args
if (!$myloader_keep_dir)
{
  --rmdir $targetdir
}
use test;
--let $databases=
--let $myloader_args=
--let $myloader_keep_dir=

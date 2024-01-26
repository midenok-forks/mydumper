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
--exec $MYLOADER -d $targetdir --verbose 3 -L $targetdir/../myloader.log $myloader_args
--let grep_file=$targetdir/../myloader.log
--let grep_regex=\[WARNING\](?! - Failed to load config file)
--replace_regex /^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d // /Thread \d+:\s*//
--replace_result $MYSQLTEST_VARDIR VARDIR
--source include/grep.inc

if (!$myloader_keep_dir)
{
  --rmdir $targetdir
}
use test;
--let $databases=
--let $myloader_args=
--let $myloader_keep_dir=

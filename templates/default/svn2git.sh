#!/bin/bash

export MAILTO=fabien.udriot@typo3.org
export LANG=C

cd /home/svn2git/Svn2Git
/bin/su -c "/usr/bin/flock -n /tmp/svn2git.lockfile /usr/bin/php console.php" svn2git

exit $?

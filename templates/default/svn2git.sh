#!/bin/bash
# This script is handled by Chef
# All changes will be overridden

cd /home/svn2git/Svn2Git
/usr/bin/flock -n /tmp/svn2git.lockfile /usr/bin/php console.php

# Previous environment variable used in schroot environment
#export MAILTO=fabien.udriot@typo3.org
#export LANG=C

# Previous command used in schroot environment
#/bin/su -c "/usr/bin/flock -n /tmp/svn2git.lockfile /usr/bin/php console.php" svn2git

exit $?

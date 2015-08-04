#!/usr/bin/env bash
## osxdotz: Set filetype associations using http://duti.org/
set -eu

## if $basedir is unset
if [ -z ${basedir+x} ]; then
  basedir=$(dirname "$(perl -MCwd=realpath -e "print realpath '$0'")")
  basedir=$(dirname "$basedir")
fi

source "$basedir/lib/dotz_helpers.sh"

echo ""
echo "osxdotz::filetype_associations"

dotz_install_if_missing duti

duti -v "$basedir/resources/filetype_associations"

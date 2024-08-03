#!/usr/bin/awk -f
# motdnewest.awk - print the most recent motd entry
# Copyright (c) 2023 Sriranga Veeraraghavan.  All rights reserved.
#
# v. 0.1.0 - initial version
# v. 0.1.1 - if no arguments are provided, read ./motd

BEGIN {
    entry = 0;

    if (ARGC < 2) {
        ARGV[1] = "./motd" ;
        ARGC = 2 ;
    }
}

{

   # skip all lines till we get the first entry

   if (entry != 1 && $0 !~ /^[01]/) { next; }

   # stop once all the entries are done

   if ($0 ~ /^Older|^Earlier/) { exit ; }

   # this is the first line of an entry

   if ($0 ~ /^[01]/) {

        # if we have already found an entry, this
        # is the second entry, so we are done

        if (entry == 1) { exit ; }

        # found the first entry

        entry = 1;

        # omit the date and print our the rest of the
        # the line

        sub(/^[01][0-9]\/[0-3][0-9]\/[0-9][0-9][0-9][0-9][ \t]+/, "");
        print;
        next;
    }

    # part of the first entry, delete leading whitespace
    # and print out the line

    if (entry == 1) {
        sub(/^[ \t]+/, "");
        print ;
        next ;
    }
}

#!/usr/bin/perl -wT
# motd2html - convert motd to html

use strict;

# global

my $HEADER = "<!DOCTYPE html>\n<html>\n";
$HEADER .= "<head><title>motd</title></head>\n<body>\n<pre>\n";
my $FOOTER = "</pre>\n</body>\n</html>\n";

# main()

print "$HEADER";

while (<>)
{
    s/\&/\&amp\;/g;
    s/\</\&lt\;/g;
    s/\>/\&gt\;/g;
    s/(\s*)(http[s]?\:\/\/\S+)/$1\<a href=\"$2\"\>$2\<\/a\>/;
    print $_;
}

print "$FOOTER";

exit(0);

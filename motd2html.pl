#!/usr/bin/perl -wT
# motd2html - convert motd to html
# Copyright (c) 2023 Sriranga Veeraraghavan.  All rights reserved.
#
# v. 0.1.0 - initial version
# v. 0.1.1 - add RSS autodiscovery support, based on:
#            https://www.rssboard.org/rss-autodiscovery
#            https://www.chromium.org/user-experience/feed-subscriptions/

use strict;

# globals

my $gTitle  = "motd";

my $gHeader = <<"EO_HEADER";
<!DOCTYPE html>
<html>
<head>
<title>$gTitle</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="viewport"
      content="width=device-width, minimum-scale=1, initial-scale=1, shrink-to-fit=no">
<link rel="alternate" type="application/rss+xml" href="rss.xml">
<style>pre { overflow: auto; }</style>
</head>
<body>
<pre>
EO_HEADER

my $gFooter = <<'EO_FOOTER';
</pre>
</body>
</html>
EO_FOOTER

# main()

print "$gHeader";

# escape &, <, >, ", and '
# based on: https://pagedart.com/blog/single-quote-in-html/

while (<>)
{
    s/\&/\&amp\;/g;
    s/[\'\’]/\&\#39\;/g;
    s/\</\&lt\;/g;
    s/\>/\&gt\;/g;
    s/\"/\&\#34\;/g;
    s/(\s*)(http[s]?\:\/\/\S+)/$1\<a href=\"$2\"\>$2\<\/a\>/;
    print $_;
}

print "$gFooter";

exit(0);


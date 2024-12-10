#!/usr/bin/perl -wT
# motd2html - convert motd to html
# Copyright (c) 2023 Sriranga Veeraraghavan.  All rights reserved.
#
# v. 0.1.0 - initial version
# v. 0.1.1 - add RSS autodiscovery support, based on:
#            https://www.rssboard.org/rss-autodiscovery
#            https://www.chromium.org/user-experience/feed-subscriptions/
# v. 0.1.2 - add <a name> tag's for each entry (the name are generated
#            using MD5, which is good enough, because a collision is
#            unlikely and MD5 isn't being used for a crypto purpose
# v. 0.1.3 - remove style from header
# v. 0.1.4 - add dark mode support
# v. 0.1.5 - add title to RSS header
#

use strict;
use Digest::MD5 qw(md5 md5_hex md5_base64);

# globals

my $gTitle = "motd";
#my $gLink  = "https://srirangav.github.io/motd";

my $gHeader = <<"EO_HEADER";
<!DOCTYPE html>
<html>
<head>
<title>$gTitle</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="viewport"
      content="width=device-width, minimum-scale=1.0, initial-scale=1.0, shrink-to-fit=no">
<meta name="color-scheme" content="light dark">
<link rel="alternate" type="application/rss+xml" href="rss.xml" title="$gTitle">
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

my $older = 0;

while (<>)
{
    if (/^Older|^Earlier/)
    {
        $older = 1;
    }

    s/\&/\&amp\;/g;
    s/\</\&lt\;/g;
    s/\>/\&gt\;/g;
    s/\"/\&\#34\;/g;
    s/[\'\’]/\&\#39\;/g;

    if (/^([01][0-9])\/[0-3][0-9]\/([0-9]{4})\s+/ && $older == 0)
    {
        my $digest = md5_hex($_);
        print "<a name=\"$digest\">";
        s/(\/[0-9]{4})(\s+)/$1\<\/a\>$2/;
    }

    s/(\s*)(http[s]?\:\/\/\S+)/$1\<a href=\"$2\"\>$2\<\/a\>/;

    print $_;
}

print "$gFooter";

exit(0);


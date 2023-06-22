#!/usr/bin/perl -wT
# motd2html - convert motd to html
#
# v. 0.1.0 - initial version
# v. 0.1.1 - add RSS autodiscovery support, based on:
#            https://www.rssboard.org/rss-autodiscovery
#            https://www.chromium.org/user-experience/feed-subscriptions/

use strict;

# globals

my $gTitle  = "motd";
my $gRSSURL = "https://github.com/srirangav/motd/commits.atom";

my $gHeader = <<"EO_HEADER";
<!DOCTYPE html>
<html>
<head>
<title>$gTitle</title>
<link rel="alternate" type="application/atom+xml" href="$gRSSURL">
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


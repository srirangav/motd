#!/usr/bin/perl -wT
# motd2feed - create a rss feed for the motd
# Copyright (c) 2023 Sriranga Veeraraghavan.  All rights reserved.
#
# Based on: https://shinobi.bt.ht/
#           https://shinobi.bt.ht/feed.xml
#           https://www.rssboard.org/rss-specification
#
# v. 0.1.0 - initial Perl version

use strict;
use Time::Piece;
use HTML::Entities;

# globals

my $gTitle = "motd";
my $gLink  = "https://srirangav.github.io/motd/";
my $gDesc  = "Message of the day";

# rss header

my $gHeader = <<"EO_HEADER";
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
<channel>
<title>$gTitle</title>
<link>$gLink</link>
<description>$gDesc</description>
EO_HEADER

# rss footer

my $gFooter = <<'EO_FOOTER';
</channel>
</rss>
EO_FOOTER

# opening tags for an rss entry / item

my $gOpenEntry = <<'EO_OPEN_ENTRY';
<description>
<![CDATA[\n<pre>
EO_OPEN_ENTRY

# closing tags for an rss entry / item

my $gCloseEntry = <<'EO_CLOSE_ENTRY';
</pre>]]>
</description>
</item>
EO_CLOSE_ENTRY

# track whether an entry has been found

my $gEntry = 0;

# track whether the closing tag for the entry has been printed

my $gEntryClosed = 0;

# main

# print the rss header

print "$gHeader";

# add the last build date

my $gBuildTime = Time::Piece->new;
print "<lastBuildDate>";
print $gBuildTime->strftime("%a, %d %b %Y %H:%M:%S %Z");
print "</lastBuildDate>\n";

# process STDIN or all files provided as arguments

while (<>)
{

    # skip all lines till we get the first entry

    if ($gEntry == 0 && $_ !~ /^[01]/) { next; }

    # end of entries

    if ($gEntry == 1 && $_ =~ /^(Older|Earlier)/)
    {
        # close out the entry
        print $gCloseEntry;
        $gEntry = 0;
        $gEntryClosed = 1;

        # close this file and move on to the next one
        close ARGV;
        next;
    }

    # check to see if an entry starts on this line

    if ($_ =~ /^[01]/) {

        # if we already have an entry, close it and
        # start a new one

        if ($gEntry == 1)
        {
            print $gCloseEntry;
            $gEntryClosed = 0;
        }

        # have an entry

        $gEntry = 1;

        # start the entry

        if ($_ =~ /^([01][0-9]\/[0-3][0-9]\/[0-9]{4})\s{4}(.*)$/)
        {
            my $rawTime = $1;
            my $rawTitle = $2;

            print "<item>\n";

            my $time = Time::Piece->strptime($rawTime, "%m/%d/%Y");
            print "<pubDate>" . $time->strftime("%a, %d %b %Y") .
                  " 00:00:00 PST</pubDate>\n";

            $rawTitle =~ s/\:$//;
            my $title = encode_entities($rawTitle);

            print "<title>$title</title>\n";
            print "<description>\n";
            print "<![CDATA[\n<pre>$title:\n";
            next;
        }
    }

    # part of an entry, delete leading whitespace,
    # add html escapes, and print out the line

    if ($gEntry == 1)
    {
        s/^\s{14}//;
        s/\&/\&amp\;/g;
        s/[\'\’]/\&\#39\;/g;
        s/\</\&lt\;/g;
        s/\>/\&gt\;/g;
        s/\"/\&\#34\;/g;
        s/(\s*)(http[s]?\:\/\/\S+)/$1\<a href=\"$2\"\>$2\<\/a\>/;
        print $_;
        next;
    }
}

if ($gEntryClosed == 0)
{
    print $gCloseEntry;
}

print "$gFooter";

exit(0);

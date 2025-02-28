#!/usr/bin/perl -wT
# motd2feed - create a rss feed for the motd
# Copyright (c) 2023-2024 Sriranga Veeraraghavan.  All rights reserved.
#
# Based on: https://shinobi.bt.ht/
#           https://shinobi.bt.ht/feed.xml
#           https://www.rssboard.org/rss-specification
#
# v. 0.1.0 - initial Perl version
# v. 0.1.1 - add build date for the feed
# v. 0.1.2 - add links for each entry
# v. 0.1.3 - add guid for each entry; update rss tag in header;
#            add atom:link in header
# v. 0.1.4 - add support for publication time for entries

use strict;
use Time::Piece;
use HTML::Entities;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use POSIX;

# globals

my $gTitle = "motd";
my $gLink  = "https://srirangav.github.io/motd/";
my $gDesc  = "Message of the day";
my $gEntryDate = "";
my @gEntryTime = (0, 0);

# rss header

my $gHeader = <<"EO_HEADER";
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
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

# opening tag for an rss item

my $gOpenItem = "<item>\n";

# closing tag for an rss item

my $gCloseItem = "</item>\n";

# opening tags for the description for an rss item / motd entry

my $gOpenEntry = <<'EO_OPEN_ENTRY';
<description>
<![CDATA[\n<pre>
EO_OPEN_ENTRY

# closing tags for an rss entry / item

my $gCloseEntry = <<'EO_CLOSE_ENTRY';
</pre>]]>
</description>
EO_CLOSE_ENTRY

# track whether an entry has been found

my $gEntry = 0;

# track whether the closing tag for the entry has been printed

my $gEntryClosed = 0;

# current timezone

my $gTZ = "";

# main

# print the basic rss header

print "$gHeader";

# if a URL is the first argument, then add an atom:link to the header
# see: https://validator.w3.org/feed/docs/warning/MissingAtomSelfLink.html

my $gMotdUrl = "";

if ($ARGV[0] =~ /^http/)
{
    $gMotdUrl = shift(@ARGV);

    my $atomLink = <<"EO_ATOM_LINK";
<atom:link href="$gMotdUrl" rel="self" type="application/rss+xml" />
EO_ATOM_LINK

    print "$atomLink";
}

# add the last build date

my $gBuildTime = Time::Piece->new;
print "<lastBuildDate>";
print $gBuildTime->strftime("%a, %d %b %Y %H:%M:%S %Z");
print "</lastBuildDate>\n";

# get the current timezone

tzset();
$gTZ = tzname();
$gTZ = "PST" if ($gTZ eq "");

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
        &printItemPubDate($gEntryDate, @gEntryTime);
        print $gCloseItem;
        $gEntry = 0;
        $gEntryClosed = 1;
        $gEntryDate = "";
        @gEntryTime = (0,0);

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
            &printItemPubDate($gEntryDate, @gEntryTime);
            print $gCloseItem;
            $gEntryClosed = 0;
            $gEntryDate = "";
            @gEntryTime = (0,0);
        }

        # have an entry

        $gEntry = 1;

        # start the entry

        if ($_ =~ /^([01][0-9]\/[0-3][0-9]\/[0-9]{4})\s{4}(.*)$/)
        {
            $gEntryDate  = $1;
            my $rawTitle = $2;

            my ($entryMonth, $entryDay, $entryYear) =
                split(/\//, $gEntryDate);

            print $gOpenItem;

            # add a link and guid for this entry, if a valid year
            # and month were present

            if ($entryYear =~ /^[0-9]{4}$/ &&
                $entryMonth =~ /^[01][0-9]$/)
            {
                my $digest = md5_hex($_);

                # make the link and guid are the same

                my $entryLink =
                    "$gLink$entryYear/$entryMonth/index.html#$digest";

                print "<link>$entryLink</link>\n";

                # add a guid:
                # https://www.rssboard.org/rss-specification#ltguidgtSubelementOfLtitemgt

                print "<guid isPermaLink=\"true\">$entryLink</guid>\n";
            }

            # add this entry's title

            $rawTitle =~ s/\:$//;
            my $title = encode_entities($rawTitle);
            print "<title>$title</title>\n";

            # start the entry, with the first line as a repeat
            # of the title

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

        # if the first character after the leading whitespace
        # is removed is @, assume that the publication time
        # follows on this line

        if (/^\@/)
        {
            s/^\@//;
            @gEntryTime = split(/:/);
            next;
        }

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

# finished processing entries, but the last entry processed
# wasn't closed, so print out the entry's closing tags

if ($gEntryClosed == 0)
{
    print $gCloseEntry;
    printItemPubDate($gEntryDate, @gEntryTime);
    print $gCloseItem;
}

# print the feed's closing tags

print "$gFooter";

exit(0);

# subroutines

sub printItemPubDate
{
    my ($pubDate, $pubHr, $pubMin) = @_;
    if ($pubHr < 0 || $pubHr > 23 || $pubMin < 0 || $pubMin > 59)
    {
        $pubHr  = 0;
        $pubMin = 0;
    }

    # published time for the entry

    my $time = Time::Piece->strptime($pubDate, "%m/%d/%Y");
    print "<pubDate>" . $time->strftime("%a, %d %b %Y");
    printf(" %02d:%02d:00", $pubHr, $pubMin);
    print " $gTZ</pubDate>\n";
}

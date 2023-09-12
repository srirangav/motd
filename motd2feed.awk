#!/usr/bin/awk -f
# motd2feed.awk - generate an rss feed for the motd
#
# Based on: https://shinobi.bt.ht/
#           https://shinobi.bt.ht/feed.xml
#           https://www.rssboard.org/rss-specification
#
# v. 0.1.0 - initial version
# v. 0.1.1 - html escape the title of each entry
#
# TODO: add support for processing older entries

BEGIN {
    entry = 0;

    # variables for feed details

    motdTitle = "motd";
    motdURL = "https://srirangav.github.io/motd/";
    motdDesc = "Message of the day";

    # print rss feed header

    print "<?xml version=\"1.0\"?>";
    print "<rss version=\"2.0\">";
    print "<channel>";
    printf("<title>%s</title>\n", motdTitle);
    printf("<link>%s</link>\n", motdURL);
    printf("<description>%s</description>\n", motdDesc);
}

# htmlEscape - html escapes the provided string

function htmlEscape(str)
{
    if (str == "") { return ""; }

    gsub(/\&/, "\\&amp;", str);
    gsub(/[\'\’]/, "\\&#39;", str);
    gsub(/\</, "\\&lt;", str);
    gsub(/\>/, "\\&gt;", str);
    gsub(/\"/, "\\&#34;", str);
    return str;
}

# printEntryEnd - close the xml for an entry

function printEntryEnd()
{
    print "</pre>]]>";
    print "</description>";
    print "</item>";
}

# Main

{
   # skip all lines till we get the first entry

   if (entry == 0 && $0 !~ /^[01]/) { next; }

   # end of all the entries, stop processing lines

   if (entry == 1 && $0 ~ /^Earlier/) {
       printEntryEnd();
       exit;
   }

   # this is the first line of an entry

   if ($0 ~ /^[01]/) {

        # if we already have an entry, close it and
        # start a new one

        if (entry == 1) { printEntryEnd(); }

        # have an entry

        entry = 1;

        # start the entry

        print "<item>";

        # print the published date of this entry in RFC822 format
        # based on: https://stackoverflow.com/questions/2121896
        # TODO - check for errors from date

        cmd = "date -j -f \"%m/%d/%Y\" " $1 " +\"%a, %d %b %Y\"";
        cmd | getline rssDate;
        close(cmd);
        printf("<pubDate>%s 00:00:00 PST</pubDate>\n", rssDate);

        # remove the date and the trailing colon for the title

        sub(/^[01][0-9]\/[0-3][0-9]\/[0-9]{4}\ {4}/, "");
        sub(/\:$/, "");

        # print the title and repeat it as the first line
        # of the description

        itemTitle = htmlEscape($0);
        printf("<title>%s</title>\n", itemTitle);
        print "<description>"
        printf("<![CDATA[\n<pre>%s:\n", itemTitle);
        next;
    }

    # part of an entry, delete leading whitespace,
    # add html escapes, and print out the line

    if (entry == 1) {
        sub(/^\ {14}/, "");
        print htmlEscape($0);
        next;
    }
}

END {
    # close the last entry

    #print "</pre>]]>"
    #print "</description>"
    #print "</item>"

    # close the feed

    print "</channel>";
    print "</rss>";
}


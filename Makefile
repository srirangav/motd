# Makefile for motd

MOTD      = motd.txt
INDEX     = index.html
FEED      = rss.xml
MOTD2HTML = ./motd2html.pl
MOTD2RSS  = ./motd2feed.awk

all: html feed

.PHONY: html feed

html:
	$(MOTD2HTML) < $(MOTD) > $(INDEX)

feed:
	$(MOTD2RSS) $(MOTD) > $(FEED)

clean:
	rm $(INDEX) $(FEED)


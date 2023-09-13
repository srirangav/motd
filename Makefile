# Makefile for motd

MOTD      = motd.txt
MOTD_PREV = ./2023/08/$(MOTD) \
            ./2023/07/$(MOTD) \
            ./2023/06/$(MOTD) \
            ./2023/05/$(MOTD) \
            ./2023/04/$(MOTD) \
            ./2023/03/$(MOTD) \
            ./2023/02/$(MOTD) \
            ./2023/01/$(MOTD) \
            ./2022/12/$(MOTD) \
            ./2022/11/$(MOTD) \
            ./2022/10/$(MOTD) \
            ./2022/09/$(MOTD) \
            ./2022/08/$(MOTD) \
            ./2022/07/$(MOTD) \
            ./2022/06/$(MOTD) \
            ./2022/05/$(MOTD) \
            ./2022/04/$(MOTD) \
            ./2022/03/$(MOTD)
INDEX     = index.html
FEED      = rss.xml
MOTD2HTML = ./motd2html.pl
MOTD2RSS  = ./motd2feed.pl

all: html feed

.PHONY: html feed

html:
	$(MOTD2HTML) < $(MOTD) > $(INDEX)

feed:
	$(MOTD2RSS) $(MOTD) $(MOTD_PREV) > $(FEED)

clean:
	rm $(INDEX) $(FEED)


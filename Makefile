# Makefile for motd

MOTD      = motd.txt
MOTD_CUR  = ./2023/09/
MOTD_YTD  = ./2023/08/$(MOTD) \
            ./2023/07/$(MOTD) \
            ./2023/06/$(MOTD) \
            ./2023/05/$(MOTD) \
            ./2023/04/$(MOTD) \
            ./2023/03/$(MOTD) \
            ./2023/02/$(MOTD) \
            ./2023/01/$(MOTD)
MOTD_2022 = ./2022/12/$(MOTD) \
            ./2022/11/$(MOTD) \
            ./2022/10/$(MOTD) \
            ./2022/09/$(MOTD) \
            ./2022/08/$(MOTD) \
            ./2022/07/$(MOTD) \
            ./2022/06/$(MOTD) \
            ./2022/05/$(MOTD) \
            ./2022/04/$(MOTD) \
            ./2022/03/$(MOTD)
MOTD_ALL  = $(MOTD) \
            $(MOTD_YTD) \
            $(MOTD_2022)
INDEX     = index.html
FEED      = rss.xml
FEED_CUR  = rss-cur.xml
FEED_YTD  = rss-ytd.xml
MOTD2HTML = ./motd2html.pl
MOTD2RSS  = ./motd2feed.pl

all: html feed

.PHONY: html feed feed_all feed_current feed_ytd

html:
	$(MOTD2HTML) < $(MOTD) > $(INDEX) && \
    /bin/cp $(INDEX) $(MOTD_CUR)

feed: feed_all feed_current feed_ytd

feed_all:
	$(MOTD2RSS) $(MOTD_ALL) > $(FEED)

feed_current:
	$(MOTD2RSS) $(MOTD) > $(FEED_CUR)

feed_ytd:
	$(MOTD2RSS) $(MOTD) $(MOTD_YTD) > $(FEED_YTD)

clean:
	/bin/rm -f $(INDEX) $(FEED) $(FEED_CUR) $(FEED_YTD)


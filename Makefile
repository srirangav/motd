# Makefile for motd

MOTD      = motd.txt
MOTD_CUR_DIR = ./2024/11
MOTD_CUR  = $(MOTD_CUR_DIR)/$(MOTD)
MOTD_YTD  = ./2024/10/$(MOTD) \
            ./2024/09/$(MOTD) ./2024/08/$(MOTD) ./2024/07/$(MOTD) \
            ./2024/06/$(MOTD) ./2024/05/$(MOTD) ./2024/04/$(MOTD) \
            ./2024/03/$(MOTD) ./2024/02/$(MOTD) ./2024/01/$(MOTD)
MOTD_2023 = ./2023/12/$(MOTD) ./2023/11/$(MOTD) ./2023/10/$(MOTD) \
            ./2023/09/$(MOTD) ./2023/08/$(MOTD) ./2023/07/$(MOTD) \
            ./2023/06/$(MOTD) ./2023/05/$(MOTD) ./2023/04/$(MOTD) \
            ./2023/03/$(MOTD) ./2023/02/$(MOTD) ./2023/01/$(MOTD)
MOTD_2022 = ./2022/12/$(MOTD) ./2022/11/$(MOTD) ./2022/10/$(MOTD) \
            ./2022/09/$(MOTD) ./2022/08/$(MOTD) ./2022/07/$(MOTD) \
            ./2022/06/$(MOTD) ./2022/05/$(MOTD) ./2022/04/$(MOTD) \
            ./2022/03/$(MOTD)
MOTD_ALL  = $(MOTD) $(MOTD_YTD) $(MOTD_2023) $(MOTD_2022)
INDEX     = index.html
FEED      = rss.xml
FEED_CUR  = rss-cur.xml
FEED_YTD  = rss-ytd.xml
MOTDURL   = https://srirangav.github.io/motd
MOTD2HTML = ./bin/motd2html.pl
MOTD2RSS  = ./bin/motd2feed.pl

all: html feed

.PHONY: html feed feed_all feed_current feed_ytd

html:
	if [ ! -d $(MOTD_CUR_DIR) ] ; then \
       /bin/mkdir -p $(MOTD_CUR_DIR) ; \
    fi
	$(MOTD2HTML) < $(MOTD) > $(INDEX) && \
    /bin/cp $(INDEX) $(MOTD_CUR_DIR)

feed: feed_all feed_current feed_ytd

feed_all:
	$(MOTD2RSS) "$(MOTDURL)/$(FEED)" $(MOTD_ALL) > $(FEED)

feed_current:
	$(MOTD2RSS) "$(MOTDURL)/$(FEED_CUR)" $(MOTD) > $(FEED_CUR)

feed_ytd:
	$(MOTD2RSS) "$(MOTDURL)/$(FEED_YTD)" $(MOTD) $(MOTD_YTD) > $(FEED_YTD)

clean:
	/bin/rm -f $(INDEX) $(FEED) $(FEED_CUR) $(FEED_YTD)


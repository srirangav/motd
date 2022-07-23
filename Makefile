# Makefile for motd

MOTD = motd.txt
INDEX = index.html
MOTD2HTML = ./motd2html.pl

all:
	$(MOTD2HTML) < $(MOTD) > $(INDEX)

clean:
	rm $(INDEX)

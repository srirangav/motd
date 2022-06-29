# Makefile for motd

MOTD = motd.txt
INDEX = index.html
HEADER = '<!DOCTYPE html><html><head><title>motd</title></head><body><pre>'
FOOTER = '</pre></body></html>'

all: $(INDEX)

$(INDEX): clean
	echo $(HEADER) > $(INDEX) && \
    sed -e 's/\</\&lt\;/g' -e 's/\>/\&gt\;/g' $(MOTD) >> $(INDEX) && \
    echo $(FOOTER) >> $(INDEX)

clean:
	rm $(INDEX)

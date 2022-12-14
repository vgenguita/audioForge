FROM alpine:latest
MAINTAINER Victor G.Enguita <victor@brutalix.org>

COPY --chmod=777 depFiles/ripCD.sh /usr/local/bin/ripCD.sh
COPY --chmod=777 depFiles/audioforge.sh /usr/local/bin/audioforge.sh
COPY --chmod=777 depFiles/convert_audio.py /usr/local/bin/convert_audio.py
RUN apk add --no-cache libcddb cd-discid cdrkit curl py3-pip cdparanoia gnu-libiconv jpegoptim optipng cdrdao ffmpeg
RUN pip install sacad
ENTRYPOINT ["/usr/local/bin/ripCD.sh"]

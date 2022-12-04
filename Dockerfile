#FROM alpine:latest
FROM debian:stable-slim
MAINTAINER Victor G.Enguita <victor@brutalix.org>

RUN mkdir -p /media/rip /media/flac /media/alac
    && mkdir -p /root/.config/whipper
COPY depFiles/sources.list /etc/apt/sources.list
COPY depFiles/requirements.txt /tmp/requirements.txt
COPY depFiles/whipper.conf /root/.config/whipper/whipper.conf
COPY --chmod=777 depFiles/audioforge.sh /usr/local/bin/audioforge.sh
COPY --chmod=777  depFiles/convert_audio.py /usr/local/bin/convert_audio.py
RUN apt update \
    && apt -y upgrade \
    && apt -y install ffmpeg whipper python3-pip \
        firmware-amd-graphics libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && pip install -r /tmp/requirements.txt
CMD [ls -lah /media]
#ENTRYPOINT ["/usr/local/bin/audioforge.sh"]

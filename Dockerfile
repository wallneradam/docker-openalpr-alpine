FROM alpine:edge

RUN \
    # Enable testing repo
    echo "http://nl.alpinelinux.org/alpine/edge/testing" >>/etc/apk/repositories \
    # Install needed libs
 && apk --no-cache add \
    libexecinfo libcurl leptonica log4cplus opencv tesseract-ocr \
    # Install build dependencies
 && apk --no-cache add --virtual .build-deps \
    ca-certificates wget \
    git gcc g++ cmake make curl-dev leptonica-dev log4cplus-dev opencv-dev tesseract-ocr-dev libexecinfo-dev \
    # Prepare build directories
 && cd /srv \
 && git clone https://github.com/openalpr/openalpr.git \
 && cd openalpr/src && mkdir build && cd build \
    # Patch to be able to compile with Musl glibc
 && sed -i.bak 's/backtrace/0;\/\//' ../daemon.cpp \
    # Build
 && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc .. && \
    make -j4 && \
    make install \
    # Clean not needed build directory and dependencies
 && rm -rf /srv/openalpr \
 && apk del .build-deps \
    # Solves libdc1394 error
 && echo -e "#!/bin/sh\nln /dev/null /dev/raw1394\nexec /usr/bin/alpr \$@" >/usr/local/bin/alpr \
 && chmod a+x /usr/local/bin/alpr \
     # Create working directory
&& mkdir /openalpr

WORKDIR /openalpr

ENTRYPOINT ["alpr"]

ARG FROM
FROM $FROM

RUN mkdir -p /usr/share/man/man1 && apt-get update \
#
# Install some imaging tools
#
    && apt-get install -y imagemagick poppler-utils exiftool \
#
# Install unoconv ...
#
    && apt-get install -y unoconv \
#
# Clean-up
#
    && rm -rf /var/lib/apt/lists/*

FROM ubuntu:22.04

RUN apt-get -qq update --fix-missing && \
    apt-get install -y \
    wget \
    perl \
    default-jre \
    unzip

WORKDIR /usr/bin/

RUN wget https://snpeff.blob.core.windows.net/versions/snpEff_latest_core.zip \
  && unzip snpEff_latest_core.zip \
  && cd snpEff \
  && rm snpEff.config

ADD /bin/snpEff.config /usr/bin/snpEff/snpEff.config

ADD /bin/*.pl /usr/bin/

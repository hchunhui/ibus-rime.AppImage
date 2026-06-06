FROM ubuntu:16.04
RUN apt-get update -qq && \
    apt-get install -qq apt-transport-https ca-certificates gnupg software-properties-common wget git bsdmainutils
RUN apt-get install -qq build-essential libboost-dev libibus-1.0-dev libnotify-dev libnotify-bin --no-install-recommends

FROM ubuntu:20.04

MAINTAINER Sarah Allen <sarah@devloaf.io>

LABEL org.label-schema.vendor="Sarah Allen" \
      org.label-schema.name="Ubuntu linux image for compalition of Cardinal C++ projects" \
      org.label-schema.license="MIT" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.version="${VERSION}" \
      org.label-schema.schema-version="1.0.1" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-type="git" \
      org.label-schema.vcs-url="https://github.com/sarahjabado/cardinal-compiler"

ENV TZ=Australia/Perth
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y g++ make cmake libhiredis-dev git
RUN mkdir /app
WORKDIR /app

COPY ./build.sh /etc/build.sh

CMD /etc/build.sh
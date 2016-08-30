FROM alpine:3.4

MAINTAINER Leon de Jager <ldejager@coretanium.net>

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/ldejager/alpine-glibc"

ENV GLIBC_VERSION 2.23-r1

RUN apk --update add --no-cache --virtual=build-dependencies curl \
 && curl -Ls https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -o /tmp/glibc-${GLIBC_VERSION}.apk \
 && curl -Ls https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -o /tmp/glibc-bin-${GLIBC_VERSION}.apk \
 && curl -Ls https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk -o /tmp/glibc-i18n-${GLIBC_VERSION}.apk \
 && apk add --allow-untrusted /tmp/glibc-${GLIBC_VERSION}.apk /tmp/glibc-bin-${GLIBC_VERSION}.apk /tmp/glibc-i18n-${GLIBC_VERSION}.apk \
 && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true \
 && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc/usr/lib \
 && echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh \
 && echo "hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4" >> /etc/nsswitch.conf \
 && apk --update del build-dependencies curl \
 && rm -vfr /tmp/glibc-* \
 && rm -vfr /var/cache/apk/*

ENV LANG=C.UTF-8

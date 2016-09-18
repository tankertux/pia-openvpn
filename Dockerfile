FROM alpine:latest
MAINTAINER swmacdonald

RUN apk -U upgrade && \
    apk add --no-cache openvpn curl && \

    curl -o /openvpn.zip https://www.privateinternetaccess.com/openvpn/openvpn.zip && \
    unzip -d /etc/openvpn/ /openvpn.zip && \

    # cleanup temporary files
    rm -rf /tmp && \
    rm -rf /var/cache/apk/*


COPY openvpn.sh /usr/local/bin/openvpn.sh

ENV REGION="US Seattle"
ENTRYPOINT ["openvpn.sh"]

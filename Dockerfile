FROM alpine:latest
MAINTAINER deltaangle

RUN apk -U upgrade && \
    apk add --no-cache openvpn curl && \

    apk add bash && \

    #AES256
    #curl -o /openvpn-strong.zip https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip && \
    #unzip -d /etc/openvpn/ /openvpn-strong.zip && \
    #AES128
    curl -o /openvpn.zip https://www.privateinternetaccess.com/openvpn/openvpn.zip && \
    unzip -d /etc/openvpn/ /openvpn.zip && \

    # cleanup temporary files
    # rm -rf /tmp && \
    #rm /openvpn-strong.zip && \
    rm /openvpn.zip && \
    rm -rf /var/cache/apk/*


COPY openvpn.sh /usr/local/bin/openvpn.sh
WORKDIR /etc/openvpn

ENV REGION="US Seattle"
ENTRYPOINT ["openvpn.sh"]
#ENTRYPOINT ["/bin/bash"]

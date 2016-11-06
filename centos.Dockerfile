FROM centos:latest
MAINTAINER swmacdonald

RUN yum -y update && yum clean all

RUN yum -y install epel-release

RUN yum -y install openvpn unzip

RUN yum -y update && yum clean all
    

ADD https://www.privateinternetaccess.com/openvpn/openvpn.zip /openvpn.zip
RUN unzip -d /etc/openvpn/ /openvpn.zip

COPY openvpn.sh /usr/local/bin/openvpn.sh
WORKDIR /etc/openvpn

EXPOSE 1194
ENV REGION="US Seattle"
#ENTRYPOINT ["openvpn.sh"]
ENTRYPOINT ["/bin/bash"]


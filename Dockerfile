FROM fedora:20
MAINTAINER Sascha Marcel Schmidt <docker@saschaschmidt.net>

RUN yum -y update && yum clean all
RUN yum -y install openssh-server && yum clean all
RUN mkdir /var/run/sshd

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

RUN yum -y install vim vim-command-t vim-nerdtree passwdqc && yum clean all
ADD start.sh /start.sh

# EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd", "-D"]

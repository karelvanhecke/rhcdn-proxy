FROM registry.access.redhat.com/ubi9@sha256:572155f3053e0267874da447743adec560458824c12d3f8acd429f781656cf33
ENV SMDEV_CONTAINER_OFF=1
RUN mkdir /var/lock/subsys
RUN dnf makecache && \
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf module enable -y nginx:1.22 && \
    dnf install -y nginx inotify-tools && \
    dnf clean all
COPY --chmod=750 rhcdn-proxy /usr/sbin/rhcdn-proxy
COPY --chmod=640 nginx.conf /etc/nginx/nginx.conf
ENTRYPOINT /usr/sbin/rhcdn-proxy

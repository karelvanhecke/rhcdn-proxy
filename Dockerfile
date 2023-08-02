FROM registry.access.redhat.com/ubi9@sha256:c35238b35cbebe4e6c5d0f63a54e54dba41d0b425f2d101ad9f04a5e5ec100b8
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

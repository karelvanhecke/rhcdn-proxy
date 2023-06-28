FROM registry.access.redhat.com/ubi9@sha256:089bd3b82a78ac45c0eed231bb58bfb43bfcd0560d9bba240fc6355502c92976
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

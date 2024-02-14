FROM registry.access.redhat.com/ubi9@sha256:1fafb0905264413501df60d90a92ca32df8a2011cbfb4876ddff5ceb20c8f165
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

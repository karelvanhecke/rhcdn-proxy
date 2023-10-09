FROM registry.access.redhat.com/ubi9@sha256:57273341b34c7f387a6ec97bbd6aee72425d09786052f1512fb652fcd810ab4f
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

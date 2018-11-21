# We have to use CentOS here, as there is a bug in the Debian/Ubuntu versions that
# cause vsftpd to hang when using the pam_script.so module.
#
# See https://web.archive.org/web/20181121091830/https://askubuntu.com/questions/406486/vsftpd-hanging-when-using-pam-exec-or-pam-script/778448/#778448

FROM centos:7

# Install all required dependencies.
RUN yum install -y epel-release && \
    rpm -Uvh http://repo.iotti.biz/CentOS/7/noarch/lux-release-7-1.noarch.rpm && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-LUX && \
    yum install -y vsftpd pam_mysql pam_script wget gettext && \
    wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    chmod +x /usr/local/bin/dumb-init && \
    yum erase -y wget && \
    yum clean all && \
    rm -rf /var/cache/yum

# Ensure required directories exist.
RUN mkdir -p /srv/secure-chroot /srv/virtual /etc/pam-scripts.d && \
    chown -R ftp:ftp /srv/secure-chroot /srv/virtual && \
    chmod a-w /srv/secure-chroot

VOLUME /srv/virtual

COPY fs/ /

ENV DB_HOST="${DB_HOST}" \
    DB_USERNAME="${DB_USERNAME}" \
    DB_PASSWORD="${DB_PASSWORD}" \
    DB_NAME="${DB_NAME}" \
    TABLE_USERS="ftp_users" \
    COL_USERNAME="username" \
    COL_PASSWORD="password" \
    PASSWORD_CRYPT=1 \
    LOG_TRANSACTIONS="no" \
    TABLE_LOGS="ftp_log" \
    EXTERNAL_IP="" \
    UID=65534 \
    GID=65534

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/docker-entrypoint.sh"]

#!/usr/bin/env bash
set -e

# Ensure configuration is provided.
has_error=0

[[ -z $DB_HOST ]] && { echo "\$DB_HOST is required."; has_error=1; }
[[ -z $DB_USERNAME ]] && { echo "\$DB_USERNAME is required."; has_error=1; }
[[ -z $DB_NAME ]] && { echo "\$DB_NAME is required."; has_error=1; }

# Exit if there are errors.
[[ $has_error -eq 1 ]] && exit 1

# Initialize user.
userdel -f ftp &> /dev/null || true
groupdel -f ftp &> /dev/null || true
groupadd -o -g ${GID} ftp
useradd -K MAIL_DIR=/dev/null -u ${UID} -G ftp -o -d /srv/secure-chroot -M -N -s /sbin/nologin ftp 2>/dev/null

# Update the configuration.
envsubst '
$DB_HOST
$DB_USERNAME
$DB_PASSWORD
$DB_NAME
$TABLE_USERS
$TABLE_LOGS
$COL_USERNAME
$COL_PASSWORD
$PASSWORD_CRYPT
$LOG_TRANSACTIONS' < /etc/pam.d/vsftpd-config > /etc/pam.d/.vsftpd-config
mv /etc/pam.d/.vsftpd-config /etc/pam.d/vsftpd-config

# Set the external address.
if [ "$EXTERNAL_IP" != "" ]; then
    sed -i "/pasv_address/c\pasv_address=${EXTERNAL_IP}" /etc/vsftpd/vsftpd.conf
else
    sed -i "/pasv_address/c\#pasv_address=" /etc/vsftpd/vsftpd.conf
fi

# Execute the FTP server.
exec /usr/sbin/vsftpd

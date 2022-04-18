#!/bin/sh
set -x
set -e

# # Update base system
# apt update

# # Upgrade packages
# apt -y upgrade

# Remove existing crontabs, if any.
rm -fr /var/spool/cron
rm -fr /etc/crontabs
rm -fr /etc/periodic

# Remove all but a handful of admin commands.
find /bin /etc /lib /usr /usr/bin /usr/sbin -xdev \( \
  -iname login_duo \
  -iname nologin -o\
  -iname setup-proxy \
  -iname start.sh \
  -iname apk \
  \) -delete

# Remove world-writeable permissions except for /tmp/
find / -xdev -type d -perm +0002 -exec chmod o-w {} + \
  && find / -xdev -type f -perm +0002 -exec chmod o-w {} + \
  && chmod 777 /tmp/ \
  && chown $APP_USER:root /tmp/

# Remove unnecessary user accounts.
#sed -i -r '/^(ubuntu|root|sshd)/!d' /etc/group
#sed -i -r '/^(ubuntu|root|sshd)/!d' /etc/passwd

# Remove interactive login shell for everybody but user.
#sed -i -r '/^ubuntu:/! s#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd


# Disable password login for everybody
#while IFS=: read -r username _; do passwd -l "$username"; done < /etc/passwd || true

#sysdirs="
#   /bin
#   /etc
#   /lib
#   /usr
#   /usr/bin
# "

# Remove apk configs.
#find $sysdirs -xdev -regex '.*apk.*' -exec rm -fr {} +

# Remove crufty...
#   /etc/shadow-
#   /etc/passwd-
#   /etc/group-
#find $sysdirs -xdev -type f -regex '.*-$' -exec rm -f {} +

# Ensure system dirs are owned by root and not writable by anybody else.
find $sysdirs -xdev -type d \
  -exec chown root:root {} \; \
  -exec chmod 0755 {} \;


# Remove init scripts since we do not use them.
rm -fr /etc/init.d
rm -fr /lib/rc
rm -fr /etc/conf.d
rm -fr /etc/inittab
rm -fr /etc/runlevels
rm -fr /etc/rc.conf

# Remove kernel tunables since we do not need them.
rm -fr /etc/sysctl*
rm -fr /etc/modprobe.d
rm -fr /etc/modules
rm -fr /etc/mdev.conf
rm -fr /etc/acpi

# Remove root homedir since we do not need it.
#rm -fr /root

# Remove fstab since we do not need it.
rm -f /etc/fstab

# Remove broken symlinks (because we removed the targets above).
find $sysdirs -xdev -type l -exec test ! -e {} \; -delete

# Improve strength of diffie-hellman-group-exchange-sha256 (Custom DH with SHA2).
# moduli=/etc/ssh/moduli
# if [[ -f ${moduli} ]]; then
#   cp ${moduli} ${moduli}.orig
#   awk '$5 >= 2000' ${moduli}.orig > ${moduli}
#   rm -f ${moduli}.orig
# fi

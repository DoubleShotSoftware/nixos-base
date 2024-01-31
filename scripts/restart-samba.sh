#1/usr/bin/env bash
systemctl restart samba-nmbd
systemctl restart samba-smbd
systemctl restart samba-winbindd
systemctl restart samba-wsdd

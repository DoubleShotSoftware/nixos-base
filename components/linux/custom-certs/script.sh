#!/usr/bin/env bash
set -e
temp_file=$(mktemp)
local_ssl_bundle=$HOME/.config/ssl/ssl_bundle.crt
local_ssl_dir=$HOME/.config/ssl
custom_cert_root="/persist/etc/certs"
if [ ! -d $local_ssl_dir ]; then
    mkdir -p $local_ssl_dir
fi
if [ ! -f $local_ssl_bundle ]; then
    touch $local_ssl_bundle
fi

cat /etc/ssl/certs/ca-bundle.crt >> $temp_file
cat /etc/ssl/certs/ca-certificates.crt >> $temp_file
for cert in $(ls $custom_cert_root); do
  echo $(cat $custom_cert_root/$cert) >> $temp_file; 
done
if [[ !("$(md5sum $temp_file|awk '{print $1}')" == "$(md5sum $local_ssl_bundle|awk '{print $1}')") ]]
then
  echo "Files do not match updating bundles."
  cat $temp_file > $local_ssl_bundle
fi
rm $temp_file
export NIX_SSL_CERT_FILE=$local_ssl_bundle
export SSL_CERT_FILE=$local_ssl_bundle

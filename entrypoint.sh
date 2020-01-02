#!/bin/sh
set -e

exec_certbot(){
  if [ -z "${EMAIL_ADDRESS}" ]; then
    echo "Please set EMAIL_ADDRESS env variable to register ACME account"
    exit 1
  fi
  if [ -z "${DOMAIN_NAME}" ]; then
    echo "Please set DOMAIN_NAME for which to obtain certificates"
    exit 1
  fi
  # build array of domains to get certificates for
  set -- "-d" "${DOMAIN_NAME}"
  if [ -n "${SUBDOMAINS}" ]; then
    IFS=','
    for subdomain in ${SUBDOMAINS}; do
      set -- "$@" "-d" "${subdomain}.${DOMAIN_NAME}"
    done
  fi

  certbot certonly \
    --agree-tos \
    --non-interactive \
    -m "${EMAIL_ADDRESS}" \
    --dns-cloudflare \
    --dns-cloudflare-credentials "${CLOUDFLARE_CONFIG_LOCATION:-/config/cloudflare.ini}" \
    --dns-cloudflare-propagation-seconds "${CLOUDFLARE_PROPAGATE_SECONDS:-60}" \
    "$@"

  # Setup a cron schedule
  echo "SHELL=/bin/sh
  0 0 * * 0 /run-certbot.sh >> /var/log/cron.log 2>&1
  " > scheduler.txt

  crontab scheduler.txt
  crond -f
}

if [ -n "$1" ]; then
  # If the entrypoint receives any command - execute it directly.
  # Useful if someone wants to start a shell in the container
  exec "$@"
else
  # Default
  exec_certbot
fi

# Description
Simple Certbot image for `armhf` architecture. Designed to be used with Cloudflare DNS only for now.

Tries to issue certificates for your domains and starts a weekly cron job to renew the certificates. 
# Usage

The container requires `EMAIL_ADDRESS` and `DOMAIN_NAME` environment variables, as well as you Cloudflare login
information.

## Environment variables: 
- `EMAIL_ADDRESS` - email address for your ACME account
- `DOMAIN_NAME` - domain name to retrieve certificates for, eg `example.com`
- `SUBDOMAINS` - (optional) comma-separated list of subdomains to get the certificate for. Can be a wildcard.
Eg `api.example.com` or `*.example.com`
- `CLOUDFLARE_CONFIG_LOCATION` - (optional) Location of the cloudflare login information.
Default value is `/config/cloudflare.ini`
- `CLOUDFLARE_PROPAGATE_SECONDS` - (optional) Time to wait (in seconds) for DS challenge to propagate before 
attempting to resolve it. Default value is 60s.

## Cloudflare login information
This image uses [certbot-dns-cloudflare](https://certbot-dns-cloudflare.readthedocs.io/en/stable/) for Cloudflare
authentication.

You can obtain credentials from [your Cloudflare account page](https://www.cloudflare.com/a/account/my-account).
The plugin does not currently support Cloudflare’s “API Tokens”, so please ensure you use the “Global API Key” for authentication.

Example credentials file:
```
# Cloudflare API credentials used by Certbot
dns_cloudflare_email = cloudflare@example.com
dns_cloudflare_api_key = 0123456789abcdef0123456789abcdef01234567
```

## Example docker-compose.yml
```
version: "3"
services:
  certbot:
    image: msdinit/certbot
    container_name: certbot-renewer
    volumes:
      - ./cloudflare:/config
      - certbot-certificates:/etc/letsencrypt
    environment:
      EMAIL_ADDRESS: webmaster@example.com
      DOMAIN_NAME: example.com
      SUBDOMAINS: www,api
volumes:
  certbot-certificates:
```

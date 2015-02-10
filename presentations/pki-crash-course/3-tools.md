## Tools and Libraries

- OpenSSL
- NSS
- Java
- Others
- Compatibility Issues

--
## OpenSSL - Signing Certificates

- Ad hoc: `openssl x509 -req`
- Managed: `openssl ca`

--
## OpenSSL - Signing Certificates

Extensions don't get automatically carried over when signing with the `ca`
subcommand.

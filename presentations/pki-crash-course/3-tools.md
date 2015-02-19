# Tools and Libraries

- OpenSSL
- NSS
- Java
- Others
- Compatibility Issues

--
# OpenSSL

- Very common and extremely versatile
- Has a plethora of subcommands
  - The `man` pages for a subcommand are accessed directly

    ```none
    # man x509
    # man genrsa
    ```
- Contrary to convention, all long options use a single hyphen

  ```none
  # openssl x509 -in foo.pem -text
  ```
- Generally works with PEM files

--
# OpenSSL - General Concepts

- Governed by a conf file.  Default is `/etc/pki/tls/openssl.cnf`
- Most commands use `-in` and `-out` or variants
  - `-pubout`, `-keyout`, etc.
- `-noout` is useful to keep OpenSSL from spitting out the raw PEM all the
  time
- Passwords can be read in using `-passin` or `-passout` and a special syntax
  - `-passout pass:hello` Encrypt with password "hello"
  - `-passin file:/tmp/secret` Decrypt with contents of file `/tmp/secret`
  - `-passin stdin` Decrypt with whatever gets piped in through `stdin`
- If you are using `file` for passwords, make sure your file is *exactly* right.  No
  trailing newlines (use `echo -n`)!
    - OpenSSL will tolerate a newline, others may not
      ```none
      # echo  "hello" > secret.txt ; openssl rsa -in foo.key -passin file:secret.txt -noout -check
      RSA key ok
      # echo -n "hello" > secret.txt ; openssl rsa -in foo.key -passin file:secret.txt -noout -check
      RSA key ok
      ```
--
# OpenSSL - Generating Keys

```none
# openssl genrsa -out foo.key 2048
```

- Last number is the number of bits in the key
- Key can be encrypted immediately with `-idea`, `-aes192`, `-aes256`
  - AES options are not in the man pages as of Fedora 20
  - There is a `-des` option to encrypt with DES.  Do **not** use it.  DES is old
- Results in PKCS1 file containing the **private key**
  - Public key can be derived if you need it

    ```none
    # openssl rsa -in foo.key -out foo.pub -pubout
    ```

--
# OpenSSL - Creating a CSR (Simple)

```none
# openssl req -new -key foo.key -out foo.csr
```

- Will ask you lots of questions to build the certificate Subject
  - Most important is the Common Name (CN).  If you are generating a server
    certificate, this value should match the server's hostname (unless you
    are using SubjectAltNames).
  - Common Names can contain wildcards: "*.fedoraproject.org"
- Will ask for a "challenge password".  Don't bother
- Tedious to answer these questions. Two options:
  - Default answers can be specified in an OpenSSL conf file and the file
    passed in with `-config`
  - Use `-subj` and pass in components delimited with a slash

    ```none
    -subj /C=US/O=Acme Inc./CN=localhost
    ```

Note:
The "challenge password" was meant to be an additional means of
authenticating to CAs if a certificate needed to be revoked.  Most CAs do not
use it and it does not add any additional security to the CSR.

--
# OpenSSL - Creating a CSR (Advanced)

```none

# cat /etc/pki/tls/openssl.cnf - <<CONF > san.cnf
[ my_extensions ]
subjectAltName=DNS:www.example.com,DNS:www.example.org
CONF
# openssl req -new -key foo.key -out foo.csr -extensions my_extensions -config san.cnf

```

--
# OpenSSL - Creating a CA/Self-Signed Certificate

```none
# openssl req -new -x509 -key my_ca.key -out my_ca.crt -days 3650
```

- Useful for smoke tests, rapid development
- Is marked **by default** as a CA
- To be explicit about creating a CA add `-extensions v3_ca`
- If you intend to use the cert as a CA:
  - Put something in the CN like "My Test CA" to indicate the purpose
  - Use a long validity period (5 years at least)

--
# OpenSSL - Creating a Self-Signed Cert Fast

```none
#  openssl req -new -x509 -newkey rsa:2048 -nodes -days 365 -subj '/CN=localhost' -out x.crt -keyout x.key
```

- Creates the key inline

--
# OpenSSL - Signing Certificates (Ad Hoc)

```none
# openssl x509 -req -days 365 -in foo.csr -out foo.crt -CA my_ca.crt -CAkey my_ca.key -CAcreateserial
```

- Great for development.  Not great for managing large numbers of certificates
- A serial number must be provided (decimal or hex with `0x`)
  - By default, expects a file named `<crt file basename>.srl`
    containing a hex number.  E.g. `my_ca.srl`
  - `-CAserial my_serial_list.srl` lets you use an arbitrary file
  - `-CAcreateserial` auto-generates a serial number for the cert and
    creates the srl file for later use
  - `-set_serial 0xDEADBEEF` works if you want to specify the serial on the
    CLI
- After a serial is used, OpenSSL increments the value in the `.srl` file
- If no serial is provided, OpenSSL emits a cryptic riddle

  ```none
  my_ca.srl: No such file or directory
  140437440989056:error:02001002:system library:fopen:No such file or directory:bss_file.c:398:fopen('my_ca.srl','r')
  140437440989056:error:20074002:BIO routines:FILE_CTRL:system lib:bss_file.c:400:
  ```
- **No extensions** on the CSR are copied over by default

--
# OpenSSL - Signing Certificates (Managed)

- For managing large numbers of certificates use `openssl ca`
- Lightweight tool to track revocations, serials, define signing policies
- Create a custom OpenSSL conf file and directory structure
- **No extensions** on the CSR are copied over by default
- To copy extensions:
  - In the CA section of the conf file set `copy_extensions = copy`
  - Set `basicConstraints = CA:FALSE`
  - These two settings will copy over requested extensions except for the CA
    extension.
  - Prevents the case where an unwitting operator creates and issues a sub-CA
    from a malicious CSR


--
# Compatibility Issues - Java

- OpenSSL outputs PKCS1 formated RSA keys.  Java only wants to read PKCS8.

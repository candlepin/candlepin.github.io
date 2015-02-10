## PKI Concepts

- ASN.1
- Formats
- X509 Certificates
- Certificate Authorities
- Trust Stores
- Certificate Signing Requests
- Certificate Extensions
- Certificate Revocation Lists
- Key Stores

--
# ASN.1

- Similar in concept to Backus-Naur Form
- A way to describe data and data-types
- Start simple and move up
- The building blocks of PKI

Note:
Pretty much everything is in ASN.1: Keys, certificates, certificate signing
requests, etc.

--
# ASN.1 - Trivial Example

```
Widget ::= SEQUENCE {
    model IA5String,
    serialNumber INTEGER,
    inspections InspectionInfo
}

InspectionInfo ::= SEQUENCE {
    inspectorName IA5String,
    inspectionDates SEQUENCE OF DATE
}
```

Note: Let's say we have a Widget.  Every Widget has a model name, a serial
number, and some inspection information with the name of the inspector and
the dates of the inspections.  Here's how we represent that in ASN.1.

Now let's go over that.  A SEQUENCE is one of the four ASN.1 structured types
and it's just an ordered collection of items.  Inside that sequence we have
an IA5String (International Alphabet 5 — basically ASCII), an INTEGER, and
then an item of InspectionInfo type.  We continue down and see InspectionInfo
is also a SEQUENCE containing the inspector's name and the inspection dates.
The inspection dates are a SEQUENCE OF, another structured type that holds
zero or more occurrences of a given type. In this case, the given type is
DATE.

--
# ASN.1 - Real Example

PKCS1 - Format for storing RSA keys

```none
RSAPublicKey ::= SEQUENCE {
    modulus           INTEGER,  -- n
    publicExponent    INTEGER   -- e
}

RSAPrivateKey ::= SEQUENCE {
    version           Version,
    modulus           INTEGER,  -- n
    publicExponent    INTEGER,  -- e
    privateExponent   INTEGER,  -- d
    prime1            INTEGER,  -- p
    prime2            INTEGER,  -- q
    exponent1         INTEGER,  -- d mod (p-1)
    exponent2         INTEGER,  -- d mod (q-1)
    coefficient       INTEGER,  -- (inverse of q) mod p
    otherPrimeInfos   OtherPrimeInfos OPTIONAL
}

Version ::= INTEGER { two-prime(0), multi(1) }
    (CONSTRAINED BY {
        -- version must be multi if otherPrimeInfos present --
    })

OtherPrimeInfos ::= SEQUENCE SIZE(1..MAX) OF OtherPrimeInfo

OtherPrimeInfo ::= SEQUENCE {
    prime             INTEGER,  -- ri
    exponent          INTEGER,  -- di
    coefficient       INTEGER   -- ti
}
```

From [RFC 3447](https://www.ietf.org/rfc/rfc3447.txt)

--
# ASN.1 - According to OpenSSL's `asn1parse`

```none
% openssl genrsa 2048 2> /dev/null | openssl asn1parse
    0:d=0  hl=4 l=1189 cons: SEQUENCE
    4:d=1  hl=2 l=   1 prim: INTEGER           :00
    7:d=1  hl=4 l= 257 prim: INTEGER           :DF313FF1...
  268:d=1  hl=2 l=   3 prim: INTEGER           :010001
  273:d=1  hl=4 l= 257 prim: INTEGER           :A5CEE1B1...
  534:d=1  hl=3 l= 129 prim: INTEGER           :FEF2403F...
  666:d=1  hl=3 l= 129 prim: INTEGER           :E01D66B4...
  798:d=1  hl=3 l= 129 prim: INTEGER           :EFCF535C...
  930:d=1  hl=3 l= 129 prim: INTEGER           :A00CFF33...
 1062:d=1  hl=3 l= 128 prim: INTEGER           :38264063...
```

And we can see that corresponds to the schema described in the previous
slide for a private key.

--
# Formats

- DER (Distinguished Encoding Rules)
  - Binary encoding
  - No ambiguity; Only one way to represent any given value
- PEM
  - Base64 encoded DER with header and footer
  - Most common format
  - Example:
    ```none
    -----BEGIN RSA PRIVATE KEY-----
    MIICXQIBAAKBgQDCb3IURscbZ75C/0b...
    eTi8ffmPntD2YDWYJknOY1vf0NpeKH8...
    [...]
    -----END RSA PRIVATE KEY-----
    ```

Note:
You've got all the components you need to define something in ASN.1.  Now
what?  We need to encode the data.  The standard method uses Distinguished
Encoding Rules which encode the data in an unambiguous manner.  DER is a
binary format which isn't very useful if you need to email the certificate
or print it to your terminal.  Taking the DER and base64 encoding it solves
the problem.  Now we have a blob of ASCII text that we add a descriptive
header and footer onto.  The result is a PEM file.  PEM stands for
Privacy-enhanced Electronic Mail which is due to the format's history
with PGP.  It's a fun bit of trivia, but not relevant in the modern era.

--
# X509 Certificates

- "Certificates" or "certs" for short
- An ASN.1 object with a public key and metadata
- Signed by a trusted party or self-signed which means "trust me"
- Used for identification since the private key is only known by the cert
  owner

--
# X509 - Anatomy

- Version: "3" is the latest
- Serial Number: Of limited interest.  Use a SHA1 fingerprint for
  identification
- Issuer: Entity that vouches for this certificate
- Validity: How long is this certificate good?
- Subject: Who the certificate owner claims to be
- Extensions: Many and varied.  We'll get back to these
- Certificate Signature: An unforgeable signature from the Issuer to prove
  the certificate hasn't been tampered with
- Subject Public Key Info: The components of the public key

Note:
We'll talk about the purpose of the Validity when we get to certificate
revocation lists.

--
#X509 - Example

```none
Certificate:
  Data:
    Version: 3 (0x2)
    Serial Number: 31647 (0x7b9f)
  Signature Algorithm: sha256WithRSAEncryption
  Issuer: C=US, ST=North Carolina, L=Raleigh, O=Fedora Project, OU=Fedora Project CA,
          CN=Fedora Project CA/emailAddress=admin@fedoraproject.org
  Validity
    Not Before: Apr 15 18:26:14 2014 GMT
    Not After : Apr 12 18:26:14 2024 GMT
  Subject: C=US, ST=North Carolina, O=Fedora Project, OU=Fedora Builders,
           CN=koji.fedoraproject.org/emailAddress=buildsys@fedoraproject.org
  Subject Public Key Info:
    Public Key Algorithm: rsaEncryption
      Public-Key: (4096 bit)
      Modulus:
        00:b5:ea:c6:39:97:d4:6b:b8:c3:87:26:c6:d0:c3:
      Exponent: 65537 (0x10001)
        X509v3 extensions:
          X509v3 Basic Constraints:
            CA:FALSE
          Netscape Comment:
            OpenSSL Generated Certificate
          X509v3 Subject Key Identifier:
            3C:[...]
          X509v3 Authority Key Identifier:
            keyid:C0:[...]
            DirName:/C=US/ST=North Carolina/L=Raleigh/O=Fedora Project/
              OU=Fedora Project CA/CN=Fedora Project CA/emailAddress=admin@fedoraproject.org
            serial:C5:DC:BD:63:32:07:D6:5E

    Signature Algorithm: sha256WithRSAEncryption
       95:62:87:c9:c6:4d[...]
```

--
# Certificate Authorities

- "CAs" for short
- Trusted third-parties that put their seal of approval on a certificate
- The "seal of approval" is based on the CA's private key
- Commercial CAs will externally verify you before signing
- CAs sign certificates with other, special certificates
  ```none
  X509v3 extensions:
    X509v3 Basic Constraints:
      CA:TRUE
  ```

Note:
If you are getting a certificate for a domain name for example, the CA will
require you to respond to an email sent to the Registrant Email stored in
DNS.

--
# Trust
- Trust is in a chain
  - Sometimes there are two links: subject and issuer.
  - Many CAs have sub-CAs, so you could have: subject, sub-sub-CA, sub-CA,
    root CA
- Clients walk the chain until they find a CA they trust
- Trust has to begin somewhere, so root CA certs are self-signed

--
# Truststores

- A CA is useless if no one trusts it, so the certificates for commercial CAs
  need to be disseminated somehow
- Systems (e.g. Fedora, Firefox, Chrome) contain a truststore with a
  database of CA certificates
- When clients try to make a connection using certificates (e.g. SSL/TLS),
  if the CA the server returns is unknown, the client aborts the connection
  ```none
  % curl https://koji.fedoraproject.org
  curl: (60) Peer's certificate issuer has been marked as not trusted by the user.
  More details here: http://curl.haxx.se/docs/sslcerts.html

  curl performs SSL certificate verification by default, using a "bundle"
   of Certificate Authority (CA) public keys (CA certs). If the default
   bundle file isn't adequate, you can specify an alternate file
   using the --cacert option.
  If this HTTPS server uses a certificate signed by a CA represented in
   the bundle, the certificate verification probably failed due to a
   problem with the certificate (it might be expired, or the name might
   not match the domain name in the URL).
  If you'd like to turn off curl's verification of the certificate, use
   the -k (or --insecure) option.
  ```

--
# Certificate Authorities - Roll Your Own

- No reason you can't create your own CA.  Perfectly reasonable for large
  organizations (and much cheaper)
- The trick is to make sure everyone in your organization has and trusts the
  CA certificate
  ```none
  % curl --cacert ~/.fedora-server-ca.cert https://koji.fedoraproject.org
  <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
  <html><head>
  <title>302 Found</title>
  </head><body>
  <h1>Found</h1>
  <p>The document has moved <a href="https://koji.fedoraproject.org/koji">here</a>.</p>
  </body></html>
  ```

Note:
The certificate for koji.fedoraproject.org that we looked at earlier is not
signed by a commercial CA and most systems won't have the CA the cert used
in their truststores.  If we connect and tell curl explicitly that we trust
the Fedora Project CA, everything works.

--
# Truststores - The Devil is in the Details
- There are a half dozen different ways of trusting a CA
  - Path to the PEM for the CA cert
  - Various types of binary stores
    - PKCS12
    - JKS
    - NSS DB
  - Add to the system truststore
  - Place CA PEM in special directory (Docker)

---
title: The Certificate Revocation List
---
{% include toc.md %}
# How X509CRLStreamWriter Works

## Introduction
This document describes in detail how X509CRLStreamWriter modifies an existing
X509 CRL in a streaming fashion.  Before proceeding, it is useful to have an
understanding of [Abstract Syntax Notation
1](http://luca.ntop.org/Teaching/Appunti/asn1.html), [DER versus other forms of
encoding for ASN1](https://en.wikipedia.org/wiki/X.690), and the [CRL
specification in RFC 5280](https://tools.ietf.org/html/rfc5280#section-5).  ASN1
is a method for encoding data.  Data exists in tag-length-value (TLV) units.
The tag defines the type of data (e.g. an integer, a string), the length is the
length of the data in bytes, and the value is the binary data.

For example the string "hello" would be encoded `160568656C6C6F` in hexadecimal
where `16` denotes the data is a IA5String (ASCII), `05` is the length of the
data, and the subsequent bytes are the word "hello" encoded in ASCII.  ASN1 data
can be encoded in different formats, but the only one we are interested in is
Distinguished Encoding Rules (DER) that define a single unambiguous way to
encode each piece of ASN1.  For the rest of this document, when I refer to ASN1
it is with the implicit understanding that it will be encoded using DER.

The eighth and seventh bits (where the first bit is the rightmost bit) of the
tag byte describe the class of the tag.  For our purposes, the only class we
care about is the "universal" class which is the class of types built in to
ASN1.  The sixth bit describes whether the type is primitive or constructed.
Primitive types are irreducible while constructed types can hold additional ASN1
items within themselves.  One of the most important constructed types is the
*sequence*.  The final five bits (hereafter referred to as the *tag number*) are
a number that maps to a specific data type.

To illustrate how a tag and tag number are related, let's consider the sequence
type.  According to the X690 specification, the tag number for a sequence is 16.
In binary that translates to `10000`.  A sequence is in the universal class
which according to the specification makes the class bits (bits seven and eight)
`00`.  Finally, a sequence is a constructed type, making the sixth bit a `1`.
Thus, the final tag is `00110000` in binary or `30` in hexadecimal.

Starting with with the universal types, we can build more and more complex TLVs
to represent our data.  For example, below is the schema specification for an
X509 CRL as defined by RFC 5280.

```
CertificateList ::= SEQUENCE  {
     tbsCertList          TBSCertList,
     signatureAlgorithm   AlgorithmIdentifier,
     signatureValue       BIT STRING
}

TBSCertList ::= SEQUENCE  {
     version                 Version OPTIONAL,
                              -- if present, MUST be v2
     signature               AlgorithmIdentifier,
     issuer                  Name,
     thisUpdate              Time,
     nextUpdate              Time OPTIONAL,
     revokedCertificates     SEQUENCE OF SEQUENCE  {
          userCertificate         CertificateSerialNumber,
          revocationDate          Time,
          crlEntryExtensions      Extensions OPTIONAL
                                   -- if present, version MUST be v2
     }  OPTIONAL,
     crlExtensions           [0]  EXPLICIT Extensions OPTIONAL
                                   -- if present, version MUST be v2
}

AlgorithmIdentifier ::= SEQUENCE  {
     algorithm    OBJECT IDENTIFIER,
     parameters   ANY DEFINED BY algorithm OPTIONAL
}

Version ::= INTEGER  {  v1(0), v2(1), v3(2)  }

Time ::= CHOICE {
     utcTime        UTCTime,
     generalTime    GeneralizedTime
}

CertificateSerialNumber ::= INTEGER

Extensions ::= SEQUENCE SIZE (1..MAX) OF Extension

Extension ::= SEQUENCE  {
     extnID      OBJECT IDENTIFIER,
     critical    BOOLEAN DEFAULT FALSE,
     extnValue   OCTET STRING
                 -- contains the DER encoding of an ASN.1 value
                 -- corresponding to the extension type identified
                 -- by extnID
}
```

The specification looks complicated but it boils down to the CRL consisting of a
block of initial meta-data, a sequence of items representing revoked
certificates, a sequence of optional extensions (some of which are not optional
as we will see later), an identifier indicating what cryptographic algorithm
was used to generate the digital signature, and finally a digital signature to
prevent the list from being tampered with.  I will be referring to the elements
of this specification extensively throughout the remainder of this document.

A digital signature works by taking a document and reducing it to a unique
number (a hash) using a cryptographic hash function.  The hash is then encrypted
with a private key.  To check the signature, one uses the public key of the
signer to decrypt the signature and reveal the hash.  The decrypted hash is then
compared with the actual hash of the document received.  If the hashes do not
match, the document has been tampered with.  The encrypting of the hash prevents
anyone from tampering with the document and then modifying the hash to align
with the alterations.  A signature algorithm therefore is a combination of a
hash algorithm and an encryption algorithm.

## Standard Reading Techniques
The standard technique for reading a CRL involves the reader walking through the
components of the CRL and building up a graph of objects where each object more
or less corresponds to one of the logical entities on the left-hand side of the
schema definition.  E.g. an array containing *Extension* entries or an array of
*revokedCertificate* objects.

The problem with this approach is that it can require a significant amount of
memory since every entry on the list is in memory at the same time.  However,
any information about the CRL can be randomly accessed once the object graph is
built which is a convenient property.

## Streaming Reading Technique
Imagine working on an assembly line.  After a widget has moved past us on the
conveyor belt, it's gone.  Likewise, when we are reading the CRL in as a stream
we receive data only once and it is inaccessible after that.  An input stream is
an abstract concept representing the consumption of data as it arrives.  Data
coming in over the network, for example, arrives in a stream and it is not
possible to assume that the data will ever be available again.  In reality, when
we are working with files on disk, we would have the ability to retrieve data
that has already been read once, but we are limited by the constraints of the
stream abstraction.  See [this
page](http://howtodoinjava.com/core-java/io/how-java-io-works-internally-at-lower-level/)
for a discussion of I/O in Java.

## Streaming Reading Process
This process is focused entirely on retrieving the revokedCertificate entries.
It does not return any information stored elsewhere in the *tbsCertList* nor
does it check the validity of the signature.  It is possible to do these things
but with an increase in complexity.  The decision to dispense with signature
verification means that this process is inappropriate for a CRL that does not
belong to the reader.  Reading a CRL issued by another entity without verifying
the signature potentially exposes the reader to using a counterfeit CRL.  I will
discuss alterations to the process that could be made to address these
deficiencies.

The reading process has four elemental operations.  Each one of these operations
can be passed a counter to track the number of bytes that it has consumed from
the stream.

* *Reading the tag* reads a single byte.
* *Reading the tag number* takes the tag byte and extracts the tag number from
  it by looking at bits five through one.  It is important to note that ASN1
  does allow for tags that use multiple bytes but the only tags that do so are
  tags representing data types that are not "universal", i.e. not already
  included in the ASN1 specification.  The CRL specification, however, does not
  use any non-universal tags (barring any custom extensions), so we can ignore
  this complication when discussing the high level mechanics in this document.
* *Reading the length* begins by reading a single byte.  If the eighth bit is a
  zero, interpret the other seven bits as the length, if it is one, the other
  seven bits indicate how many more bytes to read.  Read that many bytes and
  interpret the result as an unsigned integer.
* *Reading the value* reads *N* bytes and stores them into a byte array.  *N*
  is generally the value of the length we just read.

To only return the *revokedCertificates* entries, we need to begin by getting to
the beginning of the *revokedCertificates* sequence.  The following process is
performed when the caller first constructs the streaming reader:

1. Begin by reading the tag and length of the TLV for the *CertificateList*
   sequence.  Discard these values.  We have now descended into the
   *tbsCertList*.
2. Read the tag and the length of the *tbsCertList*.  We are now at the
   *version*.
3. Read tag, length, and value until we reach a tag number of type UTCTime or
   GeneralizedTime.  Now we are at the *thisUpdate*.  Read the tag, length, and
   value.
4. We are now either at *nextUpdate* or *revokedCertificates*.  Read the tag and
   read the tag number.  If it is of type UTCTime or GeneralizedTime, read the
   length, data, and then the next tag.  Read the length and store it as
   `seqLength` (the length of the *revokedCertificates* sequence).
5. We are now within the *revokedCertificates* sequence.

With the preliminary operations complete, we return the instantiated reader and
the caller can begin streaming sequences within *revokedCertificates* using the
`next` method.  This method returns one revoked certificate sequence each time
it is called.

1. Read and store the tag.  Decrement `seqLength` by the number of bytes read.
2. Read and store the length `L`.  Decrement `seqLength` by the number of bytes
   read.
3. Read `L` bytes and store them as the value `V`.  Decrement `seqLength` by the
   number of bytes read.
4. Reconstruct the revoked certificate sequence by writing the tag, length `L`
   encoded back into DER format, and the value `V` to a byte array.
5. Return the byte array.  This byte array is a valid DER sequence that can then
   be used as desired.  Callers will generally build a sequence object and then
   look at the *userCertificate* or *revocationDate*.

The caller can repeat the `next` operation as long as the `hasNext` method
returns true.  The `hasNext` operation simply looks to see if `seqLength` is
greater than zero.  If so, `hasNext` returns true.  The purpose of `hasNext` is
to prevent trying to read past the end of the *tbsCertList*.

Earlier I mentioned that this reading process does not return any meta-data
information or perform any signature verification.  Returning the meta-data
information would be straightforward.  The meta-data information is generally on
the order of a few hundred bytes so retaining it in memory is not problematic.
The caller would need to pass in some type of memo object to the streaming
reader when the reader is instantiated.  As the reader moves through the
meta-data items in the *tbsCertList* during initialization, it would simply
populate the memo object with the values.  The caller could then look in the
memo object once the reader has finished instantiation.

Signature verification is more complex.  Since the signature algorithm used is
required for the verification process and the algorithm information is towards
the end of the CRL, we would have to make two passes over the CRL.  The first
pass would skip as rapidly as possible to the *signatureAlgorithm* and then
construct a hasher using the same hash algorithm used by the
*signatureAlgorithm*.  Then we would need to reopen the CRL as a new stream (so
that we start back at the beginning) and perform our normal stream read
operations.  As we read, we would pass in every byte from the *tbsCertList* into
the hasher.  (Hashers have the useful property of being able to accept bytes
over time).  Once `hasNext` detects that the reader has reached the end of the
*tbsCertList*, we would ask the hasher to return the hash and encrypt it with
the issuer's public key using the encryption algorithm specified in the
*signatureAlgorithm*.  We would then continue to read the stream down to the
*signatureValue* and compare it to the signature we just calculated.  At this
point, `hasNext` can raise an exception or set a flag if the signatures do not
match.

## Standard Manipulation Techniques
As mentioned before, the standard technique for reading involves creating a
complete object graph in memory.  The standard technique for writing is to
manipulate the graph, adding additional *revokedCertificates* entries for
example.  Once the manipulations are complete, a writer converts the object
graph back into ASN1 as a *tbsCertList*, calculates the signature for the new
CRL, and then inserts the *tbsCertList*, signature algorithm, and signature into
an ASN1 sequence.

The memory requirements for this approach are still high with the additional
disadvantage that much of the memory is allocated to objects that CRL
manipulation programs are uninterested in.  A program that wants to add an entry
to the CRL is unlikely to require continual access to the other
*revokedCertificates* entries (aside from a quick check that the entry being
inserted isn't already present).  Furthermore, when it comes time to write the
CRL, time is wasted converting unchanged items back into ASN1.

The standard technique is analogous to memorizing an entire grocery list and
then writing the whole list on another piece of paper merely to add "eggs" to
the bottom of the list.  This analogy is slightly deceptive, however, because
modifying the CRL invalidates the signature and results in changes to the length
values in the ASN1 container sequences.  Let's amend our analogy and add the
stipulation that the list is written in ink and the paper is cut to the exact
length of the list.  With these new constraints, copying the list over to
another piece of paper is a reasonable and straightforward approach albeit a
laborious one.

## Streaming Manipulation Techniques
There is another way to modify our hypothetical grocery list.  What if we write
"eggs" on a strip of paper and glue it on to the bottom of our existing list?
This solution is fast and means that we don't have to reproduce the whole list
again, but it is potentially ugly and messy.  The streaming technique described
below is the equivalent of our pasted together grocery list complete with the
same virtues and liabilities.

## The Streaming Manipulation Process
At this point, let's discuss the L in an ASN1 TLV.  The L, length, must be
unfailingly accurate.  If it is inaccurate, other parsers will be unable to
decode what we wrote.  They will end up reading an incorrect number of bytes for
the value portion of the TLV.  The parser would then end up trying to read in
another TLV at an incorrect position and will invariably fail.

Imagine a script where the character's name, the T, is followed by the number of
lines they will speak, the L, and the lines themselves are the V.

    HORATIO: 1 lines
        Hail to your lordship!
    HAMLET: 2 lines
        I am glad to see you well:
        Horatio,--or I do forget myself.
    HORATIO: 1 line
        The same, my lord, and your poor servant ever.
    HAMLET: 2 lines
        Sir, my good friend; I'll change that name with you:
        And what make you from Wittenberg, Horatio? Marcellus?

Now imagine we inadvertently change the first direction to read "3 lines"
instead of "1 line".  Our literal-minded actors would speak the following
dialog:

    <Horatio>: "Hail to your lordship!  Hamlet 2 lines.  I am glad to see you well:"
    <Horatio>:

And then our actor playing Horatio stops because while "Horatio" is a valid T,
"--or I do forget myself" can't be interpreted as a number of lines to read (an
L).

This analogy illustrates the problem with an incorrect length in a single TLV.
However, our TLVs can contain other TLVs by using the ASN1 sequence type much
like if our play also had the number of lines specified for each scene and act.
If we are adding additional dialog we need to remember to update the number of
lines in the scene and the number of lines in the act.  Like throwing a stone
into a pond, a length change deep within nested structure ripples outward to the
containing structures.

A further complication ensues when we realize that the number of bytes used to
encode a length is factored in to length of the containing sequence.  Let's say
we have a sequence and it contains multiple TLVs.  On one of those TLVs, we add
a single byte to the value portion.  Consequently, we need to increase the
length of this TLV by 1.  If the current length value is 127, the length value
itself would require a single byte.  But increasing the length to 128 results in
DER requiring two byte (the first bit is reserved in the first length byte).
Therefore the length of our container sequence needs to increase by 2!  Once for
the actual byte we added to the V in our constituent TLV and once for the
additional byte now required to encode the L in the same TLV.  Accordingly, when
we compute the differences in lengths, we also need to account for the
difference in bytes required to encode each length in DER.  The function used
for this accounting is called `findHeaderBytesDelta(oldLength, newLength)`.

### Initialization
When creating the writer instance, some initial information is required.  We
need to know the public and private key to use for signing the CRL.  Since the
size of the signature depends on the size of the private key, we must do some
math to account for a CRL being signed with a different sized key.  The length
of an RSA signature (the only signature type currently supported by this method)
is equal to the length of the private key's modulus in bytes (see
[here](https://en.wikipedia.org/wiki/RSA_%28cryptosystem%29) for more
information on RSA).  We create an empty byte array sized the same as the
signature length and then encode that in DER as a bit string type.  We take the
length of the resulting dummy signature and store that as `newSigLength`.  We
will retain the public key to insert into the AuthorityKeyIdentifier extension
that is required by RFC 5280 for version 2 CRLs.

Our modifications can include either additions of revoked certificate entries or
deletions of existing entries where the certificate has reached its expiration
data and will thus never be valid in any circumstance.

For deletions, during this first pass, the caller must specify the serial
numbers that should be removed or a callback function that will be invoked with
the value of each existing *revokedCertificates* entry.  If the callback returns
true, that entry is marked for deletion.

For additions, the caller must specify the *userCertificate*, *revocationDate*,
and any extensions they desire (such as a revocation reason).  We encode this
information in DER to create a *revokedCertificates* entry and store each entry
in a list, `newEntries`.  We total the length of each entry and store it as
`addedEntriesLength`.

### The First Pass
In order to create a valid CRL, we need to modify several pieces of information
besides just the *revokedCertificates* entries.  Unfortunately, some of this
information is stored at the end of the CRL.  The solution is to make two passes
through the CRL.  In the first pass, we record pieces of existing data that we
need during the modification process.

The first pass begins by using the streaming read process to examine each
*revokedCertificates* entry.  If the entry has a serial number matching one of
the serials the caller marked for deletion, we record the length of that entry's
ASN1 sequence.  At the end, we total all the lengths to create
`deletedEntriesLength`.

Having reached the end of the *revokedCertificates* sequence, we are potentially
at the *crlExtensions*.  RFC 5280 requires two extensions for version 2 CRLs.
We continue the read tag, read length, and read value steps pausing after each
value is read to assess the whole TLV.  If the TLV has a tag number of 0, we are
at the *crlExtensions* (this 0 tag value is unusual but is described in the
RFC).  Store the subsequent TLV in its entirety as `oldExtensions`.

If the TLV has a tag number indicating it is a sequence, we have reached the
*signatureAlgorithm* sequence.  Read the sequence TLV and store it as
`signingAlg`.  Then read the TLVs within `signingAlg`.  The first sequence item
is the most important and corresponds to an OID.  We compare the OID we read
against a reference list.  Each OID corresponds to a particular hasher and
signer.  Based on the OID, we construct the appropriate hasher and signer.

Ultimately, we will reach the *signatureValue* TLV.  We read that TLV and store
the number of bytes as `oldSigLength`.

The `oldExtensions` require some adjustments.  We need to examine each extension
looking for the *crlNumber* extension.  The *crlNumber* is supposed to increase
every time the CRL is regenerated.  The extensions are just ASN1 sequences, so
we continue the pattern of reading the tag, length, and value to introspect each
extension.  The first item in the sequence will be an OID (an ASN1 object
identifier).  We are looking for OID 2.5.29.20 which the RFC has assigned to
mean *crlNumber*.  If the item matches, we read the next TLV which is an ASN1
octet string.  We interpret this octet string as an integer and add one to it.

The other extension that may need changing is the *authorityKeyIdentifier*.  If,
when iterating through the extensions, we find OID 2.5.29.35, then replace the
next TLV with the public key passed in during initialization encoded as an
AuthorityKeyIdentifier according to RFC specifications.

Store the modified extensions in DER as `newExtensions` and calculate the entire
difference in length using the formula `newExtensions.length -
oldExtensions.length` and store the result as `extensionsDelta`.  Since both
`newExtensions` and `oldExtensions` are DER encoded, there is no need to run
`findHeaderBytesDelta` on the two since the difference in the DER encoded
lengths already accounts for the difference in the header bytes.

The first pass is now complete.  We have gathered four pieces of information:
the total number of bytes we plan on removing due to deleted entries, the DER
encoded new extensions, the hashing and signing algorithms to use, and the
number of bytes in the old signature.

### The Second Pass
The second pass is where we write the modified CRL to output.  We open a new
input stream for the CRL and perform the following procedure:

1. Read the tag and length.  Store both these values as `topTag` and
   `oldTotalLength`.
2. We have moved to the *tbsCertList*.  Read the tag and length and store them
   as `tbsTag` and `oldTbsLength`.
3. Read the tag, length, and value for the initial entries of the *tbsCertList*
   storing in `tempOutput` as we go.
4. When we read a tag with a tag number of type GeneralizedTime or UTCTime, we
   have reached the *thisUpdate* field.  Since we are updating the CRL, we need
   to update this value.
5. Read the length and value.  Store the value as `oldThisUpdate`.  Based on the
   tag number construct a new GeneralizedTime or UTCTime with an appropriate
   time (such as the current time) and encode it to DER.  Store the new DER for
   *thisUpdate* in `tempOutput`.
6. Potentially, we are now at the *nextUpdate* field.  It would be possible to
   allow callers to specify this value, but instead I elected to set it to the
   new *thisUpdate* time plus the difference between the old *thisUpdate* and
   the old *nextUpdate*.  Read the tag and store it in `tempOuput`.  If its tag
   number is a GeneralizedTime or UTCTime, we need to write a new *nextUpdate*.
   Read the length and value.  Store the value as `oldNextUpdate`.  Compute the
   time difference between `oldThisUpdate` and `oldNextUpdate`.  Add that
   difference to the current time and encode that time in DER as the same type
   (GeneralizedTime or UTCTime) used originally.  Write the new *nextUpdate* to
   `tempOutput`.  Read the next tag and store it to `tempOutput`.
7. We are now at the *revokedCertificates*.  Read the tag and length.  Store the
   length as `oldRevokedCertsLength`.  Our stream is now at the start of the
   first *revokedCertificates* entry.
8. Pause the reading for a moment to adjust the preceding sequence lengths:
    * `newRevokedCertsLength = addedEntriesLength - deletedEntriesLength +
      oldRevokedCertsLength`
    * `revokedCertsHeaderBytesDelta =
      findHeaderBytesDelta(oldRevokedCertsLength, newRevokedCertsLength)`
    * `tbsCertListLengthDelta = addedEntriesLength - deletedEntriesLength +
      revokedCertsHeaderBytesDelta + extensionsDelta`
    * `newTbsLength = oldTbsLength + tbsCertListLengthDelta`
    * `tbsHeaderBytesDelta = findHeaderBytesDelta(oldTbsLength, newTbsLength)`
    * `sigLengthDelta = newSigLength - oldSigLength`
    * `totalLengthDelta = tbsCertListLengthDelta + tbsHeaderBytesDelta +
      sigLengthDelta`
    * `newTotalLength = oldTotalLength + totalLengthDelta`
9. Having calculated the length changes for *revokedCertificates*, *tbsCertList*
   and *CertificateList*, we can begin to write the new DER to the output.
    * Write `topTag`.
    * DER encode and write `newTotalLength`.
    * Write `tbsTag` and send it to the signer.  (Every byte of *tbsCertList*
      must go to the signer).
    * DER encode `newTbsLength`.  Write the result and send it to the signer.
    * Write the contents of `tempOutput` and send the them to the signer.
    * DER encode `newRevokedCertsLength`.  Write the result and send it
      to the signer.
10. Begin reading the TLVs for each *revokedCertificates* entry from the stream.
    At each read, we will decrement `oldRevokedCertsLength` by the number of
    bytes we have read.  If the entry we read has a serial that we were asked to
    delete, drop the entire entry.  Otherwise, write the TLV to the output and
    send it to the signer.
11. Once `oldRevokedCertsLength` has been reduced to zero, write each entry in
    `newEntries` to the output and send each to the signer.
12. Write `newExtensions` to the output and send it to the signer.
13. Write `signingAlg` to the output.
14. Ask the signer to generate a signature.  Encode that signature as a BIT
    STRING and write to the output.

### The Degenerate Case
There is one case where the streaming process is not appropriate.  If the CRL is
empty, the *revokedCertificates* sequence is simply not present in the ASN1.
Handling this case leads to difficulties as once we have proceeded through to
the *nextUpdate*, we would have to add a large amount of conditional logic to
determine whether we had reached the *revokedCertificates* or *crlExtensions*
and then handle the situation accordingly.  It is probably possible to add this
logic, but at the expense of code readability.  Instead, I elected to handle an
empty CRL as an exceptional case.  When we detect that there is no
*revokedCertificates* sequence during the first pass, a flag is set to true.
During the second pass, if this flag is true, we abort the streaming process and
use the conventional approach of reading into memory, manipulating the object
graph, and encoding the graph into DER.  This approach performs well enough for
small CRLs so long as we are not adding thousands upon thousands of entries.

# Certificate Revocation List & Online Certificate Status Protocol
The [CRL(Certificate Revocation List)](http://en.wikipedia.org/wiki/Revocation_list) is generated by
`CertificateRevocationListTask` on a regular basis for all the entitlements which have been revoked.

* The location where the crl is generated can be configured by specifying the property, by default the file is in /var/lib/candlepin/candlepin-crl.crl

  ```
  candlepin.crl.file=/etc/candlepin/candlepin-crl.crl
  ```

* To change the frequency

  ```
  pinsetter.org.candlepin.pinsetter.tasks.CertificateRevocationListTask.schedule = 0 5 * * * ?
  ```

  in the `candlepin.conf` file.

You can tweak the frequency at which the crl file is generated by changing
`DEFAULT_SCHEDULE` in CertificateRevocationListTask.

# Configuring CRL with ocspd
To verify the integrity of the CRL generated as well as use it in practice
using [ocspd](http://en.wikipedia.org/wiki/Online_Certificate_Status_Protocol),
please follow the following steps.

* Install ocspd. On fedora use the following command to install ocspd

  ```
      sudo yum install ocspd -y
  ```

* Configure ocspd.  You may have to customize to fit your needs. After doing so, please move the file to `/etc/ocspd/ocspd.conf`
* Start your ocspd daemon using the following command

  ```
       ocspd -v -d 9090 -c /etc/ocspd/ocspd.conf
  ```

  ocspd logs in `/var/log/messages`. When you try the above command, you should see something similar to the contents of [attachment:log.txt log.txt] file.
* Query the status of a serial using the following command,

  ```
      openssl ocsp -issuer /etc/candlepin/certs/candlepin-ca.crt -serial 0x01 -host localhost:9090 -CAfile /etc/candlepin/certs/candlepin-ca.crt
  ```

  When you query for some serial which is valid and not present in the crl list, you should see something similar to the text below.

  ```
    Response verify OK
    0x01: good
    This Update: Jul  7 18:22:30 2010 GMT
    Next Update: Jul  7 18:41:48 2010 GMT
  ```

  When you query for a serial which is not valid/revoked.(present in crl file), 

  ```
    Response verify OK
    0x31: revoked
    This Update: Jul  7 18:22:30 2010 GMT
    Next Update: Jul  7 18:42:03 2010 GMT
    Reason: (UNKNOWN)
    Revocation Time: Jul  7 00:00:00 2011 GMT
  ```

# Reference
 * <http://www.openca.org/projects/ocspd/>
 * <http://www.openssl.org/docs/apps/ocsp.html>
 * <http://wiki.cacert.org/OcspResponder>

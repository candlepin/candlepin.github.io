# Cryptography

- Goals
- Terms
- Mechanics
- Symmetric Ciphers
- Asymmetric Ciphers
- Cryptographic Hash Functions
- MACs
- Signatures

--
# Goals

- Confidentiality: outside parties can't decipher messages
- Integrity: outside parties can't tamper with messages
- Authenticity: outside parties can't masquerade as trusted parties
- Non-repudiation: provable that a message originated from a single source

--
# Terms

- Cipher

  The means of turning a message into encrypted text and then later reversing
  process.

- Cleartext

  The text of the message.
- Plaintext

  Cleartext formatted for the encryption process.  The cipher encrypts the
  plaintext.

- Ciphertext

  The outcome of applying the cipher to the plaintext.  Should be
  indistinguishable from gobbledygook.

- Key

  The key is the secret number used by the cipher to encrypt the message.
  Recipients need the key to decrypt the ciphertext.  In asymmetric ciphers,
  there are two keys and only one is kept secret.

Note:
The distinction between cleartext and plaintext is subtle but important.
Some ciphers may require the cleartext to be in certain formats (for example
in blocks of 16 bytes with padding on the end to fill up any short blocks).
The plaintext is the formatted cleartext.

--
# Mechanics

It all comes down to XOR because XOR is reversible.

| Plaintext | Key | Ciphertext |
|-|-|-|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

| Ciphertext | Key | Plaintext |
|-|-|-|
| 0 | 0 | 0 |
| 1 | 1 | 0 |
| 1 | 0 | 1 |
| 0 | 1 | 1 |

Note:
Every cipher has its own implementation details (e.g. number of times the
plaintext is run through the algorithm; how the plaintext is sliced and
diced), but ultimately everything arrives at XOR.

--
# Symmetric Ciphers

- Provide confidentiality
- One key to do all the work

  Plaintext + Key = Ciphertext

  Ciphertext + Key = Plaintext
- Fast
- Best for communication between just two parties
- Examples: AES (Rijndael), Blowfish, IDEA

--
# Asymmetric Ciphers

- Provide confidentiality and non-repudiation
- Two keys: public and private

  Plaintext + Public Key = Ciphertext

  Ciphertext + Private Key = Plaintext
- The public key should be (and often needs to be) widely distributed
- All these public keys need a management infrastructure
- Examples: RSA, ElGamal, ECDSA

Note:
Symmetric ciphers do not provide non-repudiation since both parties in the
conversation share the secret key.  With asymmetric ciphers, if Alice sends
a message and it's encrypted with her private key, we can decrypt it with
the public key and know that it only could have come from her (presuming the
key hasn't been leaked).

--
# Cryptographic Hash Functions

- Send in some input and get a unique, fixed-length output (a "digest")
- One way trip: someone with just the hash can't work backward to get the
  message
- No collisions: No two messages produce the same hash and it should be
  infeasible to specially craft a message that results in a targeted hash.
- A small variation in the message leads to large variation in the hash
- Used to create unique fingerprints for files, messages, certificates, etc.
- Examples: MD5 (don't use), SHA1 (don't use), SHA256

--
# MACs

- Message Authentication Codes
- An *encrypted* hash using a shared secret key (symmetric ciphers)
- Sent with the message to provide authenticity and limited integrity
  - Limited because they do not prevent replaying or dropping messages
- HMACs (Hashed MACs) mix the key and the message together and hash them
- Recipient performs the same mix with the shared key and the message they
  received.  If there's a mismatch, the message has been tampered with

Note:
The second point warrants further explanation.  Using a digest to verify
message integrity is pointless if an attacker can manipulate the hash
with impunity.

--
# Signatures

- An *encrypted* hash using a private key (asymmetric ciphers)
- Provide authenticity, limited integrity, and non-repudiation
- For RSA, creating a signature is the inverse of encrypting a message:

  Hash(Plaintext) + Private Key = Signature

  Signature + Public Key = Hash(Plaintext)
- Recipient compares the hash they calculate with the hash they decrypted
  using the sender's public key.  If they match, we know the message
  could have only come from someone with the private key
- Other algorithms use different signing methods but same general concept

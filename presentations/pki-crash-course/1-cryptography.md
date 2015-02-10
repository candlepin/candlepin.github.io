# Cryptography

- Goals
- Terms
- Mechanics
- Symmetric Ciphers
- Asymmetric Ciphers
- Cryptographic Hash Functions
- Signatures

--
# Goals

- Confidentiality: outside parties can't decipher messages
- Integrity: outside parties can't tamper with messages
- Authenticity: outside parties can't masquerade as trusted parties

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

- Provide confidentiality
- Two keys: public and private

  Plaintext + Public Key = Ciphertext

  Ciphertext + Private Key = Plaintext
- The public key should be (and often needs to be) widely distributed
- All these public keys need a management infrastructure
- Examples: RSA, ElGamal, ECDSA

--
# Cryptographic Hash Functions

- Send in some input and get a unique, fixed-length output (a "digest")
- One way trip: someone with just the hash can't work backward to get the
  message
- No collisions: No two messages produce the same hash and it should be
  infeasible to specially craft a message that results in a targeted hash.
- A small variation in the message leads to large variation in the hash
- Examples: MD5 (don't use), SHA1 (don't use), SHA256

--
# Cryptographic Hash Functions

- Provide message integrity (if the subsequent hash is encrypted)
- Create unique fingerprints for files (or certificates)

Note:
The first point warrants further explanation.  Using a digest to verify
message integrity is pointless if an attacker can manipulate the hash
with impunity.  To counter this, many encryption protocols call for an HMAC
(hash message authentication code) which mixes the key and message together
and then takes the hash thus insuring that non-key-holders can't tamper with
message digests.

--
# Signatures

- Provide authenticity
- For RSA, creating a signature is the inverse of encrypting a message:

  Hash(Plaintext) + Private Key = Signature

  Signature + Public Key = Hash(Plaintext)
- Recipient compares the hash they calculate with the hash they decrypted.
  If they match, we know the message could have only come from someone with
  the private key.
- Other algorithms use different signing methods

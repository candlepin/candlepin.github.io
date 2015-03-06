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
# Example

<div class="two_column left_float">
![Alice Cooper](alice.png "Alice Cooper")

Alice <!-- .element: class="caption" -->
</div>

<div class="two_column right_float">
![Robert Plant](bob.png "Robert Bob Plant")

Bob <!-- .element: class="caption" -->
</div>

--
# Example - Symmetric

Alice and Bob agreed on the key "heavymetal" before departing the tour

<div class="action_block">
![Alice](alice-small.png "Alice")

<pre><code>
% echo "Let's add an umlaut to the name" | openssl aes-256-cbc -a -pass pass:heavymetal | tee to_bob.txt
U2FsdGVkX18YUwyJ40AENC/KHY33SQ64zcJjNEixiOaITdgKlTt2hegIVTV0+htO
nLPNDb0wIcqTaW1izJHRBA==
</code></pre>
</div>

<div class="action_block">
![Bob](bob-small.png "Bob")

<pre><code>
% openssl aes-256-cbc -d -a -pass pass:heavymetal -in to_bob.txt
Let's add an umlaut to the name

% echo "Too cliche" | openssl aes-256-cbc -a -pass pass:heavymetal | tee to_alice.txt
U2FsdGVkX1+Iznlb/aup/LddQM9AJnr8U/UXlV7WAyg=
</code></pre>
</div>

<div class="action_block">
![Alice](alice-small.png "Alice")

<pre><code>
% openssl aes-256-cbc -d -a -pass pass:heavymetal -in to_alice.txt
Too cliche
</code></pre>
</div>
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
# Example - Asymmetric

Alice and Bob exchanged public keys before departing the tour

<div class="action_block">
![Alice](alice-small.png "Alice")

<pre><code>
% echo "Do the amps go up to 11?" | openssl rsautl -pubin -inkey bob.pub -encrypt | openssl base64 | tee to_bob.txt
eojXM/WUB65wbatFBn88TEvr7YBi5haP7iS0ID5RpFn7sPiY0J+fNvfTkctLwhfP
pP79KdF4RR6Fnoh+ZIB3ciOI3TxKovtQUgQOFGT4N++4w+4DuPfIl9do3DGLUhpt
6/rsyqIRMbF7S3aVbYEE0rQ5hYz2OEbmT64H8vBtFKrPaF6+xnX+tme2Pu1IO8qd
qY1bOlsfiI4H4QzaIDKoCA1uT5JK2u2QQyTFrCFfYdm610QARVyDShgBr/VggUQx
L2ua88+Yzme5jkcEQ5emb48dPm9xL9xaYN+NmPXmyd3+0r/i6PtHKwdGC6/H22c9
m9CWn+ClOal7ML54lBgdXw==
</code></pre>
</div>

<div class="action_block">
![Bob](bob-small.png "Bob")

<pre><code>
% openssl base64 -d -in to_bob.txt | openssl rsautl -inkey bob.key -decrypt
Do the amps go up to 11?

% echo "Totally" | openssl rsautl -pubin -inkey alice.pub -encrypt | openssl base64 | tee to_alice.txt
IjPBJ80M4+seS+v+b6cu/ItC/YjfSje7y+euRMJHdeV4nPnU5kQitUNJipdCowX0
rz3bOH6Hngfxgvsby+AXyhlQN2INwPD6N9wtx/XEXrGPvPN5QUIym1grtDohQipi
EPxu1xDbUof2PBlmyiq21N8u5GhaNItj9sEVrwk+YoDojHCSn78taUkuQ3JFNwRP
+yc7i9AN7BoN8OHrK5nGBwo4glI6wN5C4ppJV0i6MdTnRTsRjDAVkJAJhnOb4uhA
69SsQUMaaaZRFU+vsqIrja2iMoRKMUQAvAdjcarGYxO18blGTZ3yVE84mXo216Qr
Gk8etvyyOZa0u5M5oJpbTw==
</code></pre>
</div>

<div class="action_block">
![Alice](alice-small.png "Alice")

<pre><code>
% openssl base64 -d -in to_alice.txt | openssl rsautl -inkey alice.key -decrypt
Totally
</code></pre>
</div>

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

--
# Example - Signatures

Alice sends a message to a mailing list and Bob wants to verify who wrote it

<div class="action_block">
![Alice](alice-small.png "Alice")

<pre><code>
% echo "School's out for summer" > lyrics.txt
% openssl sha256 lyrics.txt | openssl rsautl -inkey alice.key -sign | openssl base64 >> lyrics.txt
% cat lyrics.txt
School's out for summer
TW510XuRliGtf2jtLcLdGwcTq2In5w9ULKreG4RY0li6fiere9umq7Z3MC9jNHft
QmzKfekGklINKyVAA3QWh77O7MnUL2Z28DG77iH2eAhYqPDNTactSvqwrFT0c1MJ
/m05qT2a3AVYEzO++aQYS/c+tcDIwf3iKrZgXXLYFQzABjfMuBp1M+3oizFi1nqE
JXUk3/BiK+2CHLtyszGzPhdCfYVKjQPlZvpwHa06HnZsWIcSCcL3Uy5x0DIitriq
VbvGyyrIlfhwpaQYHtqggUto+Yj011rTOIXfRnk4NxDq3MHQHsJmQ2dm9hnveJI4
8mSi+GCwRdW+fLDsYzeVXA==
</code></pre>
</div>

<div class="action_block">
![Bob](bob-small.png "Bob")

<pre><code>
% sed -n '1p' lyrics.txt > message.txt
% sed -n '2,$p' lyrics.txt > signature.txt
% openssl base64 -d -in signature.txt | openssl rsautl -inkey alice.pub -pubin -verify
SHA256(lyrics.txt)= 6c4fc3b953f7ad20a087b6d24b3dc16bb70a6ce1ac5cce51c369fed2e97faf92
% openssl sha256 message.txt
SHA256(message.txt)= 6c4fc3b953f7ad20a087b6d24b3dc16bb70a6ce1ac5cce51c369fed2e97faf92
% diff -s -q <(!! | cut -d' ' -f2) <(!-2 | cut -d' ' -f2)
Files /proc/self/fd/11 and /proc/self/fd/12 are identical
</code></pre>
</div>

--
# Example - Signatures

Lemmy Kilmister gives Bob a message from Alice but it doesn't sound like Alice...

<div class="action_block">
![Alice](alice-small.png "Alice")

<pre><code>
% echo "No more Mr. Nice Guy" > lyrics2.txt
% openssl sha256 lyrics2.txt | openssl rsautl -inkey alice.key -sign | openssl base64 >> lyrics2.txt
% openssl rsautl -inkey alice.key -sign -in lyrics2.txt | openssl base64 >> lyrics2.txt
% cat lyrics2.txt
No more Mr. Nice Guy
XLNoxhulst///d1gDGIrx5OcjVRJqlfuNl0fi3i212Y/K8ams/qOKn9pnYWXD7dv
RMkZJmebSzl7yy+y9koNSMJFRtNy5kd95Lt6nZjXwaJ1HO+Xhauo0McGKirs4teP
w79xz1P9Tm4aUb7QCkhX9ypPYoX8B7h4CH0ld+SQLx0Z0bIiHsIgvAlvqF45OH7S
O/0beCncXmef4O4T2xQcJMbjxrNWVDdl7aMgaeDf4tYxdbzuuusacVqw/uU9L1hu
RTXEpPxpppTG+DQ7dFIzCOQI6fusCCYSmC6iVHRBX97yfodpIkP2qt1dDdxBvAQv
ibi8ab815W62xEjhUrbXSA==
</code></pre>
</div>


<div class="action_block">
![Bob](bob-small.png "Bob")

<pre><code>
% cat lyrics-strange.txt
The only card I need is the ace of spades
XLNoxhulst///d1gDGIrx5OcjVRJqlfuNl0fi3i212Y/K8ams/qOKn9pnYWXD7dv
RMkZJmebSzl7yy+y9koNSMJFRtNy5kd95Lt6nZjXwaJ1HO+Xhauo0McGKirs4teP
w79xz1P9Tm4aUb7QCkhX9ypPYoX8B7h4CH0ld+SQLx0Z0bIiHsIgvAlvqF45OH7S
O/0beCncXmef4O4T2xQcJMbjxrNWVDdl7aMgaeDf4tYxdbzuuusacVqw/uU9L1hu
RTXEpPxpppTG+DQ7dFIzCOQI6fusCCYSmC6iVHRBX97yfodpIkP2qt1dDdxBvAQv
ibi8ab815W62xEjhUrbXSA==
% sed -n '1p' lyrics-strange.txt > message.txt
% sed -n '2,$p' lyrics-strange.txt > signature.txt
% openssl base64 -d -in signature.txt | openssl rsautl -inkey alice.pub -pubin -verify
SHA256(lyrics2.txt)= 7bb2c4647ab5b0002e1de8686e1d8e1cc5568f85b0866006dfa60025966e64c3
% openssl sha256 message.txt
SHA256(message.txt)= e4f97ede052cb671344553e8dff2b1b61ed077548a5dce9a575b9fd0af37b0b1
% diff -s -q <(!! | cut -d' ' -f2) <(!-2 | cut -d' ' -f2)
Files /proc/self/fd/11 and /proc/self/fd/12 differ
</code></pre>
</div>

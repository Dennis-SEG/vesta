#!/usr/bin/env python3
import base64

# Read the PuTTY private key
with open('new private.ppk', 'r') as f:
    lines = f.readlines()

# Extract private key lines
private_lines = []
in_private = False
for line in lines:
    if line.startswith('Private-Lines:'):
        in_private = True
        continue
    elif line.startswith('Private-MAC:'):
        break
    elif in_private:
        private_lines.append(line.strip())

# Combine and decode
private_key_b64 = ''.join(private_lines)
private_key_bytes = base64.b64decode(private_key_b64)

# Extract public key lines
public_lines = []
in_public = False
for line in lines:
    if line.startswith('Public-Lines:'):
        in_public = True
        continue
    elif line.startswith('Private-Lines:'):
        break
    elif in_public:
        public_lines.append(line.strip())

public_key_b64 = ''.join(public_lines)

# Write OpenSSH format
with open('vesta-key.pem', 'w') as f:
    f.write('-----BEGIN RSA PRIVATE KEY-----\n')
    # Write the private key data in 64-char chunks
    for i in range(0, len(private_key_b64), 64):
        f.write(private_key_b64[i:i+64] + '\n')
    f.write('-----END RSA PRIVATE KEY-----\n')

print("Key converted to vesta-key.pem")

-- Cryptographic sender attribution for group messages (ADR-29).
--
-- Until now, who sent a group message was attested by the SERVER: the RLS
-- policy `messages_member_send` enforces `sender_id = auth.uid()` on insert.
-- That is a real control, but it is the server's word, and it is the one
-- guarantee that does not survive the server going away — which is exactly
-- the case the offline Wi-Fi transport analysis is aimed at
-- (`docs/research/offline-wifi-transport.md`).
--
-- Messages are encrypted with AES-GCM under a key SHARED by the whole group.
-- That proves a message came from someone holding the group key; it does not
-- prove which member. So without a signature, any group member could
-- originate a message attributed to any other member the moment the transport
-- is not a server that stamps sender_id. In this app the plausible attack is
-- a forged "the medical tent has moved" from a trusted organiser.
--
-- Fix: each device publishes an Ed25519 signing public key alongside its
-- X25519 identity key, and signs (group, epoch, ciphertext). Two keys because
-- an X25519 key cannot sign.
--
-- Nullable on purpose: existing installs have no signing key until they next
-- open the app. Clients treat "sender has no published key" as unverifiable,
-- and "sender HAS a key but sent an unsigned message" as invalid — which is
-- what closes the downgrade attack.

alter table public.device_keys
  add column if not exists signing_public_key text
    check (char_length(signing_public_key) <= 128);

-- No new policies needed and none wanted: device_keys already reads to any
-- authenticated user (you must be able to seal to, and verify, other members)
-- and writes only to `user_id = auth.uid()`. That existing write rule is what
-- stops anyone publishing a signing key on someone else's behalf, which would
-- let them forge that member's messages.

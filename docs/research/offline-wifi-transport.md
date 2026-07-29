# Offline Wi-Fi / hotspot transport — feasibility analysis

_2026-07-28 · analysis only, no code written. Companion to ADR-17 (no Bluetooth
mesh). Turn into an ADR when a direction is chosen._

## The question

Can CommonGround exchange data device-to-device over Wi-Fi when there is no
internet, and what is the right way to encrypt it?

The motivating scenario is real and specific: India leads the world in
government-ordered internet shutdowns, and a shutdown during a protest is
exactly when a facility map matters most. Everything the app does today
degrades gracefully offline — but "offline" currently means *reads from
cache*, not *new information reaching you*.

## Short answer

**Yes, but not as a phone-to-phone mesh.** The buildable shape is:

- an **island**, not a mesh: one access point, everyone within ~20–50 m of it;
- **Android can host, iOS cannot** — this is a hard platform limit, not a
  library gap;
- **the web/PWA build gets none of it**, which matters because that is
  currently how the app is being tested on iPhone;
- and the encryption question is already answered: **treat the Wi-Fi link as
  hostile and reuse the existing E2E envelopes**. WPA2/WPA3 is not the
  security boundary and must never be described as one.

The single highest-value variant is a **dedicated hub device** (a cheap
battery-powered travel router or Pi) rather than a volunteer's phone. It
removes the iOS limitation, the battery problem, and the "my phone is the
infrastructure and also my life" problem in one move.

---

## 1. What the platforms actually allow

| Capability | Android | iOS | Web/PWA |
|---|---|---|---|
| Start a local AP from the app | ✅ `startLocalOnlyHotspot()` (API 26+) | ❌ **impossible** | ❌ |
| Join a specific AP from the app | ✅ `WifiNetworkSpecifier` (10+) | ✅ `NEHotspotConfiguration` (needs entitlement) | ❌ |
| Wi-Fi Direct / P2P | ✅ `WifiP2pManager` | ❌ not exposed | ❌ |
| Wi-Fi Aware (NAN) | ⚠️ 8+, hardware-dependent | ❌ | ❌ |
| Peer framework | Nearby Connections | Multipeer Connectivity | ❌ |
| mDNS discovery + TCP/UDP on a joined LAN | ✅ | ✅ (`NSLocalNetworkUsageDescription` + `NSBonjourServices`, iOS 14+) | ❌ |

Two things fall out of that table.

**iOS can never be the host.** Personal Hotspot is a Settings toggle gated on
carrier entitlement, not an API. Multipeer Connectivity works iOS↔iOS over
AWDL but does not interoperate with Android at all — supporting it means
building and maintaining a *second, incompatible* transport for a minority of
one-platform-only crowds. Not worth it.

**Joining is cross-platform; hosting is not.** So the portable half of the
work is the LAN protocol (discovery + sync + crypto), and the platform-specific
half is only "who makes the radio". That is the seam the design should follow.

**The web build is out entirely.** Browsers have no raw sockets and no mDNS.
Any hotspot feature is Android/iOS-app-only, and the PWA must not advertise it.

## 2. Why this is islands, not a mesh

A phone soft-AP covers roughly 20–50 m through a crowd (bodies absorb 2.4 GHz
well); line of sight is better, a dense protest is worse. Jantar Mantar is
much larger than one cell.

Multi-hop would need devices to be AP and client simultaneously (STA+AP
concurrency). That is hardware-dependent on Android and impossible on iOS, and
it is the point where this stops being "a Wi-Fi feature" and becomes "writing a
mesh routing protocol" — the same multi-month, independently-reviewed effort
ADR-17 declined for Bluetooth.

So the honest product framing is **sync islands**: you walk near a hub, your
device exchanges what it has for what it lacks, and you carry that away with
you. Sneakernet with radios. That happens to fit the existing outbox model
exactly.

## 3. The security analysis

### WPA is not the boundary

Three independent reasons the Wi-Fi layer cannot be trusted:

1. **The AP owner sees everything at layer 3.** Whoever runs the hotspot is a
   full man-in-the-middle by construction.
2. **WPA2-PSK gives no protection between clients.** Everyone has the same
   pre-shared key, so anyone who captures another client's 4-way handshake can
   derive that client's session key and decrypt its traffic. WPA3-SAE fixes
   this with per-session keys and forward secrecy — but Android's
   local-only hotspot is WPA2 on most versions, and the device mix at a protest
   cannot be assumed WPA3-capable.
3. **It is a beacon.** A soft AP broadcasts an SSID continuously and is
   trivially direction-findable with a cheap sniffer. Clients emit probe
   requests. In a threat model that includes police surveillance, *turning this
   on makes the phone visible*. A branded SSID ("CommonGround-Mesh") is a
   label saying "organiser here".

Point 3 deserves the same treatment ADR-24 gave the alert chime: offer the
capability, default it **off**, randomise the SSID per session (never the app
name), and tell the user plainly what switching it on costs. Hidden SSIDs are
not a mitigation — they make *clients* probe more aggressively, which is worse.

### The encryption design writes itself

The app already has, in `core/crypto/`:

- X25519 device identity, private seed in the OS keystore (`device_identity_service.dart`);
- ECIES sealed delivery of a random 256-bit group key (`sealGroupKey` / `openGroupKey`);
- AES-GCM-256 message encryption under the group key (`encryptMessage`), with
  **key epochs** (ADR-20) so rotation does not destroy history;
- ciphertext-only local caching (ADR-19) and an oldest-first drain queue.

A LAN transport should therefore carry **exactly the same opaque envelopes the
Supabase path carries** and add no new secrets. `RemoteSyncApi` is already a
one-method interface (`push`), and `RemotePullService` is already the read
half — a `LanSyncApi` slots in beside `SupabaseRemoteApi` rather than
replacing anything. Group scoping keeps working because a non-member simply
does not hold the epoch key: they can copy the bytes and learn nothing.

**Do not invent a second crypto system for the LAN.** That is the whole
recommendation.

### The one real gap: sender authentication

Today `encryptMessage` is AES-GCM under a **shared group key**. That proves a
message came from *someone holding the group key* — it does not prove *which
member*. Sender identity is currently attested by the server: the RLS policy
`messages_member_send` enforces `sender_id = auth.uid()` on insert.

Remove the server and that guarantee evaporates. On a LAN, any group member
could originate a message claiming to be from any other member. In a protest
context — where a forged "the medical tent has moved to X" from a trusted
organiser is a plausible attack — that is not acceptable.

Fix: give each device an **Ed25519 signing key** alongside its X25519 identity
key, publish it in `device_keys`, and sign `(group_id, epoch, msg_id,
ciphertext)`. Receivers verify against the group roster's public keys.
Notes:

- X25519 keys cannot sign directly. Either add a separate Ed25519 key (simple,
  needs a `device_keys` column + migration) or adopt XEdDSA (not exposed by the
  `cryptography` package). **Add a separate key.**
- This is worth doing **regardless of whether the LAN transport ships** — it
  upgrades the Supabase path from server-attested to cryptographically attested
  sender identity, which is what an E2E system should offer anyway.

### Channel security on top (defence in depth)

Even with signed, group-encrypted payloads, the link itself should be
authenticated so a stranger on the same Wi-Fi cannot flood or fingerprint
peers. The right primitive is a **Noise handshake (Noise_IK)** between device
identity keys — ephemeral-static gives forward secrecy, and group members
already hold each other's X25519 public keys through the envelope system, so
there is no new trust distribution problem. Everything needed (X25519, HKDF,
AES-GCM) is already in the `cryptography` dependency.

Avoid TLS with self-signed certs: it means shipping a certificate story, and
this app already has one unresolved (`certificate_pinning.dart` is inactive
pending a real pin bundle). Do not add a second.

### Replay, flooding, metadata

- **Replay**: message ids are already primary keys in the cache, so dedupe is
  free. Add a per-sender monotonic counter inside the signed payload to catch
  reordering.
- **Flooding**: rate-limit per peer identity, cap message size, cap the sync
  window. An unauthenticated peer gets nothing but a handshake attempt.
- **Metadata**: the hub learns who is nearby and when. Minimise by never
  logging, keeping peer records in memory only, and treating the roster as
  ephemeral. Randomised MACs help but the AP still sees a stable
  per-network MAC per device.

## 4. Recommended shape, in order

**Phase A — LAN transport, no hotspot code at all.**
Discovery over mDNS (`bonsoir` — Android + iOS), transport over plain TCP
sockets from `dart:io`, payloads = existing envelopes, Noise_IK channel,
Ed25519 sender signatures. Works today the moment *any* AP exists, including a
router with its uplink unplugged. Fully cross-platform, no new permissions
beyond iOS local-network, testable on a desk with two phones and a home router.
This is where nearly all the value is.

**Phase B — Android host.** `startLocalOnlyHotspot()` with a random SSID,
displayed as a `WIFI:T:WPA;S:…;P:…;;` QR code. Both the iOS Camera app and
Android natively understand that format, so joining is a scan — and the app
already ships `mobile_scanner` and `qr_flutter` for group invites. iOS can also
join programmatically via `NEHotspotConfiguration` if the entitlement is worth
requesting.

**Phase C — dedicated hub (recommended over B for real deployments).** A
~£15 OpenWrt travel router or a Pi Zero W on a battery, running the same sync
service. It removes the iOS host limitation, does not drain a person's phone,
lets you *mandate* WPA3-SAE because you control the AP, and can live in a
medical tent or water point — facilities the app already maps. It holds only
ciphertext, so seizure yields metadata at worst.

**Explicit non-goals**, to be written into the ADR:
iOS as host · iOS↔iOS Multipeer · multi-hop routing · web support · and
calling any of this "a mesh" in user-facing copy.

## 5. Costs and things that would regress

- **Battery.** Hosting a soft AP is one of the heaviest sustained radio loads a
  phone has. At a protest, battery is safety. This was one of ADR-17's three
  objections to BLE mesh and it applies here too — which is the strongest
  argument for Phase C over Phase B.
- **Permissions.** Android 13+ has `NEARBY_WIFI_DEVICES` with
  `neverForLocation`, which is clean. **Android 12 and below require
  `ACCESS_FINE_LOCATION` just to scan or use P2P** — that would undo ADR-28's
  position that the app's only location access is the explicit one-shot share.
  Either set `minSdk` for the feature to 33 and hide it below that, or accept
  the regression and document it loudly. Recommend the former.
- **Attack surface.** A listening socket on a device in a crowd is a new
  remote attack surface, reachable by anyone who joins the same Wi-Fi. Parsing
  must be treated as hostile input, exactly like `inviteCodeFrom()` is for QR.
- **Testing.** None of this can be verified in CI or on an emulator pair
  meaningfully. It needs two physical devices, which is already the blocking
  constraint on the E2E chat smoke test.

## 6. Verdict

Worth building, in this order: **Ed25519 sender signatures first** (valuable on
its own), then **Phase A**, then **Phase C**. Phase B only if a hub device is
not realistic for the deployment.

What should *not* happen is a phone-to-phone "mesh" framing. It over-promises
range, drains the batteries of the people relying on it, cannot include iPhone
hosts, and would push the project toward the multi-month routing-protocol work
ADR-17 already declined on the same grounds.

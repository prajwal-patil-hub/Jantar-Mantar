# Adapting CommonGround to floods, earthquakes and other disasters

_2026-07-30 · research + threat-model analysis. Sources are recent reporting,
listed inline. One piece of this is already built (ADR-30); the rest is a
prioritised backlog with an explicit **never build** list._

## Why this is a small change technically and a large one ethically

The app's data model is already the right shape for a disaster. It maps
**facilities** (water / food / shelter / medical / toilet / safe area / danger)
with **capacity for N people**, a **status**, a **freshness TTL**, and
verification before public display. A relief camp *is* a shelter facility with
a capacity. A tanker *is* a water facility. The offline-first outbox, the
ciphertext-only cache, the trust tiers and the corroboration trigger all
transfer unchanged.

What does **not** transfer unchanged is the threat model. Section 3 is the
important part of this document.

---

## 1. What the reporting says is actually missing

### Floods — Assam, July 2026 (live as of writing)

- **6.54 lakh people affected across six districts, 274 relief camps active**
  ([NE India Broadcast, 28 Jul 2026](https://neindiabroadcast.com/2026/07/28/assam-flood-update-6-54-lakh-people-affected-across-six-districts-274-relief-camps-active/));
  700,000+ affected in the latest wave with 60+ deaths
  ([Maps of India](https://www.mapsofindia.com/my-india/news/assam-floods-2026-death-toll-affected-districts-and-relief-efforts)).
- **The gap is sanitation and water, and it is measurable.** Around 20,000
  diarrhoea cases. One camp of **15,000 people with 6 latrines and 3 hand
  pumps**; another of **13,000 people with 3 latrines and 6 hand pumps**, with
  people drinking from a nearby pond and defecating in the open. Women had no
  private space to bathe ([Oxfam](https://www.oxfam.org/en/press-releases/assam-facing-deepening-humanitarian-crisis)).
- **Coordination failure has a specific shape: visibility bias.** Camps that
  appear on an official's itinerary receive disproportionate attention while
  equally affected but less visible camps wait — "a structural tension where
  symbolic presence and operational efficiency compete for the same limited
  administrative capacity" — alongside fragmented volunteer effort
  ([Assam Times](https://www.assamtimes.org/article/many-hands-no-single-grip-the-coordination-paradox-of-flood-relief-in-sivasagar)).

Put the Assam numbers against the humanitarian minimums and the gap stops
being rhetorical:

| Measure | Sphere / UNHCR minimum | Assam camp A | Assam camp B |
|---|---|---|---|
| People per latrine (first phase) | **≤ 50** | 15,000 ÷ 6 = **2,500** | 13,000 ÷ 3 = **4,333** |
| Water | **15 L/person/day** | 3 hand pumps for 15,000 | 6 hand pumps for 13,000 |
| Latrine distance | ≤ 50 m from dwellings | — | — |

Sources: [Sphere Handbook WASH chapter](https://handbook.spherestandards.org/?handbook=Sphere&lang=english&chapter_id=ch006&section_id=ch006_005&match=toilet),
[UNHCR emergency sanitation standards](https://emergency.unhcr.org/emergency-assistance/water-hygiene-and-energy/emergency-sanitation-standards).

**That is 50× to 87× worse than the emergency maximum, and nobody had the
number.** The number is the intervention. It is computable from data this app
already models.

### Earthquakes — Venezuela, June 2026

- 1,430+ dead in twin quakes; **an aftershock collapsed a bridge and cut the
  parish of Caraballeda off from La Guaira**, disrupting relief mid-response
  ([CNN live](https://www.cnn.com/2026/06/27/world/live-news/venezuela-earthquake-hnk),
  [Wikipedia](https://en.wikipedia.org/wiki/2026_Venezuela_earthquakes)).
- **Convergence, not scarcity, was a bottleneck**: "coordination problems have
  been the airfields, with a lot of different groups from all around the world
  trying to land at the same airfield."
- Hospitals overwhelmed; families left waiting for word on relatives.

The earthquake-specific lesson is **route status changes hour to hour**. A
bridge that existed this morning does not exist now. The app maps *points*; a
disaster needs *edges* — "this road is impassable" — which is the single
biggest genuine gap in the current model.

### Communications

The first infrastructure to fail is the one everyone depends on: base-station
cabinets flood, backhaul snaps, towers topple
([Hytera](https://www.hytera.com/en/connect/blog/when-networks-go-dark-what-emergency-communication-really-is-and-why-it-matters)).
After the Türkiye earthquakes, GSM was down for days and "lack of
communication for the first days created coordination problems."

This is the same conclusion the Wi-Fi transport analysis reached from the
protest side (`offline-wifi-transport.md`) — and it raises the priority of
that work, because in a disaster there is no adversary reason *not* to run a
hotspot. The emissions objection that dominates the protest case largely
evaporates.

### Misinformation

- **Viral posts have a median engagement half-life under two hours — faster
  than most verification and moderation cycles**, and false news travels ~6×
  faster than true ([Bulletin of the Atomic Scientists](https://thebulletin.org/2025/09/ai-misinformation-is-threatening-emergency-communications-heres-how-to-fix-that/)).
- Fake rescue claims during the Maui wildfires forced agencies to fight
  conspiracy theories alongside the fire.
- AI-generated fake disaster video is rising sharply in 2026
  ([RaillyNews](https://raillynews.com/2026/07/rapid-rise-of-ai-generated-fake-videos-in-natural-disasters/)).

**This is the strongest external validation of work already done.** A
verification queue with a two-hour turnaround is useless against a two-hour
half-life. Corroboration auto-verify (ADR-26) and trust-tier verifiers
(ADR-25) exist precisely to collapse that latency without opening the door to
sock puppets.

### Official alerting in India is currently degraded

India's CAP-based national alert system (**SACHET**, cell broadcast) launched
**2 May 2026** across all 36 states and UTs, then was **temporarily suspended**
pending technical and procedural fixes
([Zee Business](https://www.zeebiz.com/india/news-emergency-alerts-suspended-for-the-time-being-ndma-issues-advisory-397223),
[SACHET portal](https://sachet.ndma.gov.in/)).
CAP is the ITU-recommended interoperability standard, so it is the right thing
for the app to *read* — but the official channel being intermittently down is
itself the argument for a resilient second path.

### The historical warning: Haiti

Crowdsourced crisis mapping in Haiti ran with **no established data-protection
protocols** — responders were "on uncharted territory", and an SMS code of
conduct was being called for only two months later. The Harvard Humanitarian
Initiative found that the lack of a formal contact point with volunteer
coordinators **overwhelmed already overworked responders**
([Ushahidi reflections](https://www.ushahidi.com/about/blog/crisis-mapping-haiti-some-final-reflections),
[J. Int. Humanitarian Action](https://jhumanitarianaction.springeropen.com/articles/10.1186/s41018-018-0048-1)).

Two lessons, both binding on this project: decide the data-protection rules
*before* deployment, and do not create a firehose that a formal responder is
expected to drink from.

---

## 2. Where the existing app already fits

| Disaster need | Already built |
|---|---|
| Works with no network | Offline-first Drift cache, outbox with backoff |
| Camp / water / medical locations | Facility model + map + clustering + filters |
| "Is it still true?" | Freshness TTL banding, stale banner |
| Stop rumour reaching the map | Verify-before-display (ADR-2) |
| Verification at speed | Trust tiers (ADR-25) + corroboration (ADR-26) |
| Stop a captured account | Moderator hold (ADR-27) |
| Who really said this | Ed25519 sender signatures (ADR-29) |
| Coordinating a response team | Groups + E2E chat + broadcasts |
| Multi-site | `MapConfig.sites` |
| Low-end devices, Hindi | Already a hard requirement |

Very little of a disaster build is new plumbing. Almost all of it is judgement.

---

## 3. The threat model inverts — and that is where the loopholes are

The dangerous assumption would be that "disaster" is a friendlier context than
"protest" and the safeguards can relax. Some genuinely can. Others must get
**stricter**, because a disaster produces a population that is locatable,
desperate, and predictable — which is exactly what a predator needs.

| Dimension | Protest (built for this) | Disaster | Verdict |
|---|---|---|---|
| Primary adversary | The state / police | Scammers, looters, traffickers — **and still sometimes the state** (Assam's citizenship politics; Venezuela) | Do **not** assume the state is benign |
| Anonymity of reporters | Essential | Still essential for survivors; less so for *organisations* | Keep anonymous default |
| Radio emissions (SSID, chime) | Dangerous — identifies you | Mostly fine; a phone that beeps in rubble is a **feature** | Relax **per-deployment**, never silently |
| Verification latency | Bad | **Fatal** — 2-hour misinformation half-life | Push harder on corroboration |
| Interop with authorities | Deliberately none | Necessary (CAP) | Read-only inbound only |
| Precise personal location | Never server-side | Still never server-side | **Unchanged** |
| Dwellings on the map | Never mapped | **Must still never be mapped** | Stricter, see below |

### The never-build list

These are the features a disaster app is most often asked for, and each one is
a weapon. Writing them down is the point of this document.

1. **Anything that marks homes or areas as evacuated, empty, or already
   visited by aid.** Looting of evacuated properties is a documented,
   recurring pattern — "individuals frequently victimize abandoned businesses
   and residences … from pre-disaster evacuation"
   ([FBI](https://www.fbi.gov/contact-us/field-offices/sanantonio/news/fbi-san-antonio-issues-warning-about-disaster-related-fraud-schemes),
   [AccuWeather](https://www.accuweather.com/en/weather-news/authorities-warn-of-looting-scams-and-fraud-cases-during-post-florence-relief-efforts/70006105)).
   A crowdsourced "evacuated" layer is a burglary itinerary with a refresh
   button. **Map facilities, never dwellings.**

2. **A public vulnerability register** — "elderly person alone here", "needs
   insulin", "disabled, cannot evacuate". This is the most-requested disaster
   feature and the most dangerous dataset the app could hold. If it is ever
   built it must be group-scoped, E2E-encrypted, never server-readable and
   never on the public layer. The honest answer is that it probably should not
   be in a public-map app at all.

3. **A missing-persons board.** This is personal data about people who cannot
   consent, published at the moment they are least able to protect
   themselves; post-disaster trafficking is a real phenomenon, and Haiti is
   the cautionary tale for exactly this. The ICRC's Restoring Family Links
   already exists and is accountable. **Link to it; do not rebuild it.**

4. **Free-text URLs, phone numbers or payment details in public pins.**
   Criminals register scam domains *as soon as storm names are published*, and
   file aid claims using survivors' stolen identities
   ([FEMA](https://www.fema.gov/press-release/20250714/be-alert-fraud-after-disaster)).
   A crowdsourced "donate here" field becomes a scam channel within hours.

5. **A client-side "disaster mode" that relaxes verification thresholds.** Any
   relaxation must be server-side, geographically scoped, time-boxed and
   audited — otherwise it is a switch an attacker flips to make their own
   reports auto-publish.

### Loopholes to close in features we *do* want

- **CAP ingest is hostile input.** Parsing government XML from a URL brings
  XXE, entity expansion and feed spoofing. Requirements: fixed allowlisted
  origin, TLS pinned, external entities and DTDs **disabled**, size and depth
  caps, and official alerts rendered in a visually distinct channel that
  crowd reports can never imitate. Same discipline as `inviteCodeFrom()`.
- **Never write official alerts into the crowd table, or vice versa.** Same
  reasoning as ADR-21 keeping group broadcasts out of `public.alerts`.
- **Pseudonym linkage.** Trust tiers give each account a persistent
  pseudonymous history. In a camp of 200, "the person who reports the water
  status every morning" is identifiable by pattern alone. Mitigation is to
  keep `reporter_history` admin-only (already true, ADR-27) and to resist any
  public "top contributor" display. **Never add leaderboards.**
- **Photos.** EXIF stripping already exists (ADR-22 pipeline) and becomes more
  important, not less: a photo of a camp encodes who was standing where.

---

## 4. Prioritised backlog

**Built (ADR-30): Sphere adequacy ratios.** Turn the map's existing facility
and capacity data into the number the Assam reporting shows nobody had —
persons-per-latrine and litres-per-person against the published minimums,
shown on any shelter/camp pin. No new data, no new permissions, no personal
information. See §5.

**Next, in order of value ÷ risk:**

1. **Road / route status ("edges, not just points")** — the Venezuela lesson.
   A `blocked` facility type is a poor proxy for "this bridge is gone".
   Needs a genuine model addition (segments, not pins) and is the largest
   real gap.
2. **CAP ingest, read-only** — pull SACHET / official CAP feeds into a
   separate, visually distinct official-alert channel. Hardened parse per §3.
3. **Wi-Fi LAN transport (Phase A of `offline-wifi-transport.md`)** — the
   emissions objection largely lifts in a disaster, and cell networks fail
   first. This is the highest-value cross-over item.
4. **Camp-level needs signalling, aggregate only** — "this camp needs water"
   as a facility-level status, never a per-person need. Directly attacks
   visibility bias: a camp nobody visits can still be loud on the map.
5. **Deployment profiles** — a *build/config-time* profile (not a user toggle)
   that sets the defaults which legitimately differ: alert sound on by default
   in a disaster deployment, off in a protest one; hotspot allowed vs. not.
   Must be server-attested per deployment, never client-flippable.

**Explicitly not doing:** the four items on the never-build list, and any
"AI triage of reports", which in a two-hour-half-life misinformation
environment adds a confident-sounding failure mode to a system whose whole
value is being checkable.

---

## 5. What was built alongside this document

`core/domain/sphere_standards.dart` computes, for any shelter/camp facility:

- **persons per latrine** from the camp's stated capacity and the number of
  mapped `toilet` facilities inside its radius;
- **people per water point** from mapped `water` facilities, banded between
  the two published figures (250 per tap, 500 per hand pump) because the
  facility model cannot record which. It does **not** claim litres per person:
  flow rate is not in the data model, and inventing that number would be
  exactly the kind of confident precision this document argues against.

It is deliberately conservative:

- it reports the **coverage it used** ("based on 6 mapped facilities within
  150 m") and never claims to be an audit — the map's coverage is partial by
  definition;
- with too little data it returns *unknown*, not *adequate*. Silence must
  never read as a pass;
- a latrine whose status is `out` or `closed` counts as **zero** — counting
  broken provision would turn a failing camp into a compliant one on paper;
- it adds **no** new data collection, no schema change and no permissions.

The point is not to grade camps. It is that "15,000 people, 6 latrines" should
be visible to the person standing in that camp with a phone, and to everyone
deciding where the next truck goes.

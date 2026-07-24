# Jantar Mantar Sahayata — Project Hub

Protest-support app: offline-first map of facilities (water/food/shelter/medical/safety) with capacity counts, crowdsourced updates verified before display, group layer on top of a public verified map. Flutter (Android-first → iOS → web). Long-term: worldwide protest map.

## How this doc system works
| File | Purpose | Update when |
|---|---|---|
| `CONTEXT.md` | Single source of truth: vision, decisions, constraints | Any decision changes |
| `PROJECT_MANAGEMENT.md` | Phases, epics, task board, definition of done | Start/end of every work session |
| `ARCHITECTURE.md` | Tech stack, data model, diagrams | Design changes |
| `SECURITY.md` | Threat model + hardening checklist | New feature or threat identified |
| `DECISIONS.md` | ADR log — why we chose what we chose | Every significant choice |
| `progress/PROGRESS.md` | Session-by-session build log | End of every session |

## Working agreement
1. Start each session: read `progress/PROGRESS.md` (last entry) + `PROJECT_MANAGEMENT.md` board.
2. Pick the top "Next up" task. One task at a time.
3. End each session: log what was done, what broke, what's next.
4. No feature merges without ticking its `SECURITY.md` checklist items.

## Current status
**App name:** CommonGround (ADR-12)
**Phase:** 1 — MVP core. Done: E1–E8 core loop (offline map · submit · sync · anonymous auth · admin verification queue · alerts · SOS). 33 tests green.
**Next task:** apply `supabase/` migration + dashboard setup (see `supabase/README.md`) → device smoke test → E9 i18n/accessibility

## Repo layout
```
/            docs (this hub)
/app         Flutter app (jantar_mantar_sahayata)
/supabase    backend-as-code (migrations, RLS, edge functions) — lands with E2/E5
```
Checks (from `app/`): `flutter analyze && dart run custom_lint && flutter test`

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
**Phase:** 0 — Foundation (docs done, Flutter scaffold next)
**Next task:** Confirm backend (Supabase recommended) → scaffold Flutter project

# Full ITS + games on HAMM-KA0 — status & next steps

**Date:** 2026-09-06 (built 2026-09-09/10) · **State:** ✅ DONE — full pack built + cut over; games play · **Node:** HAMM-KA0 (host 49 / octal 061)

## Result (2026-09-09/10)

- **Built** the full pack from source: `make out/pdp10-ka/rp03.2 EMULATOR=pdp10-ka BASICS=no MACSYMA=no`
  (the reduced golden was a `BASICS=yes` CI-style build — that's why it had no games). Took
  ~2h22m under emulation (`rc=0`, clean `SHUTDOWN COMPLETE`). MACSYMA skipped to save time/disk.
- **Cut over:** copied the fresh `out/pdp10-ka/rp03.*` into `systems/its-arpa51/`; HAMM-KA0 booted
  clean — **no "directories out of phase"** (a fresh single-build pack set is in-phase, unlike the
  borrowed `its` packs). Backup of the new pack: `its-arpa51/full-games-pack-20260909.tar.gz`.
- **Verified games on the pack** (build's own dir dump): `SYS3;TS ADVENT`, `SYS3;TS ZORK`,
  `GAMES;TS ADV350/ADV448/CHESS/CHESS2/OCM/TREK`, `GJD;SINE`+`SWR` (Spacewar), `CFS;MADADV SAVE`
  (MDL Zork), `SHRDLU;TS SHRDLU`, `GAMES;ELIZA`. **Colossal Cave confirmed playable** via `@L 49`
  → `:advent` (raw pipe; expect-based capture is flaky but the game runs).
- **Greeting baked into source (permanent):** `src/sysnet/telser.175` has the `KA` branch
  ("Kurt Hamm PiDP-10 - Columbia, South Carolina"); regenerated `sources.tape` so every future
  build includes it (verified: one `SYSNET;TELSER 175` in the tape, greeting present). Durable
  copy: `patches/telser-hamm-ka0-greeting.patch`.
  - **Gotcha fixed:** a stray `telser.175.pre-kurt-banner-*` backup in `src/sysnet/` was being
    tarred into `sources.tape` as a *duplicate* `SYSNET;TELSER`, which could clobber the greeting
    on the build disk. Keep source backups OUT of `src/` (moved to `~/its-src-backups/`).
- **Note:** the *currently running* pack was built just before the greeting fix, so `@L 49` still
  greets "Unknown ITS PDP-10" until either a re-apply or the next full rebuild picks up the baked-in
  telser.

---

**Original plan (2026-09-06) below, for reference.**

## Goal

Make HAMM-KA0 (the persistent ARPANET PiDP-10) run the **full ITS software set** — so the
legendary games/programs run *on the ARPANET node*, not just on the standalone `its` system.
Kurt's picks to land first: **Zork/Dungeon, Colossal Cave (Adventure), Spacewar, Eliza/Doctor,
MacHack chess.** (Spacewar + chess are Type-340 / Knight-TV *display* games — see
`docs/` display notes / memory `pidp10-display-access`; the others are text, playable over `@L 49`.)

## Current status — WORKING (do not panic)

HAMM-KA0 is **fully restored and on the net**: `@L 49` gives the real herald
("Kurt Hamm PiDP-10 - Columbia, South Carolina"), login works, greeting + persistence +
crash-safe boot all intact. **No data was lost.** It is running the *reduced* ITS pack, which
does everything except have the games.

## What we tried, and why it failed

**Attempt:** swap the full `its` system packs (`/opt/pidp10/systems/its/rp03.*`, which *do* have
the games) in under the HAMM-KA0 boot config. **Result: FAILED to boot.**

**Root cause (researched in the ITS source):** the `its` packs are **"directories out of phase"** —
their ITS generation/MDNUM stamps don't agree (that image was captured across an uneven save;
`src/its/src/system/salv.317:2745`). They boot fine on the *`its` system* because it uses the
**direct-disk READ IN** path, where the SALVAGER only *warns* and continues. But HAMM-KA0 must
boot via the **DSKDMP path** (`b ptr` → `L$n$ ITS IMPUS/61 $G`) — that is the only place the
host-061 identity (`IMPUS/61`) is injected — and that path runs the SALVAGER in **GOGO mode**,
which turns "out of phase" into the fatal `*** ERROR *** SYSTEM MAY NOT BE BROUGHT BACK UP` → DDT.
Confirmed inherent to the packs (failed even with the simple `ITS/IMPUS/61/$G` sequence, no
`L$n$`). DSKDMP loaders are byte-identical between systems; dpa order is identical. So a raw
pack-swap cannot give full-ITS **and** the ARPANET identity together.

## Chosen approach — REBUILD a fresh full pack from source

A **fresh build produces a consistent, in-phase pack** that boots via the DSKDMP path exactly like
the current reduced golden pack does. So: build a full pack (`BASICS=no` → games/Lisp/Zork/
Scheme/SHRDLU included), then drop the existing HAMM-KA0 config on top (host 061, greeting,
persistence, crash-safe boot, NCP→imp49). This is "the full ITS image as HAMM-KA0," done in a
way that actually boots as the node.

## What I learned about the build (so far)

- Build system: TCL-driven, driven by `/opt/pidp10/src/its/Makefile` (targets in `build/*.tcl`;
  `build.tcl` sources `misc/lisp/zork/scheme/shrdlu/...` when `BASICS!=yes`).
- Key env: `EMULATOR=pdp10-ka` (→ `MCHN=KA`), `BASICS` (`no`=full, default), `MACSYMA`
  (`yes` adds MACSYMA — huge; **skip for now**, not needed for the 5 games).
- Output: `out/pdp10-ka/rp03.*` (+ `ka-minsys.tape`, `minsrc.tape`, `sources.tape`, `reboot.tape`).
  Makefile target `out/pdp10-ka/rp03.2 rp03.3` is built from the tapes; a full build is a
  self-hosting bootstrap (ITS compiles itself under the SIMH KA10 — **expect it to take a long
  time on the Pi**; time a dry run before committing).
- The games' install targets (already located):
  - Adventure → `sys3;ts advent` (+ `games;ts adv350`, `games;ts adv448`)
  - Zork (MDL) → `sys;ts rbye` / link `sys1;ts zork`; "Not Zork"/Dungeon → `sys3;ts zork`
  - Spacewar (Knight TV) → `:lisp gjd;sine lisp`; Type-340 variant sources in `src/spcwar`
  - MacHack chess → `games;ts c` (340 display) / `games;ts ocm`; also `:chess`, `:chess2`, `:ckr`
  - Eliza/Doctor → `games/` (`eliza.(init)`, `doc.(init)`)

## PREREQUISITE — disk space (IMPORTANT)

Pi root is **93% full, ~982 MB free** (`/dev/mmcblk0p2`, 15 G card). A full build needs scratch
room and `out/` is already 729 MB. **Free space first.** Safe candidate: the now-redundant
pre-greeting pack backups (~330 MB), since the greeting is stable and we have both the live
working pack and the rollback tarball:

```
/opt/pidp10/src/its/out/pdp10-ka/rp03.{0,1,2,3}.pre-greeting-20260905   # ~330 MB, redundant
```
(Confirm with Kurt before deleting — his standing rule on deletions.)

## Next steps (resume checklist)

1. **Free disk** (≥ ~1.5 GB free recommended) — remove redundant pre-greeting backups and/or
   the alternate unused OS images (`its-arpa` old Civitae variant, etc.) after confirming.
2. **Find the exact build invocation** — read `src/its/README.md` + Makefile top target; likely
   `make` (or `make EMULATOR=pdp10-ka BASICS=no`) from `/opt/pidp10/src/its`. **Do NOT commit to
   /opt/pidp10 (Oscar upstream).**
3. **Timed dry run** of the build to learn duration + peak disk; report before committing.
4. **Build** the full `out/pdp10-ka/rp03.*` (BASICS=no, no MACSYMA).
5. **Verify the fresh pack in isolation** — boot a scratch instance (alt ports) via DSKDMP,
   confirm it comes up in-phase and `:advent` / `:lisp` work.
6. **Cut over HAMM-KA0**: back up current pack (already have `rollback-reduced-greeting-...tar.gz`),
   copy the fresh full packs into `systems/its-arpa51/`, keep the HAMM-KA0 `boot.pidp`.
7. **Re-apply the greeting** on the fresh pack (`SYSNET;TELSER` edit + `:MIDAS SYSBIN;TELSER…`,
   logged in — see `docs/persistence-crash-recovery.md` / host-identity notes).
8. **Verify end-to-end**: `@L 49` herald + login + `:advent`/`:zork`/Eliza (text), and Spacewar/
   chess on the Type 340 via `rpdp`/VNC; then a persistence + power-off crash-safe test.
9. **Update docs/memory/CHANGELOG.**

## Safety / rollback

- Working rollback: `/opt/pidp10/systems/its-arpa51/rollback-reduced-greeting-20260906.tar.gz`
  (60 MB — reduced+greeting packs + boot.pidp + dskdmp.rim). Restores current working state.
- Golden reduced packs: `/opt/pidp10/src/its/out/pdp10-ka/rp03.*` (pre-greeting).
- **Footgun learned:** never `cp` over `rp03.*` while the sim has them open — corrupts. Stop ALL
  sims first: `pkill -9 -f 'pdp10-ka-ncp-pidp'` (note `pgrep -x` fails — process name >15 chars).
  Then `screen -wipe` and relaunch exactly one:
  `cd /opt/pidp10/bin && screen -dmS pidp10 ./pdp10-ka-ncp-pidp /opt/pidp10/systems/its-arpa51/boot.pidp`.
- imp49 / cbridge / tv11 run in separate screens — leave them alone during sim restarts.

## Key facts

- Three ITS variants on the Pi: `its` (full, internet-NAT IMP), `its-arpa` (NCP, old Civitae
  host 198, stale), `its-arpa51` (**HAMM-KA0** — NCP, host 061, imp49, persistence, greeting).
- HAMM-KA0 boot: `systems/its-arpa51/boot.pidp` line 2 =
  `expect -p "DSKDMP" send "L\e1\eL\e2\eL\e3\eITS\rIMPUS/61\r\eG\r" ; continue`.
- dpa order (all variants): `dpa0=rp03.2 dpa1=rp03.3 dpa2=rp03.0 dpa3=rp03.1`.
- Pi access: `pi@100.105.230.31` (Tailscale, pw raspberry). Console: `telnet localhost 1025`
  (buffered). Network login test from droplet: `cd ~/arpanet/mini && NCP=ncp31 ./ncp-telnet -o 49`.

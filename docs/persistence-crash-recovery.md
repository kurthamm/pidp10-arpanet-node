# Persistent, crash-safe ITS on the PiDP-10 (HAMM-KA0 / host 49)

**Goal:** a *stable server you can modify* — install software / change config and have it
**persist**, and survive an abrupt **power-off** (pull the plug) without being hosed.

**Status:** ✅ built and validated 2026-09-06. A change made before a power-off (the login
banner) survived the crash; host 49 came back up on its own.

---

## The problem

Oscar's PiDP-10 `its-arpa51/boot.pidp` (our ARPANET ITS) **wipes the disk on every boot** —
line 20 copies the golden `rp03.*` packs back over the live ones:

```
!cp -a /opt/pidp10/src/its/out/pdp10-ka/rp03.[0-3] .../dskdmp.rim /opt/pidp10/systems/its-arpa51/
```

This is unique to `its-arpa51` — the stock `its`, `tops20`, `waits` systems all persist. That
line is the *only* reason changes didn't stick.

**But** you can't just delete that line: on a **power-off**, the sim dies mid-write and the ITS
pack is left "dirty." On the next boot, DSKDMP can't mount it and prints:

```
 DSKDMP
ITS
 PKNMTD          ← "file is on a pack that is NOT MOUNTED"
```

…and ITS never loads. So the disk that holds your changes is also the disk a crash corrupts.

## The fix — authentic ITS crash recovery

Real ITS survived crashes by running its **SALVAGER** on boot. The trick is that DSKDMP's
*auto*-mount fails for a crashed pack, but you can put the packs online **manually**, after
which ITS loads and its SALVAGER repairs the filesystem.

DSKDMP command primitives (from `system;dskdmp` source; `$` = ALTMODE/ESC):
- `S$`     — list pack IDs / directories (proves the pack is readable)
- `L$n$`   — **put disk `n` online** (re-mount a pack that failed auto-mount)

**Two changes to `its-arpa51/boot.pidp`:**

1. **Disable the per-boot reset** (persistence): comment out line 20 (`!cp -a … rp03 …`).

2. **Recovery boot** — put the disks online, then boot ITS. Change the DSKDMP `expect`
   (line 2) from `send "ITS\rIMPUS/61\r\eG\r"` to:

   ```
   expect -p "DSKDMP" send "L\e1\eL\e2\eL\e3\eITS\rIMPUS/61\r\eG\r" ; continue
   ```

   i.e. `L$1$ L$2$ L$3$` (mount the packs) → `ITS` (load) → `IMPUS/61` (set host # = octal
   061 = host 49) → `$G` (start). On start ITS runs **SALVAGER.317**, which reports the crash,
   repairs the packs, and comes up:

   ```
   $G
   SALVAGER.317
   CRASH; NO FILES, USER DIRECTORY DELETED
   KA ITS 1652  IN OPERATION
   ```

   (`L$0$` returns `FNF` and is skipped — disk 0 is already the auto-mounted boot pack;
   `L$1$ L$2$ L$3$` mount the rest. The `L$n$` are harmless on a clean boot.)

## What "no data loss" means here

Files **with content persist** through a crash — verified: the banner edit to `SYSNET;TELSER`
+ the rebuilt `SYSBIN;TELSER BIN` were intact after a power-off. The SALVAGER's
`USER DIRECTORY DELETED` only cleans up *empty / incomplete* directories left by the crash
(the standard ITS behaviour), not directories that hold saved files. You lose at most the last
few seconds of in-flight writes — never your saved work, and never a full rollback.

## Validation procedure (repeatable)

1. `@L 49` → confirm login. Make a change (e.g. edit + reassemble `TELSER`, or save a file).
2. Let ITS run ~30–40 s (so the change flushes to the packs).
3. **Power-off:** kill the sim hard (`pkill -9 -f pdp10-ka-ncp-pidp`) — simulates pulling the plug.
4. Restart the sim (the recovery `boot.pidp` runs): it puts the packs online, ITS SALVAGER
   repairs, ITS comes up.
5. `ncp-ping 49` replies and `@L 49` shows your change still present. ✅

## Files

- `configs/pi/boot.pi.arpa51.example` — includes the recovery `expect` and reset-disabled lines.
- Live file on the Pi: `/opt/pidp10/systems/its-arpa51/boot.pidp` (backups:
  `boot.pidp.pre-crashrec-20260906`, `boot.pidp.pre-persist-20260906`).

## Recovery / rollback

If a boot ever fails to salvage, the golden clean packs are preserved at
`/opt/pidp10/src/its/out/pdp10-ka/rp03.*` (and `rp03.*.pre-greeting-20260905`). Re-enabling
line 20 (the reset) restores the wipe-every-boot behaviour from a pristine pack.

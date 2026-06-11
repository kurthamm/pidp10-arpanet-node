# Front-Panel Boot Mapping

## Goal

Make a normal PiDP-10 front-panel boot selection start the ARPA51 profile without damaging the stock ITS profile.

## Selection file

PiDP-10 boot selections are mapped in:

```text
/opt/pidp10/systems/selections
```

Working mapping:

```text
0005    its-arpa51
```

Stock ITS remains available as:

```text
0001    its
```

## Required launcher behavior

The ARPA51 profile must use the NCP-capable KA10 simulator, not the stock KA simulator.

Patch `/opt/pidp10/bin/pdpcontrol.sh` so that when the selected profile is `its-arpa51`, it selects `pdp10-ka-ncp`:

```sh
if [ "$sel" = "its-arpa51" ]; then
    pidp_bin="pdp10-ka-ncp"
fi
```

## Boot behavior

`boot.pidp` should contain the same SIMH `expect` lines as `boot.pi`:

```simh
expect -p "DSKDMP" send "ITS\rIMPUS=\eG\r" ; continue
expect -p "DO YOU REALLY WANT THE SYSTEM TO GO DOWN?\r_" send "yc\c"
```

This makes front-panel boot deterministic once the profile is selected.

## Rollback

To return selection `0005` to another profile, edit `/opt/pidp10/systems/selections` and restore the prior mapping.

To restore stock ITS behavior, boot selection `0001`.

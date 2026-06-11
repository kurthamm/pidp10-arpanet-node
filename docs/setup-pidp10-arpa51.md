# Setup: PiDP-10 ARPA51 Profile

## Purpose

Create a separate ITS profile for the ARPANET host so the stock PiDP-10 boot profile remains intact.

The working profile name is:

```text
its-arpa51
```

## Prerequisites

- PiDP-10 software installed under `/opt/pidp10`.
- PDP-10/ITS source and build output available under `/opt/pidp10/src/its`.
- Lars Brinkhoff's NCP-capable KA10 simulator built and installed as:

```text
/opt/pidp10/bin/pdp10-ka-ncp-pidp
```

The stock KA10 binaries do not provide the required `set imp ncp` behavior. A plain NCP KA10 build may work on the network but leave the PiDP-10 front panel dark. Build with `PIDP10=1` so the simulator includes `ka10_pipanel.c` and the GPIO support files.


## Build the combined NCP + PiDP front-panel simulator

The ARPA51 profile needs one binary with both features:

- Lars' NCP support for `set imp ncp`.
- PiDP-10 GPIO/front-panel support.

Install the build dependency used by the PiDP panel code:

```sh
sudo apt-get update
sudo apt-get install -y libeditreadline-dev
```

In the Lars `ka10-simh` work tree, copy the PiDP GPIO helper sources from the stock PiDP-10 source tree and patch the makefile so `PIDP10=1` includes them:

```sh
cd /home/pi/work-ka10-simh-ncp
mkdir -p utils
cp -a /opt/pidp10/src/pidp10/src/utils/pinctrl utils/pinctrl
# Patch makefile: add PANELD/PIDPPANEL and include `${PIDPPANEL}` with `ka10_pipanel.c` when PIDP10=1.
make PIDP10=1 pdp10-ka
sudo cp -a BIN/pdp10-ka /opt/pidp10/bin/pdp10-ka-ncp-pidp
sudo chown pi:pi /opt/pidp10/bin/pdp10-ka-ncp-pidp
sudo chmod 6755 /opt/pidp10/bin/pdp10-ka-ncp-pidp
```

A correct build prints or contains these indicators:

```text
Use NCP protocol
PiDP-10 FP on
ka10_pipanel.c
GPIO chips:
```

## Create a separate profile

Create a profile directory:

```sh
sudo mkdir -p /opt/pidp10/systems/its-arpa51
```

Copy clean ITS build artifacts into it:

```sh
sudo cp -a /opt/pidp10/src/its/out/pdp10-ka/rp03.[0-3] \
  /opt/pidp10/src/its/out/pdp10-ka/dskdmp.rim \
  /opt/pidp10/systems/its-arpa51/
```

Use the stock ITS boot file as a starting point, then apply the ARPA51 changes shown in `configs/pi/boot.pi.arpa51.example`.

## Required monitor build choices

The ITS monitor for this profile must be built with NCP enabled and with the ARPANET host number set to `51` octal.

Important options:

```text
KAIMP==1
IMPUS==51
NCPP==1
```

`IMPUS==51` is octal host `051`, which is decimal host `41`.

## Boot automation

Use SIMH `expect` in the boot file, matching the hosted ARPANET hosts:

```simh
expect -p "DSKDMP" send "ITS\rIMPUS=\eG\r" ; continue
expect -p "DO YOU REALLY WANT THE SYSTEM TO GO DOWN?\r_" send "yc\c"
```

Do not rely on an external telnet-console script to type the DSKDMP commands after startup. That can race or drop bytes.

## Clean-pack restore

For a public/demo ARPANET host, restore clean packs at boot:

```simh
!cp -a /opt/pidp10/src/its/out/pdp10-ka/rp03.[0-3] /opt/pidp10/src/its/out/pdp10-ka/dskdmp.rim /opt/pidp10/systems/its-arpa51/
```

This mirrors the hosted simulation model. If you want persistent local ITS changes, remove this line and manage disk pack backups explicitly.

## Simulator IMP interface

The KA10 side must enable the IMP and use NCP mode:

```simh
set imp enabled
set imp ncp
at -u imp 20412:127.0.0.1:20411
```

The opposite endpoint is configured in IMP41.

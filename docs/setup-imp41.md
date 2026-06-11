# Setup: IMP41 Bridge

## Purpose

Run an H316 IMP simulator on the Pi as IMP41, then attach it to the ARPANET simulation over a stable UDP path.

## Pi-side IMP41 configuration

Use `configs/pi/imp41.simh.example` as the template.

Important parts:

```simh
set imp num=41
set mi1 enabled
attach -u mi1 11141:<CIVITAE_TAILSCALE_IP>:11262

set hi1 enabled
attach -u hi1 20411:127.0.0.1:20412
set hi1 convert
```

The modem/IMP link connects the Pi to the remote ARPANET simulation. The host interface connects IMP41 to the local KA10 simulator.

## ARPANET simulation side

On the simulation host, configure the corresponding IMP port to point at the Pi:

```simh
set mi2 enabled
attach -u mi2 11262:<PI_TAILSCALE_IP>:11141
```

The exact IMP and line number depend on the simulation topology. In the working deployment, this was attached to IMP62.

## Start IMP41

Use:

```sh
scripts/start-imp41.sh
```

The script starts the IMP under `screen` and avoids launching duplicates.

## Check the link

On the Pi:

```sh
ss -uanp | grep -E '11141|20411|20412'
```

Expected local host link:

```text
127.0.0.1:20411 <-> 127.0.0.1:20412
```

Expected remote link:

```text
<PI_TAILSCALE_IP>:11141 <-> <CIVITAE_TAILSCALE_IP>:11262
```

# Architecture

## Goal

Attach a physical PiDP-10 replica to an existing ARPANET simulation as a distinct host, without replacing one of the hosted simulated ITS machines.

The target host identity is:

- ARPANET host number: `41` decimal
- ARPANET host number: `051` octal
- IMP: `41`
- Host on IMP: host `0`
- ITS profile name: `its-arpa51`

## Data path

```text
web terminal user
  -> terminal web application
  -> ARPANET simulation host
  -> ncp-telnet client
  -> local simulated IMP mesh
  -> remote link on Civitae IMP62
  -> overlay UDP path
  -> Pi IMP41
  -> PiDP-10 KA10 simulator IMP interface
  -> ITS NCP TELSER
```

## Components

### ARPANET simulation side

The simulation side continues to run the existing IMP farm and hosted terminal stack. One IMP port is configured as a remote link to the home Pi.

In the working deployment, Civitae IMP62 used a remote modem/IMP interface pointed at the Pi's IMP41 UDP listener.

### Home Pi side

The Pi runs two relevant simulators:

- H316 IMP simulator as IMP41.
- KA10 simulator running ITS with NCP enabled.

The two simulators communicate locally over UDP:

```text
KA10 IMP interface 127.0.0.1:20412 <-> IMP41 host interface 127.0.0.1:20411
```

IMP41 communicates with the ARPANET simulation over the overlay network:

```text
IMP41 remote link local UDP 11141 <-> Civitae IMP62 remote UDP 11262
```

Use placeholders in published configs:

```text
<PI_TAILSCALE_IP>
<CIVITAE_TAILSCALE_IP>
```

## Why a separate ITS profile

Do not modify the stock PiDP-10 ITS profile directly. Create a separate profile such as:

```text
/opt/pidp10/systems/its-arpa51
```

This keeps normal PiDP-10 operation recoverable and makes the ARPANET configuration explicit.

## Why SIMH `expect` is used

The hosted ARPANET ITS hosts boot through SIMH `expect` rules in their simulator command files. The PiDP-10 ARPA profile should do the same.

This avoids race conditions caused by starting the simulator and then connecting to its console externally to type the DSKDMP boot sequence.

Correct boot automation:

```simh
expect -p "DSKDMP" send "ITS\rIMPUS=\eG\r" ; continue
expect -p "DO YOU REALLY WANT THE SYSTEM TO GO DOWN?\r_" send "yc\c"
```

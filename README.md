# PiDP-10 ARPANET Node

This repository documents how to attach a real PiDP-10 replica, running on a Raspberry Pi, to an existing `obsolescence/arpanet` simulation as an external ARPANET host.

The working model is:

```text
hosted web terminal
  -> Civitae ARPANET simulation
  -> remote IMP link
  -> Tailscale or equivalent overlay network
  -> home Raspberry Pi
  -> simulated IMP 41
  -> PiDP-10 KA10 ITS host 41 / octal 051
```

The result is that users can type `@L 41` in the hosted terminal and reach the PiDP-10 replica as ARPANET host `051`.

## What this repo is

- A deployment/integration guide for a real PiDP-10 replica.
- A set of sanitized scripts and config templates for reproducing the setup.
- A record of the working architecture, validation commands, and rollback procedure.

## What this repo is not

- It is not a fork of `obsolescence/arpanet`.
- It is not a replacement for the PiDP-10 software distribution.
- It does not include disk packs, private backups, passwords, or site-specific secrets.

## Key requirements

- A working PiDP-10 Raspberry Pi installation.
- Lars Brinkhoff's NCP-capable KA10 simulator rebuilt with PiDP-10 front-panel support and installed as `pdp10-ka-ncp-pidp`.
- A separate ITS profile for the ARPANET host, for example `/opt/pidp10/systems/its-arpa51`.
- A simulated H316 IMP on the Pi, configured as IMP `41`.
- A stable UDP path between the Pi IMP and the ARPANET simulation host. Tailscale is recommended.

## Documentation

- [Architecture](docs/architecture.md)
- [Setup: PiDP-10 ARPA51 profile](docs/setup-pidp10-arpa51.md)
- [Setup: IMP41 bridge](docs/setup-imp41.md)
- [Front-panel boot mapping](docs/front-panel-boot.md)
- [Validation](docs/validation.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Security and publishing notes](docs/security.md)

## Repository layout

```text
configs/
  civitae/     Sanitized snippets for the ARPANET simulation side
  pi/          Sanitized SIMH and PiDP config examples
scripts/       Reusable operational scripts
docs/          Reproducible setup and operations documentation
```

## Proven working behavior

The working deployment verified these layers:

1. PiDP-10 boots the separate `its-arpa51` profile.
2. ITS reports `KA ITS 1652` on its console or MTY terminal.
3. The Pi IMP and Civitae IMP have an established UDP path.
4. From Civitae, `ncp-ping 41` replies.
5. From the hosted terminal, `@L 41` reaches `TELNET to host 051` and displays the ITS greeting.

## Important design choice

Keep this work separate from the main ARPANET simulation repository. The ARPANET repository should contain general simulation fixes. This repository should contain home-lab PiDP-10 integration details.

## Relationship to the ARPANET project

This is a companion repository for the ARPANET reconstruction:

- Upstream project: https://github.com/obsolescence/arpanet
- Kurt's ARPANET fork: https://github.com/kurthamm/arpanet

The ARPANET fork contains simulation/web-terminal fixes. This repository contains the real PiDP-10 home-lab integration.

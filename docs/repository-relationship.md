# Repository Relationship

This work is intentionally split into two public repositories.

## `kurthamm/arpanet`

This is a fork of `obsolescence/arpanet`.

Use it for changes that belong to the ARPANET simulation itself:

- Hosted web terminal behavior.
- TIP command handling.
- Repeated connection cleanup.
- Hosted ITS host routing fixes.
- IMP topology changes that are generally useful.

This repository can produce small, reviewable upstream pull requests.

## `kurthamm/pidp10-arpanet-node`

This is a standalone companion repository.

Use it for the real PiDP-10 replica integration:

- Pi-side IMP41 configuration.
- PiDP-10 `its-arpa51` profile.
- Tailscale/overlay networking notes.
- Front-panel boot mapping.
- Validation and troubleshooting for host `41` / octal `051`.

This should not be a fork of `obsolescence/arpanet`, because it is not the same codebase. It is deployment/integration documentation for physical replica hardware.

## Connection between the two

The repositories should link to each other:

- The ARPANET fork should point users here for external PiDP-10 host integration.
- This repository should point users to the upstream ARPANET project and Kurt's tested fork.

Do not use a Git submodule unless the upstream maintainers request it.

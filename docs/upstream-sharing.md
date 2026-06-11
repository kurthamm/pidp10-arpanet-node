# Upstream Sharing Plan

## Goal

Make the work useful to ARPANET and PiDP-10 users without asking maintainers to merge a large, site-specific home-lab configuration.

## Recommended path

1. Keep `kurthamm/arpanet` public as the ARPANET simulation fork.
2. Keep `kurthamm/pidp10-arpanet-node` public as the companion PiDP-10 integration repo.
3. Open a concise issue or discussion on `obsolescence/arpanet` linking both repositories.
4. Post a concise message to the PiDP-10 Google Group.
5. Offer small pull requests only for generic fixes, not private deployment details.

## Good upstream PR candidates

- Hosted terminal cleanup fixes.
- Documentation for repeated `@L` usage.
- Robust `do.sh` behavior.
- General IMP remote-link documentation.

## Poor upstream PR candidates

- Private Tailscale IP addresses.
- Local Pi username/password assumptions.
- Full PiDP-10 disk packs.
- Site-specific boot selection preferences.

## Suggested issue text

```text
I have documented a working external PiDP-10 replica attached to the ARPANET simulation as host 41 / octal 051.

The work is split into two repositories:

- ARPANET fork with hosted-terminal fixes: https://github.com/kurthamm/arpanet
- PiDP-10 companion integration docs: https://github.com/kurthamm/pidp10-arpanet-node

The PiDP-10 repo is intentionally separate because it documents physical replica hardware, local IMP41 bridging, and overlay networking. I would appreciate feedback on whether any generic pieces should be turned into small upstream PRs.
```

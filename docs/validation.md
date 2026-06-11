# Validation

Validate the deployment in layers. Do not declare success based on only one symptom.

## 1. Verify the Pi is running ARPA51

On the Pi:

```sh
pgrep -af '^/opt/pidp10/bin/(pidp10|pdp10-ka|pdp10-ka-ncp)'
```

Expected:

```text
/opt/pidp10/bin/pdp10-ka-ncp-pidp /opt/pidp10/systems/its-arpa51/boot.pi
```

## 2. Verify front-panel-capable simulator startup

Capture the simulator hardcopy or console output. Expected startup indicators:

```text
Created blink_thread
PiDP-10 FP on
```

If ARPA51 is reachable but the physical lamps are dark, verify the process is using `pdp10-ka-ncp-pidp`, not a plain `pdp10-ka-ncp` binary.

## 3. Verify local ITS console

Connect to the KA10 console:

```sh
telnet localhost 1025
```

Expected signs:

```text
KA ITS 1652
Welcome to ITS!
Happy hacking!
```

The exact login greeting may include:

```text
Unknown ITS PDP-10
It's a lovely day to be a turist!
```

That greeting is normal for a generic ITS machine identity. It does not by itself identify the host.

## 4. Verify Pi-side UDP links

On the Pi:

```sh
ss -uanp | grep -E '11141|20411|20412'
```

Expected:

- Remote IMP link established on UDP `11141`.
- Local KA10-to-IMP41 host link established between `20411` and `20412`.

## 5. Verify NCP ping from the ARPANET simulation host

From the ARPANET simulation `mini` directory:

```sh
env NCP=ncp31 ./ncp-ping -c3 41
```

Expected:

```text
NCP PING host 051
Reply from host 051
```

## 6. Verify NCP TELNET from the ARPANET simulation host

From the ARPANET simulation `mini` directory:

```sh
env NCP=ncp31 ./ncp-telnet -c 41
```

Expected:

```text
TELNET to host 051.
```

A fully interactive session should display the ITS greeting.

## 7. Verify hosted terminal path

From the hosted terminal page:

```text
@L 41
```

Expected:

```text
TELNET to host 051.
Unknown ITS PDP-10
It's a lovely day to be a turist!
```

The proof of routing is `TELNET to host 051`, not the generic ITS greeting.

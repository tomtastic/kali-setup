# kali additional setup...
```
kali$ sudo systemctl enable ssh; sudo systemctl start ssh
```
```
local$ ssh-copy-id -i ~/.ssh/id_ed25519 kali@kali
local$ ssh -t kali "curl https://github.com/tomtastic/kali-setup/archive/refs/heads/main.zip -LO \
        && ln -sf . kali-setup-main \
        && unzip -o main.zip; rm kali-setup-main main.zip; ./kali-setup.sh"
```

 - tested against kali-linux-2021.2-vmware-amd64
 - apt will download about 600MB of additional packages (mainly seclists!)

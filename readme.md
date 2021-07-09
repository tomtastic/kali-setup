# kali setup...
```
kali$ sudo systemctl enable ssh
kali$ sudo systemctl start ssh
```
```
local$ ssh-copy-id -i ~/.ssh/id_ed25519 kali@kali
local$ ssh kali
```
```
kali$ curl https://github.com/tomtastic/kali-setup/archive/refs/heads/main.zip -LO \
        && ln -sf . kali-setup-main \
        && unzip -o main.zip; rm kali-setup-main main.zip; ./kali-setup.sh
```

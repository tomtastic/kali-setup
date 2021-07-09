#!/bin/bash

echo "[[ Init sudo ]]"
rm -f ~/readme.md
sudo -l >/dev/null || exit 1
echo ""

echo "[[ Set password ]]"
if [[ ! -f ~/.passwd_set ]]; then
    sudo passwd kali || exit 1
    touch ~/.passwd_set
fi
echo ""

echo "[[ Be in the home directory ]]"
cd ~kali || exit 1
echo ""

echo "[[ Remove crufty extra empty directories ]]"
rmdir Documents Downloads Music Pictures Public Templates Videos 2>/dev/null
echo ""

echo "[[ Copy dotfiles ]]"
DOTFILES=(
    "src/.gdbinit"
    "src/.gf"
    "src/.zshrc"
    "src/.tmux.conf"
    "src/.hushlogin"
)
for d in "${DOTFILES[@]}"; do
    cp -fpR "$d" ~/ 2>/dev/null
done
# We have an Apple keyboard for better or worse...
sudo cp -f src/default_keyboard /etc/default/keyboard 2>/dev/null
echo ""

echo "[[ Install packages ]]"
sudo dpkg --add-architecture i386
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    libarchive-zip-perl libc6-dev libc6-dbg:i386 libexempi-dev libexempi8 \
    libgdbm-dev libgdiplus libglib2.0-dev libc6-dbg libgmp3-dev \
    libimage-exiftool-perl libmcrypt4 libmhash2 libmime-charset-perl \
    libmpc-dev libposix-strptime-perl libreadline-dev libsombok3 libssl-dev \
    libunicode-linebreak-perl \
    ack aptitude cargo console-data console-setup evolution fonts-powerline \
    foremost gdb git gobuster golang httpie jq keyboard-configuration nodejs \
    npm powershell python3-dev python3-pip python3-setuptools redis-tools \
    rlwrap seclists steghide tmux
echo ""

echo "[[ System packages ]]"
sudo systemctl enable ssh.service
sudo systemctl enable postgresql
sudo service ssh start
sudo service postgresql start
sudo msfdb init
echo ""

echo "[[ Node packages - For Electron apps ]]"
sudo npm install -g asar
sudo npm install -g redis-dump
echo ""

echo "[[ Rust packages ]]"
cargo install feroxbuster
echo ""

echo "[[ Python packages ]]"
# - Install pip for Python2
curl https://bootstrap.pypa.io/get-pip.py -o src/get-pip.py
python3 src/get-pip.py
# - Install pip modules for Python3
python3 -m pip install --user stegoveritas black xortool enum==1.1.8
stegoveritas_install_deps
echo ""

echo "[[ Ruby packages ]]"
# - For stego in PNG files
sudo gem install zsteg
sudo gem install evil-winrm
echo ""

echo "[[ Golang packages ]]"
# - For cindex, csearch, cgrep (http://swtch.com/~rsc/regexp/regexp4.html)
go get -u github.com/google/codesearch/cmd/cindex
go get -u github.com/google/codesearch/cmd/csearch
go get -u github.com/google/codesearch/cmd/cgrep
# - nifty
go get -u github.com/ffuf/ffuf
go get -u github.com/tomnomnom/gf
GO111MODULE=on go get -u -v github.com/lc/gau
echo ""

echo "[[ Github projects ]]"
echo "[[ Github projects - GF - examples ]]"
svn export --force https://github.com/tomnomnom/gf/trunk/examples ~/.gf
echo "[[ Github projects - FZF ]]"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; ~/.fzf/install --completion --key-bindings --update-rc --no-bash --no-fish
echo "[[ Github projects - TMUX ]]"
(cd src && git clone https://github.com/samoshkin/tmux-config.git; ./tmux-config/install)
echo "[[ Github projects - RUSTSCAN ]]"
(cd src && curl -L https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb -O && sudo dpkg -i rustscan_2.0.1_amd64.deb)
echo "[[ Github projects - WEBSHELLS ]]"
(cd src && git clone https://github.com/xl7dev/WebShell.git)
echo "[[ Github projects - RSACTFTOOL ]]"
(cd src && git clone https://github.com/Ganapati/RsaCtfTool.git; cd RsaCtfTool && python3 -m pip install --user -r "requirements.txt")
echo "[[ Github projects - STEGSEEK ]]"
(cd src && wget https://github.com/RickdeJager/stegseek/releases/download/v0.5/stegseek_0.5-1.deb && sudo apt -y install ./stegseek_0.5-1.deb)
echo "[[ Github projects - VOLATILITY ]]"
# - Volatility (not v3) : eg. python vol.py -f <imagepath> windows.info
(cd src && git clone https://github.com/volatilityfoundation/volatility.git)
echo "[[ Github projects - TOBIAS HOLL tools (Team HXP) ]]"
(cd src && git clone https://gitlab.com/tobiasholl/traceheap)
(cd src && git clone https://gitlab.com/tobiasholl/ldmalloc)
echo "[[ Github projects - PWNDBG ]]"
(cd src && git clone https://github.com/pwndbg/pwndbg; cd pwndbg && ./setup.sh --user)
echo "[[ Github projects - Windows is strange ]]"
curl https://raw.githubusercontent.com/imurasheen/Extract-PSImage/master/Extract-Invoke-PSImage.ps1 -o src/win/Extract-Invoke-PSImage.ps1
echo "[[ Github projects - Malware analysis - Didier Stevens - oledump ]]"
(cd src && curl https://didierstevens.com/files/software/oledump_V0_0_60.zip -O && unzip oledump_V0_0_60.zip)
echo "[[ Github projects - Malware analysis - decalage2 - oletools ]]"
python3 -m pip install --user -U https://github.com/decalage2/oletools/archive/master.zip
echo ""

echo "[[ Misc crap for binwalk? ]]"
mkdir /tmp/unstuff && cd /tmp/unstuff && http -dF http://mirror.sobukus.de/files/grimoire/z-archive/stuffit520.611linux-i386.tar.gz
tar -xzf stuffit520.611linux-i386.tar.gz
sudo cp bin/unstuff /usr/local/bin/
cd /tmp && rm -rf unstuff
cd ~kali || exit
echo ""

echo "[[ Handy symlinks ]]"
ln -s /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt ~/med
sudo tar -xzf /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz -C /usr/share/seclists/Passwords/Leaked-Databases/
ln -s /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt ~/rock
echo ""

echo "[[ Done, login again pls ]]"
echo ""

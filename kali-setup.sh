#!/usr/bin/zsh

KALI_TZ="Europe/London"
LOG="/tmp/background_tasks.log"


function kali_setup() {
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
        "src/.zprofile"
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
        foremost gdb git gobuster golang httpie jq keyboard-configuration \
        powershell python3-dev python3-pip python3-setuptools redis-tools \
        rlwrap steghide sslsniff tmux zsh-syntax-highlighting \
        bpython python3-argcomplete python3-argh python3-blessings \
        python3-curtsies python3-cwcwidth python3-watchdog
    echo ""

    # Lets source the updated ZSH profile for useful paths, etc.
    source .zshrc

    # Refresh our credential cache timeout for another 15mins
    sudo -v

    echo "[[ System services ]]"
    sudo timedatectl set-timezone "$KALI_TZ"
    sudo systemctl enable ntp
    sudo systemctl start ntp
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
    sudo msfdb init
    echo ""

    echo "[[ Python packages ]]"
    # - Install pip for Python2
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o src/get-pip.py && python src/get-pip.py
    # - Install pip modules for Python3
    python3 -m pip config --user set global.upgrade-strategy eager
    python3 -m pip install --user \
        stegoveritas black xortool enum34==1.1.8 pwntools unicorn
    /home/kali/.local/bin/stegoveritas_install_deps
    echo ""

    echo "[[ Ruby packages ]]"
    # - For stego in PNG files
    sudo gem install zsteg
    sudo gem install evil-winrm
    sudo gem install rex-text
    echo ""

    echo "[[ Golang packages ]]"
    # - For cindex, csearch, cgrep (http://swtch.com/~rsc/regexp/regexp4.html)
    go get -u -v github.com/google/codesearch/cmd/cindex
    go get -u -v github.com/google/codesearch/cmd/csearch
    go get -u -v github.com/google/codesearch/cmd/cgrep
    # - nifty
    go get -u -v github.com/ffuf/ffuf
    go get -u -v github.com/tomnomnom/gf
    GO111MODULE=on go get -u -v github.com/lc/gau
    echo ""

    # Refresh our credential cache timeout for another 15mins
    sudo -v

    echo "[[ Github projects - GF - examples ]]"
    svn export --force https://github.com/tomnomnom/gf/trunk/examples ~/.gf
    echo "[[ Github projects - FZF ]]"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; ~/.fzf/install --completion --key-bindings --update-rc --no-bash --no-fish
    echo "[[ Github projects - TMUX ]]"
    (cd src && git clone https://github.com/samoshkin/tmux-config.git; ./tmux-config/install.sh)
    echo "[[ Github projects - Rustscan ]]"
    (cd src && curl -L https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb -O && sudo dpkg -i rustscan_2.0.1_amd64.deb)
    echo "[[ Github projects - WebShells ]]"
    (cd src && git clone https://github.com/xl7dev/WebShell.git)
    echo "[[ Github projects - Sublist3r ]]"
    (cd src && git clone https://github.com/aboul3la/Sublist3r.git)
    echo "[[ Github projects - ropstar ]]"
    (cd src && git clone https://github.com/xct/ropstar.git)
    echo "[[ Github projects - RsaCtfTool ]]"
    (cd src && git clone https://github.com/Ganapati/RsaCtfTool.git; cd RsaCtfTool && python3 -m pip install --user -r "requirements.txt")
    echo "[[ Github projects - stegseek ]]"
    (cd src && wget https://github.com/RickdeJager/stegseek/releases/download/v0.5/stegseek_0.5-1.deb && sudo apt -y install ./stegseek_0.5-1.deb)
    echo "[[ Github projects - creddump7 ]]"
    (cd src && git clone https://github.com/Neohapsis/creddump7.git)
    echo "[[ Github projects - xssmap ]]"
    (cd src && git clone https://github.com/Jewel591/xssmap.git)
    echo "[[ Github projects - carlospolop - linPEAS.sh ]]"
    (cd src && http --body -dF https://raw.githubusercontent.com/carlospolop/privilege-escalation-awesome-scripts-suite/master/linPEAS/linpeas.sh)
    echo "[[ Github projects - Volatility ]]"
    # - Volatility (not v3) : eg. python vol.py -f <imagepath> windows.info
    (cd src && git clone https://github.com/volatilityfoundation/volatility.git)
    # - Volatility (v3) : eg. python3 vol.py -f <imagepath> windows.info
    (cd src && git clone https://github.com/volatilityfoundation/volatility3.git)
    echo "[[ Github projects - TOBIAS HOLL tools (Team HXP) ]]"
    (cd src && git clone https://gitlab.com/tobiasholl/traceheap)
    (cd src && git clone https://gitlab.com/tobiasholl/ldmalloc)
    echo "[[ Github projects - pwndbg ]]"
    (cd src && git clone https://github.com/pwndbg/pwndbg; cd pwndbg && ./setup.sh --user)
    echo "[[ Github projects - Windows is strange ]]"
    curl https://raw.githubusercontent.com/imurasheen/Extract-PSImage/master/Extract-Invoke-PSImage.ps1 -o src/Extract-Invoke-PSImage.ps1
    echo "[[ Github projects - Malware analysis - Didier Stevens - oledump ]]"
    (cd src && curl https://didierstevens.com/files/software/oledump_V0_0_60.zip -O && unzip -f oledump_V0_0_60.zip)
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
    ln -s /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt ~/rock
    ln -s ~/.tmux/tmux.conf .tmux.conf
    echo ""

    echo "[[ Fix broken things ]]"
    # pwndbg installs enum34==1.10.0, which is broken, so reinstall a good version
    python3 -m pip install --user enum34==1.1.8
    echo ""
}


function bgtask_apt() {
    # Refresh our credential cache timeout for another 15mins
    sudo -v
    echo "[[ Backgrounded : Installing larger packages ]]"
    sudo DEBIAN_FRONTEND=noninteractive apt install -y -q --no-install-recommends nodejs npm seclists
    sudo tar -xzf /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz -C /usr/share/seclists/Passwords/Leaked-Databases/ 2>/dev/null
}


function bgtask_rust() {
    # Refresh our credential cache timeout for another 15mins
    sudo -v
    echo "[[ Backgrounded : Rust packages ]]"
    cargo install feroxbuster
}


function bgtask_node() {
    # Refresh our credential cache timeout for another 15mins
    sudo -v
    echo "[[ Backgrounded : Node packages - For Electron apps ]]"
    sudo npm install -g asar
    sudo npm install -g redis-dump
}


function bgtasks() {
    # These things take a long time (large downloads or compiling), so
    # we defer them to this stage which runs in the background
    bgtask_apt
    bgtask_node
    bgtask_rust
    echo "[[ FINISHED ]]"
}


# Sanity check
if [[ ! $(lsb_release -i 2>/dev/null) =~ "Kali" ]]; then
    echo "Only for Kali distributions!"
    exit 1
fi

# Options parsing
if [[ -z "$1" ]]; then
    # No arguments, run setup and background tasks
    kali_setup && (bgtasks > "$LOG" 2>&1 &)
elif [[ "$1" =~ "bgtasks" ]]; then
    # Run all the background tasks
    (bgtasks > "$LOG" 2>&1 &)
elif [[ "$1" =~ "apt" ]]; then
    # Run only the 'apt' background task
    (bgtask_apt > "$LOG".apt 2>&1 &)
elif [[ "$1" =~ "rust" ]]; then
    # Run only the 'rust' background task
    (bgtask_rust > "$LOG".rust 2>&1 &)
elif [[ "$1" =~ "node" ]]; then
    # Run only the 'node' background task
    (bgtask_node > "$LOG".node 2>&1 &)
elif [[ "$1" =~ "help" || "$1" == "-h" ]]; then
    echo "Usage: $0  [--bgtasks] | [--apt | --rust | --node]"
    exit 0
fi

sleep 5
if grep -q "Reading package lists..." "$LOG"; then
    echo "[[ Deferred tasks running in background ($LOG) ]]"
else
    echo "!! Deferred tasks not running, probably sudo auth timeout exceeded !!"
    echo "!! Re-try tasks with : $0 --bgtasks"
fi
echo "[[ Done, please login ]]"
echo ""

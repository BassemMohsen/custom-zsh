#
# A collection of useful commands and aliases
#

export PATH=$PATH:${HOME}/bin:/usr/local/bin

export EDITOR=vim

alias grep='grep --color=auto'

alias chx='chmod 755'
alias chr='chmod 644'

alias yolo="sudo"
alias svim="sudo vim"

alias gk='gitk --all .'
alias bbake='time bitbake -k'

alias nmap='nmap -v'

# Prints command history and finds a specific command if specified 
# Usage: showhist [command]
showhist () {
    history | grep -i "$1"
    return;
}

# Prints running processes and finds a specific process if specified 
# psg [process name]
psg () {
    ps aux | grep $1
}

# Prints available packages and finds a specific string if specified 
# Usage: showpkg [pkg]
showpkg () {
      apt-cache pkgnames | grep -i "$1" | sort | grep -i "$1"
      return;
}

# Prints dd progress every 2 seconds
# Usage: dd_progress <dd args>...
dd_progress() {
    set +m
    dd "$@" 2>&1 > /dev/null &
    DDPID=$!
    while kill -0 "$DDPID" &> /dev/null; do
        sleep 2
        kill -USR1 "$DDPID" &> /dev/null
    done
    set -m
}

# Find files with a specific string in their name. Ignore dot files. 
# Usage: fn <string> [dir]
fn() {
    DIR="."
    if [ -n $2 ]; then 
        DIR=$2
    fi
    find -L $DIR -iname "*$1*" -not -path '*/\.*' | grep --ignore-case --color=always "$1"
}

# Recursively search through files in directories to find a specific string in a file.
# Usage: fs <string> [dir]
fs() {
    DIR="."
    if [ -n $2 ]; then
        DIR=$2
    fi
    grep -Ri --color=always "$1" $DIR
}

# Perform local network ARP scan on a given interface.
# Usage: local_arp_scan <interface>
local_arp_scan() {
	sudo arp-scan --localnet --interface=$1
}

# Grep for a string in netstat.
# Usage: netstatg <string>
netstatg() {
    netstat | grep $1
}

# Start tcptrack on the given interface.
# Usage: tcptracki <interface>
tcptracki() {
    sudo tcptrack -f -i $1 
}

# Copy the current working directory to clipboard
# Usage: cbwd
cbwd() {
    if ! type xclip > /dev/null 2>&1; then
        echo "You must have xclip installed"
        return
    fi
    pwd | xclip -selection c
    echo "`pwd` copied to clipboard"
}

# Copy the current working directory to clipboard
# Usage: cbf <file>
cbf() {
    if ! type xclip > /dev/null 2>&1; then
        echo "You must have xclip installed"
        return
    fi

    cat "$1" | xclip -selection c
    echo "File $1 content copied to clipboard"
}

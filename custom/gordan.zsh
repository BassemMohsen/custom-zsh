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


showhist () {
  history | grep -i "$1"
  return;
}

psg () {
  ps aux | grep $1
}

showpkg () {
  apt-cache pkgnames | grep -i "$1" | sort | grep -i "$1"
  return;
}

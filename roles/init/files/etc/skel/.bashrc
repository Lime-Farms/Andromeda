###
# PATH
###

__join_PATH() {
  local path
  printf -v path %s: "$@"
  export PATH=${path%:}
}

__set_PATH() {
  local paths path

  paths=(
    "$HOME"/bin /usr/local/bin
    /usr/bin /bin /usr/sbin
    /usr/local/sbin /sbin
  )

  __join_PATH "${paths[@]}"
}

__add_PATH() {
  local path paths
  declare -A uniq_paths
  declare -a path_list=( )
  IFS=: read -ra paths <<< "$PATH"

  for path in "$@" "${paths[@]}"; do
    if [[ ! -v uniq_paths[$path] ]]; then
      uniq_paths[$path]=42
      path_list+=("$path")
    fi
  done

  __join_PATH "${path_list[@]}"
}

add_path() {
  __add_PATH "$@"
}

__set_PATH

###
# Environment
###

default_shopts=(
  nullglob extglob globstar
  hostcomplete cmdhist checkhash
  checkwinsize dotglob
)

shopt -s "${default_shopts[@]}"
ulimit -c unlimited

export EDITOR=nano
export PAGER=less
export LESSHISTFILE=-
export HISTCONTROL=ignoreboth
export SIMPLE_PROMPT=enable

if [[ -d ~/.rvm && -s ~/.rvm/scripts/rvm ]]; then
  . ~/.rvm/scripts/rvm
  add_path ~/.rvm/bin
fi

###
# Happy Holidays
###

read -r month day < <(date '+%m %d')

if (( 10#$month == 3 && 10#$day < 18 )); then
  if (( 17 - 10#$day == 0 )); then
    printf 'Happy Saint Patrick%ss day!\n' \'
  else
    printf 'Only %d days left until Saint Patrick%ss day!\n' "$(( 17 - 10#$day ))" \'
  fi

  holiday=🍀
elif (( 10#$month == 10 )); then
  if (( 31 - 10#$day == 0 )); then
    printf 'Have a spooky halloween!\n'
  else
    printf 'Only %d days left until Halloween!\n' "$(( 31 - 10#$day ))"
  fi

  holiday=🎃
elif (( 10#$month == 12 && 10#$day < 26 )); then
  if (( 25 - 10#$day == 0 )); then
    printf 'Merry Christmas!\n'
  else
    printf 'Only %d days left until Christmas!\n' "$(( 25 - 10#$day ))"
  fi

  holiday=🌲
fi

###
# prettyifiers
###

colorize() {
  printf '\001%s\002' "$(tput bold)" "$(tput setaf "$1")"
  printf %s "$2"
  printf '\001%s\002' "$(tput sgr0)"
}

red() {
  colorize 1 "$@"
}

green() {
  colorize 2 "$@"
}

yellow() {
  colorize 3 "$@"
}

blue() {
  colorize 4 "$@"
}

purple() {
  colorize 5 "$@"
}

if [[ -x /usr/bin/dircolors ]]; then
  if [[ -f ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi

###
# Prompt
###

setup-prompt() {
  tput sgr0

  if [[ -d .git ]]; then
    git_branch=" $(git branch --show-current)"
  else
    git_branch=
  fi
}

PROMPT_COMMAND=setup-prompt
PS1='\w$git_branch'

if [[ -v SSH_CLIENT ]]; then
  if [[ -v HOSTNAME ]]; then
    PS1+=' $HOSTNAME'
  else
    PS1+=' $(hostname)'
  fi
fi

if [[ -v holiday ]]; then
  PS1+=' $holiday '
else
  PS1+=' λ '
fi

###
# Completion
###

_ssh_hosts() {
  mapfile -t hosts < <(awk 'tolower($1) == "host" { print $2 }' ~/.ssh/config)
  mapfile -t COMPREPLY < <(compgen -W "${hosts[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
  return 0
}

complete -o default -F _ssh_hosts ssh scp ssh-copy-id sftp rsync

_make_targets() {
  local arg prev file targets

  if [[ -f makefile ]]; then
    file=makefile
  elif [[ -f Makefile ]]; then
    file=Makefile
  fi

  for arg in "${COMP_WORDS[@]}"; do
    if [[ $prev = -f ]]; then
      file=$arg
    elif [[ $arg = -f* ]]; then
      file=${arg#-f}
    fi

    prev=$arg
  done

  mapfile -t targets < <(
    awk '$1 ~ /:$/ && $1 !~ /^\./ { gsub(/:$/, "", $1); print $1 }' "$file"
  )

  mapfile -t COMPREPLY < <(compgen -W "${targets[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
}

complete -o default -F _make_targets make gmake

###
# wrappers
###

ls() {
  command ls --color=auto "$@"
}

grep() {
  command grep --color=auto "$@"
}

ll() {
  ls -AlF "$@"
}

###
# utilities
###

clbin() {
  tail -n +1 -- "$@" | curl -sSF 'clbin=<-' https://clbin.com
}

args() {
  local arg count
  printf 'total arguments: %d\n' "$#"

  for arg do
    printf 'argument %03d: %s\n' "$(( ++count ))" "$arg"
  done
}

:D() {
  printf ':D\n'
}

dadjoke() {
  curl -sSH "Accept: text/plain" https://icanhazdadjoke.com; echo
}

awk-find() {
  if (( $# > 1 )); then
    local find_in=${TO_FIND:-.} file pattern=$1 to_find=( )
 
    for file in "${@:2}"; do
      to_find+=(-name "$file" -o)
    done
 
    find "$find_in" -not -name . "(" "${to_find[@]::${#to_find[@]} - 1}" ")" -print0 |
      awk -F / -v RS="\0" "$pattern"
  fi
}

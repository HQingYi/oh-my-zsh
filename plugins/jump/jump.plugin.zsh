# Easily jump around the file system by manually adding marks
# marks are stored as symbolic links in the directory $MARKPATH (default $HOME/.marks)
#
# jump FOO: jump to a mark named FOO
# mark FOO: create a mark named FOO
# unmark FOO: delete a mark
# marks: lists all marks
#
export MARKPATH=$HOME/.marks

jump() {
  local target=$1 && shift
  cd -P "$MARKPATH/$target" 2>/dev/null || echo "No such mark: $1"
  if [ $# -gt 0 ]; then
    echo "with action: $@"
    $@
  fi
}

mark() {
	if [[ ( $# == 0 ) || ( "$1" == "." ) ]]; then
		MARK=$(basename "$PWD")
	else
		MARK="$1"
	fi
	if read -q \?"Mark $PWD as ${MARK}? (y/n) "; then
		mkdir -p "$MARKPATH"; ln -s "$PWD" "$MARKPATH/$MARK"
	fi
}

unmark() {
	rm -i "$MARKPATH/$1"
}

marks() {
  for link in $MARKPATH/(*|.*)(@); do
		local markname="$fg[cyan]${link:t}$reset_color"
		local markpath="$fg[blue]$(readlink $link)$reset_color"
		printf "%s\t" $markname
		printf "-> %s \t\n" $markpath
	done
}

_completemarks() {
  reply=($(find $MARKPATH -type l | sed -E 's/(.*)\/([_a-zA-Z0-9\.\-]*)$/\2/g'))
}
compctl -K _completemarks jump
compctl -K _completemarks unmark

_mark_expansion() {
	setopt extendedglob
	autoload -U modify-current-argument
	modify-current-argument '$(readlink "$MARKPATH/$ARG")'
}
zle -N _mark_expansion
bindkey "^g" _mark_expansion

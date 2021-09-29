# Store the parent shell's command line into the $BASH_ARGS array. 
read -r -a BASH_ARGS <<< "$(ps -p $$ -o args=)"

# Because macOS has bash < 4.2, we can't use the convenient '${array[-1]}'
# syntax. But, '${array[@]: -1:1}' is supported.
LAST_ARG="${BASH_ARGS[@]: -1:1}"

cd "$EMULATE_VAGRANT_PATH"
exec sudo vagrant ssh -c "$(cat "$LAST_ARG")"

# FISH_SHELL="/home/sobrien/.nix-profile/bin/fish"
# if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]; then
#     shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
#     exec $FISH_SHELL $LOGIN_OPTION
# fi
# Path to Fish shell from Home Manager
FISH_SHELL="/home/sobrien/.nix-profile/bin/fish"

# Only exec Fish if not already in Fish and not a subshell
if [[ -n "${PS1-}" && "$SHELL" != "$FISH_SHELL" && $(ps --no-header --pid=$PPID --format=comm) != "fish" ]]; then
    if [[ ${SHLVL} == 1 ]]; then
        LOGIN_OPTION=""
        [[ $(shopt -q login_shell && echo yes || echo no) == "yes" ]] && LOGIN_OPTION="--login"
        exec "$FISH_SHELL" $LOGIN_OPTION
    fi
fi


#!/usr/bin/env bash
set -eu

DEFAULT_SESSION="workspace"

DIRS=(
    "Documents/"
    "Documents/typst"
    "Documents/projects/coop"
    "Documents/projects/forks"
    "Documents/projects/lessons"
    "Documents/projects/personal"
    "Documents/projects/tests"
    "Documents/projects/work"
)

EXTRA=(
    ".config"
)


tmux_swap() {
    local session_name="$1"
    local path="$2"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-session -ds "$session_name" -c "$path"
    fi

    tmux switch-client -t "$session_name"
}

get_pick_list() {
    {
        echo "workspace"
        for d in "${DIRS[@]}"; do \
            find "$HOME/$d" -mindepth 1 -maxdepth 1 -type d 2>/dev/null; \
        done
        for d in "${EXTRA[@]}"; do \
            echo "$HOME/$d"; \
        done
    } \
    | sed "s|^$HOME/||" \
    | grep -Fvx -f <(printf '%s\n' "${DIRS[@]}") \
    | sort \
    | sk --border double
}

cmd_pick() {
    selected="$(get_pick_list)" || true

    [ "$selected" ] || exit 0

    local path session
    case "$selected" in
        "workspace")
            path="$HOME"
            session_name="$DEFAULT_SESSION"
            ;;
        *)
            path="$HOME/$selected"
            session_name="$(basename "$selected" | tr . _)"
            ;;
    esac
    tmux_swap "$session_name" "$path"
}


cmd_kill() {
    CURRENT="$(tmux display-message -p '#S')"
    target=$DEFAULT_SESSION

    [ "$CURRENT" == "$target" ] && exit 0

    tmux_swap "$target" "$HOME"

    tmux kill-session -t "$CURRENT"
}


case "${1:-pick}" in
    pick)
        cmd_pick
        ;;
    kill)
        cmd_kill
        ;;
    --help|-h|help)
        echo "Usage: $0 [pick|kill]"
        echo ""
        echo "  pick  - select workspace and switch/create tmux session"
        echo "  kill  - interactively select tmux session to kill"
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        echo "Usage: $0 [pick|kill]"
        exit 1
        ;;
esac

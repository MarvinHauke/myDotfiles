#!/usr/bin/env bash
# Claude Code status line -- pure bash, no external commands.
#
#   Opus 5 (1M) high │ session ██░░░░░░░░   7% 󰚰 4h50m (20:00) │ ctx ██░░░░░░░░   7% 65k/1M │ wk 20% 󰚰 5d18h
#
# Reads the status-line JSON payload on stdin. Fields used (Claude Code >= 2.1):
#   vim.mode (only with vim mode on), model.display_name, effort.level, fast_mode, thinking.enabled
#   context_window.{total_input_tokens,context_window_size}
#   rate_limits.five_hour|seven_day|spend_limit.{used_percentage,resets_at}
# resets_at is unix epoch seconds.
#
# Bar width adapts to the terminal: Claude Code exports the live COLUMNS of the
# parent terminal into this script's environment on every refresh, so the line is
# rendered twice -- once bare to measure the fixed text, then for real with the
# leftover width split between the bars.

IFS= read -r -d '' JSON

# ${#LINE} must count characters, not bytes (│ █ and the icons are 3-4 bytes each). Claude Code may
# start this script without a UTF-8 locale, which made the bars vanish far too early.
export LC_ALL=en_US.UTF-8

# ------------------------------------------------------------------ appearance
FULL='█'
EMPTY='░'
# Before reset countdowns. A Nerd Font icon (nf-md-update, U+F06B0): Ghostty's built-in font has it,
# while ↻ showed up as two replacement characters in Claude Code's status line.
RESET_ICON='󰚰'
BAR_MIN=3  # below this the bars are dropped rather than shrunk further
BAR_MAX=40 # never let a bar grow past this on a wide terminal

# Claude Code renders the status line with wrap:"truncate" inside its own layout,
# so the drawable width is COLUMNS minus the surrounding TUI chrome -- measured at
# 4-5 columns here. Reserve 5 so the tail never gets clipped to an ellipsis.
RIGHT_MARGIN=${CC_STATUSLINE_MARGIN:-5}

# _palette on|off -- 'off' blanks every escape so a render can be measured.
_palette() {
    if [[ $1 == on ]]; then
        local e=$'\033'
        RESET="$e[0m" DIM="$e[2m" BOLD="$e[1m" GREY="$e[90m"
        RED="$e[31m" GREEN="$e[32m" YELLOW="$e[33m" CYAN="$e[36m" MAGENTA="$e[35m"
        NORMAL_BLOCK="$e[1;30;43m" # bold black on yellow: impossible to miss
    else
        NORMAL_BLOCK=''

        RESET='' DIM='' BOLD='' GREY=''
        RED='' GREEN='' YELLOW='' CYAN='' MAGENTA=''
    fi
    SEP=" ${GREY}│${RESET} "
}

# ------------------------------------------------------------------ json bits
# Minimal extractors for the flat, machine-generated payload. Each sets V.

# _obj KEY JSON -- body of a nested object that itself contains no objects.
_obj() {
    local re="\"$1\"[[:space:]]*:[[:space:]]*\{([^{}]*)\}"
    [[ $2 =~ $re ]] && V=${BASH_REMATCH[1]} && return 0
    V=''
    return 1
}

# _num KEY JSON -- integer or decimal number, kept as text.
_num() {
    local re="\"$1\"[[:space:]]*:[[:space:]]*(-?[0-9]+(\.[0-9]+)?)"
    [[ $2 =~ $re ]] && V=${BASH_REMATCH[1]} && return 0
    V=''
    return 1
}

# _str KEY JSON -- string value, no escape handling needed here.
_str() {
    local re="\"$1\"[[:space:]]*:[[:space:]]*\"([^\"]*)\""
    [[ $2 =~ $re ]] && V=${BASH_REMATCH[1]} && return 0
    V=''
    return 1
}

# _bool KEY JSON -- true/false.
_bool() {
    local re="\"$1\"[[:space:]]*:[[:space:]]*(true|false)"
    [[ $2 =~ $re ]] && V=${BASH_REMATCH[1]} && return 0
    V=''
    return 1
}

# ------------------------------------------------------------------ formatting

# _heat PCT -- colour for a fill percentage (integer part is enough).
_heat() {
    local p=${1%%.*}
    if ((p >= 90)); then
        V=$RED
    elif ((p >= 75)); then
        V=$YELLOW
    elif ((p >= 50)); then
        V=$CYAN
    else
        V=$GREEN
    fi
}

# _eta_heat SECONDS -- colour for a countdown: the closer the reset, the louder.
_eta_heat() {
    local s=$1
    if ((s <= 900)); then
        V=$RED
    elif ((s <= 3600)); then
        V=$YELLOW
    else
        V=$CYAN
    fi
}

# _bar PCT -- coloured progress bar of BAR_WIDTH cells, empty when there is no
# room for one. Counts itself in BARS so the caller can size the next render.
_bar() {
    local p=${1%%.*} filled rest pad colour
    ((p < 0)) && p=0
    ((p > 100)) && p=100
    ((BARS++))

    V=''
    ((BAR_WIDTH > 0)) || return

    filled=$(((p * BAR_WIDTH + 50) / 100))
    rest=$((BAR_WIDTH - filled))
    _heat "$1"
    colour=$V

    V=''
    if ((filled > 0)); then
        printf -v pad '%*s' "$filled" ''
        V="$colour${pad// /$FULL}"
    fi
    if ((rest > 0)); then
        printf -v pad '%*s' "$rest" ''
        V+="$GREY${pad// /$EMPTY}"
    fi
    V+=$RESET
}

# _pct PCT [bold] -- right-aligned, colour-coded percentage.
_pct() {
    local txt=$1 colour emphasis=''
    [[ $txt == *.0 ]] && txt=${txt%.0}
    [[ $2 == bold ]] && emphasis=$BOLD
    _heat "$1"
    colour=$V
    printf -v txt '%4s' "$txt%"
    V="$colour$emphasis$txt$RESET"
}

# _tokens N -- 53894 -> 54k, 1000000 -> 1M.
_tokens() {
    local n=$1
    if ((n >= 1000000)); then
        if ((n % 1000000 == 0)); then
            V="$((n / 1000000))M"
        else
            V="$((n / 1000000)).$(((n % 1000000) / 100000))M"
        fi
    elif ((n >= 1000)); then
        V="$(((n + 500) / 1000))k"
    else
        V="$n"
    fi
}

# _until SECONDS -- compact countdown.
_until() {
    local s=$1 d h m
    ((s <= 0)) && {
        V="now"
        return
    }
    d=$((s / 86400))
    h=$((s % 86400 / 3600))
    m=$((s % 3600 / 60))
    if ((d)); then
        V="${d}d${h}h"
    elif ((h)); then
        printf -v V '%dh%02dm' "$h" "$m"
    elif ((m)); then
        V="${m}m"
    else
        V="<1m"
    fi
}

# _clock TS -- local wall-clock time of a reset, with weekday if not today.
_clock() {
    local today then
    printf -v today '%(%j)T' -1
    printf -v then '%(%j)T' "$1"
    if [[ $today == "$then" ]]; then
        printf -v V '%(%H:%M)T' "$1"
    else
        printf -v V '%(%a %H:%M)T' "$1"
    fi
}

# ------------------------------------------------------------------ segments

add() { [[ -n $1 ]] && PARTS+=("$1"); }

# Vim mode: a loud block in NORMAL (the input cursor looks the same in both modes),
# a quiet tag in INSERT, VISUAL in magenta. Absent when vim mode is off.
seg_vim() {
    local block
    _obj vim "$JSON" || return
    block=$V
    _str mode "$block" || return
    case $V in
    NORMAL) add "$NORMAL_BLOCK NORMAL $RESET" ;;
    INSERT) add "${GREY}insert$RESET" ;;
    *) add "$BOLD$MAGENTA$V$RESET" ;;
    esac
}

# Model, effort level and mode flags.
seg_model() {
    local out name model effort thinking
    _obj model "$JSON" || return
    model=$V
    _str display_name "$model" || _str id "$model" || V='?'
    name=${V/ context)/)} # "Opus 5 (1M context)" -> "Opus 5 (1M)"
    out="$BOLD$MAGENTA$name$RESET"

    if _obj effort "$JSON"; then
        effort=$V
        _str level "$effort" && out+=" $DIM$V$RESET"
    fi

    _bool fast_mode "$JSON" && [[ $V == true ]] && out+=" $YELLOW↯fast$RESET"

    if _obj thinking "$JSON"; then
        thinking=$V
        _bool enabled "$thinking" && [[ $V == false ]] && out+=" $GREY(no think)$RESET"
    fi

    add "$out"
}

# Context window: bar, bold percentage and absolute token counts.
seg_context() {
    local used size pct out
    _num total_input_tokens "$JSON" || return
    used=${V%%.*}
    _num context_window_size "$JSON" || return
    size=${V%%.*}
    ((size > 0)) || return

    pct=$(((used * 100 + size / 2) / size))
    _bar "$pct"
    out="${DIM}ctx$RESET"
    [[ -n $V ]] && out+=" $V"
    _pct "$pct" bold
    out+=" $V"
    _tokens "$used"
    out+=" $GREY$V/"
    _tokens "$size"
    out+="$V$RESET"

    add "$out"
}

# A rate-limit window: bar, percentage, countdown and reset wall-clock.
# Pass 'emphasize' as the third argument to make the countdown bold and colour it
# by urgency instead of leaving it dim.
seg_window() {
    local key=$1 label=$2 emphasis=$3 block pct out left colour ts
    # The window blocks are leaf objects, so match them against the whole payload.
    _obj "$key" "$JSON" || return
    block=$V

    _num used_percentage "$block" || return
    pct=$V

    _bar "$pct"
    out="$DIM$label$RESET"
    [[ -n $V ]] && out+=" $V"
    _pct "$pct"
    out+=" $V"

    if _num resets_at "$block"; then
        ts=${V%%.*}
        left=$((ts - EPOCHSECONDS))
        if [[ $emphasis == emphasize ]]; then
            _eta_heat "$left"
            colour="$V$BOLD"
        else
            ((left <= 900)) && colour=$RED || colour=$GREY
        fi
        _until "$left"
        out+=" $colour$RESET_ICON $V$RESET"
        if ((!COMPACT)); then # the wall-clock time is the first thing to go when space is tight
            _clock "$ts"
            out+=" $GREY($V)$RESET"
        fi
    fi

    add "$out"
}

# Weekly total: percentage and countdown only, to keep the line short.
seg_week() {
    local block pct out
    _obj seven_day "$JSON" || return
    block=$V
    _num used_percentage "$block" || return
    pct=$V

    _pct "$pct"
    out="${DIM}wk$RESET $V"

    if _num resets_at "$block"; then
        _until $((${V%%.*} - EPOCHSECONDS))
        out+=" $GREY$RESET_ICON $V$RESET"
    fi

    add "$out"
}

# ------------------------------------------------------------------ render

# render -- builds LINE from all segments, counting the bars drawn in BARS.
render() {
    PARTS=()
    BARS=0

    seg_vim
    seg_model
    seg_window five_hour 'session' emphasize # /usage calls five_hour "Current session"
    seg_context
    seg_window spend_limit '$'
    seg_week

    LINE=''
    local p
    for p in "${PARTS[@]}"; do
        [[ -n $LINE ]] && LINE+="$SEP"
        LINE+="$p"
    done
}

# Pass 1: no colours and no bar cells, purely to measure the fixed text. With a
# UTF-8 locale ${#LINE} counts characters, which is what we want here.
# If the bars don't fit, measure again without the reset clock times (COMPACT) before giving them up.
_palette off
BAR_WIDTH=0
for COMPACT in 0 1; do
    render
    fixed=${#LINE}
    bars=$BARS
    room=$((${COLUMNS:-100} - fixed - RIGHT_MARGIN - bars))
    ((bars == 0 || room >= bars * BAR_MIN)) && break
done

# Split whatever is left between the bars. Each bar also costs a leading space,
# so a bar occupies BAR_WIDTH + 1 columns. Too cramped for even BAR_MIN cells
# means dropping the bars entirely rather than letting the line overflow.
BAR_WIDTH=0
if ((bars > 0)); then
    if ((room >= bars * BAR_MIN)); then
        BAR_WIDTH=$((room / bars))
        ((BAR_WIDTH > BAR_MAX)) && BAR_WIDTH=$BAR_MAX
    fi
fi

# Pass 2: the real thing.
_palette on
render
printf '%s' "$LINE"


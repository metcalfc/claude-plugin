# Advanced fzf Patterns

## Ripgrep Launcher

Use ripgrep as the search engine, fzf as the selector with file preview:

```bash
rg --color=always --line-number --no-heading --smart-case "${*:-}" |
  fzf --ansi \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --delimiter : \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
      --bind 'enter:become(vim {1} +{2})'
```

## Interactive Ripgrep (Reload on Keystroke)

fzf in `--disabled` mode with ripgrep running on every keystroke:

```bash
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"
fzf --ansi --disabled --query "${1:-}" \
    --bind "start:reload:$RG_PREFIX {q} || true" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --delimiter : \
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind 'enter:become(vim {1} +{2})'
```

## Bidirectional Mode Toggle (Ripgrep <-> fzf)

Switch between ripgrep mode (search as you type) and fzf mode (fuzzy filter):

```bash
rm -f /tmp/rg-fzf-{r,f}
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"
fzf --ansi --disabled --query "${1:-}" \
    --bind "start:reload($RG_PREFIX {q})+unbind(ctrl-r)" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(fzf> )+enable-search+rebind(ctrl-r)+transform-query(echo {q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f)" \
    --bind "ctrl-r:unbind(ctrl-r)+change-prompt(ripgrep> )+disable-search+reload($RG_PREFIX {q} || true)+rebind(change,ctrl-f)+transform-query(echo {q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r)" \
    --prompt 'ripgrep> ' \
    --delimiter : \
    --header 'CTRL-R: ripgrep mode / CTRL-F: fzf mode' \
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind 'enter:become(vim {1} +{2})'
```

## State Toggle via Prompt

Use `$FZF_PROMPT` to track mode state and `transform` to branch conditionally:

```bash
fd --type file |
  fzf --prompt 'Files> ' \
      --header 'CTRL-T: Switch between Files/Directories' \
      --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ Files ]] &&
        echo "change-prompt(Files> )+reload(fd --type file)" ||
        echo "change-prompt(Directories> )+reload(fd --type directory)"' \
      --preview '[[ $FZF_PROMPT =~ Files ]] && bat --color=always {} || tree -C {}'
```

## Data Source Switching

Multiple keybindings to switch between different data sources:

```bash
find * | fzf --prompt 'All> ' \
    --header 'CTRL-D: Directories / CTRL-F: Files' \
    --bind 'ctrl-d:change-prompt(Directories> )+reload(find * -type d)' \
    --bind 'ctrl-f:change-prompt(Files> )+reload(find * -type f)'
```

## Live Reload with Header

Process manager with auto-refresh:

```bash
(date; ps -ef) |
  fzf --bind='ctrl-r:reload(date; ps -ef)' \
      --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
      --preview='echo {}' --preview-window=down,3,wrap \
      --layout=reverse --height=80% | awk '{print $2}' | xargs kill -9
```

## Preview Layout Cycling

Cycle through preview layouts on each keypress:

```bash
--bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)'
```

First press: 80% at bottom. Second: hidden. Third: back to default.

## Log Tailing

Preview window with follow mode for streaming output:

```bash
--preview-window follow
--preview 'tail -f /var/log/something'
```

## Design Patterns Summary

| Pattern | Key Technique | Use When |
|---------|--------------|----------|
| Ripgrep launcher | `--disabled` + `reload` on `change` | Search file contents interactively |
| State toggle | `transform` + `$FZF_PROMPT` | Switch between modes |
| Mode switching | `unbind`/`rebind` | Prevent invalid state transitions |
| Select-then-open | `become(CMD)` | Open file/resource after selection |
| Live reload | `reload` on `ctrl-r` or `start` | Dynamic data that changes |
| Preview cycling | `change-preview-window(A\|B\|C)` | Multiple preview layouts |
| Scroll to match | `+{2}+3/3,~3` | Preview scrolled to relevant line |

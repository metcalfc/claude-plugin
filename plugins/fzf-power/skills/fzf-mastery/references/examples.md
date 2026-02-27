# Real-World fzf Recipes

## Git

### Branch Checkout

```bash
git branch --all --color=always | grep -v HEAD |
  fzf --ansi --layout=reverse --border \
      --preview 'git log --oneline --graph --color=always $(echo {} | sed "s/.* //" | sed "s#remotes/[^/]*/##") -- | head -30' \
      --header 'Select branch' |
  sed "s/.* //" | sed "s#remotes/[^/]*/##" | xargs git checkout
```

### Commit Browser

```bash
git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" |
  fzf --ansi --no-sort --reverse --tiebreak=index \
      --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1)' \
      --preview-window=right,60% \
      --bind 'ctrl-s:toggle-sort' \
      --header 'CTRL-S: toggle sort'
```

### Interactive Stash

```bash
git stash list --color=always |
  fzf --ansi --layout=reverse --border \
      --preview 'git stash show -p --color=always $(echo {} | cut -d: -f1)' \
      --header 'Enter: apply / CTRL-D: drop' \
      --bind 'enter:become(git stash apply $(echo {} | cut -d: -f1))' \
      --bind 'ctrl-d:execute(git stash drop $(echo {} | cut -d: -f1))+reload(git stash list --color=always)'
```

### Changed Files

```bash
git diff --name-only |
  fzf --layout=reverse --border \
      --preview 'git diff --color=always {}' \
      --preview-window=right,70% \
      --bind 'enter:become(vim {})'
```

## Processes

### Kill Process

```bash
ps -ef | sed 1d |
  fzf -m --layout=reverse --border \
      --header-lines=0 \
      --header 'Select processes to kill (TAB for multi-select)' \
      --preview 'echo {} | awk "{print \$2}" | xargs ps -p 2>/dev/null | tail -1' \
      --preview-window=down,3,wrap |
  awk '{print $2}' | xargs kill -9
```

### Port Finder

```bash
lsof -iTCP -sTCP:LISTEN -P -n | sed 1d |
  fzf --layout=reverse --border \
      --header-lines=0 \
      --header 'Listening ports — Enter to kill' \
      --preview 'echo {} | awk "{print \$2}" | xargs ps -p' \
      --preview-window=down,4,wrap |
  awk '{print $2}' | xargs kill -9
```

## Docker

### Container Management

```bash
docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}' |
  fzf --layout=reverse --border --header-lines=1 \
      --header 'Enter: logs / CTRL-S: start / CTRL-X: stop / CTRL-D: rm' \
      --preview 'docker inspect $(echo {} | awk "{print \$1}") | jq ".[0] | {State, Config: {Image: .Config.Image, Cmd: .Config.Cmd}}"' \
      --bind 'enter:execute(docker logs --tail 100 -f $(echo {} | awk "{print \$1}"))' \
      --bind 'ctrl-s:execute-silent(docker start $(echo {} | awk "{print \$1}"))+reload(docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}")' \
      --bind 'ctrl-x:execute-silent(docker stop $(echo {} | awk "{print \$1}"))+reload(docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}")' \
      --bind 'ctrl-d:execute-silent(docker rm $(echo {} | awk "{print \$1}"))+reload(docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}")'
```

### Image Browser

```bash
docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}' |
  fzf --layout=reverse --border --header-lines=1 \
      --preview 'docker history --no-trunc $(echo {} | awk "{print \$1\":\" \$2}")' \
      --preview-window=down,40%
```

## Files

### File Browser with bat Preview

```bash
fd --type file --hidden --exclude .git |
  fzf --layout=reverse --border \
      --preview 'bat --color=always --style=numbers {}' \
      --preview-window=right,60% \
      --bind 'enter:become(vim {})'
```

### Grep and Open

```bash
rg --files-with-matches --no-messages "$1" |
  fzf --layout=reverse --border \
      --preview "rg --color=always --context 3 '$1' {}" \
      --preview-window=right,60% \
      --bind 'enter:become(vim {})'
```

## System

### Man Page Browser

```bash
man -k . 2>/dev/null | sort |
  fzf --layout=reverse --border \
      --prompt='man> ' \
      --preview 'echo {} | awk "{print \$1}" | tr -d "()" | xargs man 2>/dev/null | head -80' \
      --preview-window=right,60%,wrap |
  awk '{print $1}' | tr -d '()' | xargs man
```

### Environment Variables

```bash
env | sort |
  fzf --layout=reverse --border \
      --delimiter='=' \
      --preview 'echo {2..}' \
      --preview-window=down,3,wrap \
      --header 'Environment variables'
```

### SSH Host Picker

```bash
grep -E '^Host\s' ~/.ssh/config | awk '{print $2}' | grep -v '\*' |
  fzf --layout=reverse --border \
      --preview 'grep -A5 "Host {}" ~/.ssh/config' \
      --preview-window=right,40% \
      --header 'Select SSH host' \
      --bind 'enter:become(ssh {})'
```

## Tmux

### Session Switcher

```bash
tmux list-sessions -F "#{session_name}" 2>/dev/null |
  fzf --layout=reverse --border \
      --preview 'tmux capture-pane -t {} -p 2>/dev/null | tail -20' \
      --header 'Select tmux session' |
  xargs tmux switch-client -t
```

## Kubernetes

### Pod Browser

```bash
kubectl get pods --all-namespaces |
  fzf --layout=reverse --border --header-lines=1 \
      --prompt "$(kubectl config current-context)> " \
      --header 'Enter: exec / CTRL-O: logs / CTRL-R: reload' \
      --bind 'start,ctrl-r:reload:kubectl get pods --all-namespaces' \
      --bind 'enter:execute:kubectl exec -it --namespace {1} {2} -- bash' \
      --bind 'ctrl-o:execute:kubectl logs --tail=100 --namespace {1} {2} | less' \
      --preview 'kubectl logs --tail=20 --namespace {1} {2} 2>/dev/null' \
      --preview-window=up,follow
```

## Homebrew

### Install with Preview

```bash
brew formulae |
  fzf -m --layout=reverse --border \
      --preview 'brew info {}' \
      --preview-window=right,60%,wrap \
      --header 'Select formulae to install (TAB for multi)' |
  xargs brew install
```

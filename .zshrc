clear
# if which pokemon-colorscripts &>/dev/null; then
#     pokemon-colorscripts --no-title -s -r
# fi

export ZSH="$HOME/.oh-my-zsh"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)
source $ZSH/oh-my-zsh.sh
eval "$(oh-my-posh --init --shell zsh --config $(brew --prefix oh-my-posh)/themes/kushal.omp.json)"


# Pokemon Fastfetch display
pokemon-fastfetch() {
  # Create a temporary directory for our files
  TEMP_DIR=$(mktemp -d)
  CONFIG_FILE="$TEMP_DIR/fastfetch_config.json"
  
  # Create a fastfetch config with the pokemon-colorscript as logo
  cat > "$CONFIG_FILE" << 'EOF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "file",
    "source": "/tmp/pokemon_logo.txt",
    "width": 33,
    "padding": {
      "right": 4
    }
  },
  "display": {
    "separator": "  ",
    "size": {
      "binaryPrefix": "si"
    }
  },
  "modules": [
        {
            "type": "custom",
            "format": "┌────────────────────────────────────────────────────────┐"
        },
        {
            "type": "os",
            "key": "  󰀶 OS",
            "keyColor": "red"
        },
        {
            "type": "bios",
            "key": "  󱢌 Bios",
            "keyColor": "red"
        },
        {
            "type": "kernel",
            "key": "   Kernel",
            "keyColor": "red"
        },
        {
            "type": "packages",
            "key": "  󰏗 Packages",
            "keyColor": "green"
        },
        {
            "type": "display",
            "key": "  󰹑 Display",
            "keyColor": "green"
        },
        {
            "type": "wm",
            "key": "   WM",
	        "format": "{2}",
            "keyColor": "yellow"
        },
        {
            "type": "terminalfont",
            "key": "   Font",
            "keyColor": "yellow"
        },
        {
            "type": "terminal",
            "key": "   Terminal",
            "format": "{1}",
            "keyColor": "yellow"
        },
        "break",
        {
            "type": "colors",
            "paddingLeft": 2,
            "symbol": "circle"
        },
        "break",
        {
            "type": "cpu",
            "format": "{1}",
            "key": "   CPU",
            "keyColor": "blue"
        },
        {
            "type": "gpu",
            "format": "{1} {2} {12} Ghz",
            "key": "  󰋵 GPU",
            "keyColor": "blue"
        },
        {
            "type": "memory",
            "key": "  󰀚 Memory",
            "keyColor": "blue"
        },    
        {
            "type": "shell",
            "format": "{1} v{4}",
            "key": "  󰘳 Shell",
            "keyColor": "magenta"
        },
        {
            "type": "disk",
            "key": "  󰀚 Disk",
            "keyColor": "magenta"
        },  
        {
            "type": "localip",
            "format": "{4} {1}",
            "key": "  󰘳 Network",
            "keyColor": "magenta"
        }, 
        {
            "type": "command",
            "key": "  󱦟 OS Age ",
            "keyColor": "red",
            "text": "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days"
        },
        {
            "type": "uptime",
            "key": "  󱫐 Uptime ",
            "keyColor": "red"
        },
        {
            "type": "host",
            "key": "   Machine",
            "format": "{name}{?vendor} ({vendor}){?}",
            "keyColor": "red"
        },
        {
            "type": "custom",
            "format": "└────────────────────────────────────────────────────────┘"
        }
    ]
}
EOF

  # Generate the Pokemon sprite and save to /tmp for fastfetch to use as logo
  pokemon-colorscripts -r --no-title > /tmp/pokemon_logo.txt
  
  # Run fastfetch with our custom config
  fastfetch -c "$CONFIG_FILE"

  # Clean up
  rm -rf "$TEMP_DIR"
  # Keep the pokemon logo file for this session
}

# Run the function when starting a new shell
pokemon-fastfetch

alias cls='clear && pokemon-fastfetch'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gpo='git pull origin'
alias gl='git log'
alias gp='git push'
alias gr='git rebase'
alias gs='git status'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gph='git push origin head'
alias dn='nvm alias default'
alias udn='nvm use default'
alias yd='yarn dev'
alias ys='yarn start'
alias c='code .'
alias y='yarn'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
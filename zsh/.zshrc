# --- PLUGINS ---
# Cargamos los plugins instalados por pacman 
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- ESTILO MACHA ---
# Personalizamos el color de las sugerencias (un gris azulado tenue)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'

# --- CONFIGURACIÓN DE HISTORIAL ---
HISTSIZE=10000 
SAVEHIST=10000 
HISTFILE=~/.zsh_history 
setopt HIST_IGNORE_ALL_DUPS  # No guardar comandos duplicados
setopt SHARE_HISTORY         # Compartir historial entre terminales abiertas

# --- ALIAS ---

# Configuración
alias conf-hypr='nvim ~/.config/hypr/hyprland.conf' 
alias conf-zsh='nvim ~/.zshrc'
alias conf-waybar='nvim ~/.config/waybar/config.jsonc'
alias conf-star='nvim ~/.config/starship.toml'
alias conf-kitty='nvim ~/.config/kitty/kitty.conf'
alias conf-nvim='nvim ~/.config/nvim/init.lua'

# Navegación
alias ls='eza --icons --group-directories-first'
alias ll='eza -lha --icons --git --group-directories-first'
alias lt2='eza --tree --level=2 --icons'    # Dos niveles (ideal para ver archivos dentro de carpetas)
alias lt3='eza --tree --level=3 --icons'    # Tres niveles (visión profunda)

alias f='fd'
alias cd='z'
alias matrix='cmatrix -C blue -b'
alias limpiar='sudo pacman -Sc && sudo pacman -Rs $(pacman -Qdtq)'
alias bye='systemctl poweroff'

alias pdf='zathura'
alias img='imv'
alias tiempotalavera='curl es.wttr.in/Talavera+de+la+Reina'

# --- FUNCIONES ---

# --- AUTO-LS AL CAMBIAR DE DIRECTORIO ---
function chpwd() {
    # Si estamos en una terminal interactiva, ejecuta eza
    if [[ -o interactive ]]; then
        # Usamos 'll' o 'ls' según prefieras. 
        # Aquí usamos la configuración de eza que definimos antes:
        eza --icons --group-directories-first --color=always
    fi
}

# 1. Radio Lofi Hip Hop (La clásica)
lofi() {
    _play_radio "https://www.youtube.com/watch?v=jfKfPfyJRdk"
}

# 2. Radio Synthwave (Estética futurista/gaming)
synth() {
    _play_radio "https://www.youtube.com/watch?v=4xDzrJKXOOY"
}

# 3. Radio Jazz (Cafetería/Chill)
jazz() {
    _play_radio "https://www.youtube.com/watch?v=ZaBS6sLsHJQ"
}

# Función interna para no repetir código (Ingeniería de software 101)
_play_radio() {
    # Lanzar mpv en background
    mpv --no-video --really-quiet "$1" & 
    local RADIO_PID=$!
    
    clear
    cava
    
    # Al salir de cava, matamos la radio y limpiamos
    kill $RADIO_PID 2>/dev/null
    clear
    echo "Radio detenida. Volviendo al terminal."
}

# --- YAZI: Cambiar de directorio al salir ---
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Alias extra por si te olvidas
alias stopradio='pkill mpv && pkill cava'

# --- INICIO ---
# Solo ejecuta fastfetch si la terminal es interactiva (evita errores en scripts)
[[ -o interactive ]] && fastfetch

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

source <(fzf --zsh)

# --- REBIND CTRL+L PARA CLEAR + FASTFETCH ---
fastfetch_clear() {
    clear
    fastfetch
    zle reset-prompt  # Refresca el prompt para que aparezca abajo
}
# Creamos un widget de ZSH con la función
zle -N fastfetch_clear_widget fastfetch_clear
# Asignamos el widget a Ctrl+L
bindkey '^L' fastfetch_clear_widget

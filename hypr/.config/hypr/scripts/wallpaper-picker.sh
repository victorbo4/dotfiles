#!/bin/bash

# Directorio de tus wallpapers
DIR="$HOME/media/wallpapers"

# Seleccionar archivo con Rofi
PICS=$(ls $DIR)
CHOICE=$(echo -e "$PICS" | rofi -dmenu -i -p "Seleccionar Wallpaper:")

if [ -n "$CHOICE" ]; then
    FULL_PATH="$DIR/$CHOICE"
    
    # Cargar y aplicar el nuevo wallpaper dinámicamente
    hyprctl hyprpaper preload "$FULL_PATH"
    hyprctl hyprpaper wallpaper "eDP-1,$FULL_PATH"
    
    # Opcional: Actualizar tu hyprpaper.conf para que sea persistente
    # sed -i "s|path = .*|path = $FULL_PATH|" ~/.config/hypr/hyprpaper.conf
fi

#!/bin/bash
official=$(checkupdates | wc -l)
aur=$(yay -Qua | wc -l)
echo "Official packages: $official updates"
echo "AUR packages: $aur updates"
echo "Total: $((official + aur)) updates"


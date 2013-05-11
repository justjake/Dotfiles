#!/usr/bin/env bash

dir=$(dirname $0)
gconfdir=/apps/gnome-terminal/profiles

echo # This makes the prompts easier to follow (as do other random echos below)

########################
### Select a profile ###
########################

declare -a profiles
declare -a visnames
profiles=($(gconftool-2 -R $gconfdir | grep $gconfdir | cut -d/ -f5 |  cut -d: -f1))

#get visible names
for index in  ${!profiles[@]}; 
do    
    visnames[$index]=$(gconftool-2 -g $gconfdir/${profiles[$index]}/visible_name);
done
echo "Please select a Gnome Terminal profile:"
IFS=','
names="${visnames[*]}"
select profile_name in $names; 
do 
  if [[ -z $profile_name ]]; then
    echo -e "ERROR: Invalid selection -- ABORTING!\n"
    exit 1
  fi
  break; 
done
profile_key=$(expr ${REPLY} - 1)
unset IFS

#########################################################
### Show the choices made and prompt for confirmation ###
#########################################################

echo    "You have selected:"
echo -e "  Profile: $profile_name (gconf key: ${profiles[$profile_key]})\n"

#typeset -u confirmation
echo -n "Is this correct? (YES to continue) "
read confirmation
confirmation=$(echo $confirmation | tr '[:lower:]' '[:upper:]')
if [[ $confirmation != YES ]]; then
  echo -e "ERROR: Confirmation failed -- ABORTING!\n"
  exit 3
fi

########################
### Finally... do it ###
########################

echo -e "Confirmation received -- applying settings\n"

profile_path=$gconfdir/${profiles[$profile_key]}
# set palette
# old, shitty pallete
# gconftool-2 -s -t string $profile_path/palette "#3F3F3F3F3F3F:#CCCC93939393:#7F7F9F9F7F7F:#E3E3CECEABAB:#DFDFAFAF8F8F:#CCCC93939393:#8C8CD0D0D3D3:#DCDCDCDCCCCC:#3F3F3F3F3F3F:#CCCC93939393:#7F7F9F9F7F7F:#E3E3CECEABAB:#DFDFAFAF8F8F:#CCCC93939393:#8C8CD0D0D3D3:#DCDCDCDCCCCC"

# amazing pallete from roxterm
gconftool-2 -s -t string $profile_path/palette "#1E1E23232020:#707050505050:#6060B4B48A8A:#DFDFAFAF8F8F:#505060607070:#DCDC8C8CC3C3:#8C8CD0D0D3D3:#DCDCDCDCCCCC:#707090908080:#DCDCA3A3A3A3:#C3C3BFBF9F9F:#F0F0DFDFAFAF:#9494BFBFF3F3:#ECEC9393D3D3:#9393E0E0E3E3:#FFFFFFFFFFFF"

# set highlighted color to be different from foreground-color
gconftool-2 -s -t bool $profile_path/bold_color_same_as_fg false

# set foreground, background and highlight color
gconftool-2 -s -t string $profile_path/background_color "#3F3F3F3F3F3F"
gconftool-2 -s -t string $profile_path/foreground_color "#DCDCDCDCCCCC"
Gconftool-2 -s -t string $profile_path/bold_color       "#E3E3CECEABAB"

# make sure the profile is set to not use theme colors
gconftool-2 -s -t bool $profile_path/use_theme_colors false

#!/bin/bash

# structurize fontawesome icons
icons_dir="node_modules/@fortawesome/fontawesome-free/svgs/"
target_icons_dir="_includes/icons/fontawesome/"
mkdir -p ${target_icons_dir}
rsync -a ${icons_dir} ${target_icons_dir}
echo "Moved Fontawesome icons from ${icons_dir} to ${target_icons_dir} directory"

# fontawesome icons defaults
find_string="<svg"
replace_string="<svg fill={{ include.fill | default: site.colors.dark }}"
find_string_height='height="[0-9]+"'
replace_string_height="height={{ include.height | default: '1rem' }}"
find_string_width='width="[0-9]+"'
replace_string_width=""

for i in $(find ${target_icons_dir} -type f -name "*.svg");
do
    # add fill attribute to the fontawesome svg icons
    if ! grep -q "${replace_string}" $i; then
        sed -i "s/${find_string}/${replace_string}/" $i
        echo "Fill attribute added to ${i}"
    else
        echo "Fill attribute already exists in ${i}"
    fi

    # add height attribute to the fontawesome svg icons
    if grep -q "height=" $i; then
        sed -i -E "s/${find_string_height}/${replace_string_height}/" "$i"
        sed -i -E "s/${find_string_width}/${replace_string_width}/" "$i"
        echo "Height and width attributes changed in ${i}"
    else
        sed -i "s/<svg/<svg ${replace_string_height}/" "$i"
        echo "Height and width attributes added to ${i}"
    fi
done

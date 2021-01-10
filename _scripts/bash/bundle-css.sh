#!/bin/sh

# path to production css directory
prod_css_dir='assets/prod-css'

# remove existing production css directory
rm -rf $prod_css_dir

# compile external css into assets/prod-css directory
node-sass assets/scss/index.scss -o $prod_css_dir --output-style compressed

# path to directory to store hashes
hashes_dir="_data/generated/hashes"

# create hashes directory to store hashes
mkdir -p $hashes_dir

# name for the hash file
hash_yml_file="$hashes_dir/css.yml"

# remove the pre existing hash file
rm $hash_yml_file

# create the hash file
touch $hash_yml_file

# create md5sum hash for each css in production directory
for i in $(find $prod_css_dir -type f -name "*.css");
do 
    # create md5sum hash
    hash=$(md5sum $i | cut -c -32)

    # create new file name with hash
    file_ext="${i##*.}"
    file_base_name="${i%.*}"
    file_name_with_hash="$file_base_name.$hash.$file_ext"

    # rename the file
    mv $i $file_name_with_hash

    # add the generated hash to hashes file
    echo "- /$file_name_with_hash" >> $hash_yml_file
    echo "Added hash to $file_name_with_hash"
done

# compile inline css into _includes/css directory
node-sass assets/scss/inline/ -o _includes/css --output-style compressed

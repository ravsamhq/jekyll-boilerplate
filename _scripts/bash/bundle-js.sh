#!/bin/bash

# list of js files required by every page
required_by_all_js_files=("node_modules/jquery/dist/jquery.js"
                          "node_modules/bootstrap/dist/js/bootstrap.js"
                          "node_modules/lazysizes/lazysizes.js"
                          "node_modules/aos/dist/aos.js")

# path to production js directory
prod_js_dir="assets/prod-js"

# name for js file containing concatenated js files
js_file="global.js"

# remove existing production js directory and create a new one
rm -rf $prod_js_dir && mkdir -p $prod_js_dir

# create js file containing concatenated js files
touch $prod_js_dir/$js_file

# concatenate each js file into a single file
for file in "${required_by_all_js_files[@]}"
do
    cat $file >> $prod_js_dir/$js_file
    echo "Appended $file to $prod_js_dir/$js_file"
done

# path to directory to store hashes
hashes_dir="_data/generated/hashes"

# create hashes directory to store hashes
mkdir -p $hashes_dir

# name for the hash file
hash_yml_file="$hashes_dir/js.yml"

# remove the pre existing hash file
rm $hash_yml_file

# create the hash file
touch $hash_yml_file

for i in $(find $prod_js_dir -type f -name "*.js");
do
    # minify and mangle the resultant js file
    terser --compress --mangle --comments false -o $i -- $i

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

# target directory for included js files
includes_js_dir="_includes/js"

# list of js files required by pages on individual pages
standalone_js_files=("assets/js/index.js")

# remove existing includes js directory and create a new one
rm -rf $includes_js_dir && mkdir -p $includes_js_dir

# move each standalone file to includes directory
for file in "${standalone_js_files[@]}"
do
    file_name=`basename $file`
    rsync -a $file $includes_js_dir/$file_name
    terser --compress --comments false -o $includes_js_dir/$file_name -- $includes_js_dir/$file_name
    echo "Moved and compressed $file to $includes_js_dir/$file_name directory"
done

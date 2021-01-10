#!/bin/sh

# setup the website
npm run setup

# build the website
JEKYLL_ENV=production bundle exec jekyll build -d public

# minify the html
npm run minify-html

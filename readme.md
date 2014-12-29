[![Code Climate](https://codeclimate.com/github/metaflop/metaflop-www/badges/gpa.svg)](https://codeclimate.com/github/metaflop/metaflop-www)
[![security](https://hakiri.io/github/metaflop/metaflop-www/dev.svg)](https://hakiri.io/github/metaflop/metaflop-www/dev)
[![Dependency Status](https://gemnasium.com/metaflop/metaflop-www.svg)](https://gemnasium.com/metaflop/metaflop-www)

# Metaflop

Metaflop is a web application aimed at the generation of experimental fonts. It generates custom and flexible digital fonts by the programming language [Metafont](http://en.wikipedia.org/wiki/Metafont). For the first time users are able to transform a Metafont online simply by adjusting typographically relevant parameters. The user doesn't have to deal with the complexity of the language and the geometrical construction of all the single characters anymore and can focus on the creative and typographic decisions.

Metaflop is...

* ... a javascript powered web interface
* ... a sinatra based backend
* ... a unix tool chain that generates the preview and output fonts

The output is a downloadable [opentype font](http://en.wikipedia.org/wiki/OpenType).

## Prerequisites

* ruby >= 1.9.2 ([rbenv](http://rbenv.org/) or [rvm](http://beginrescueend.com/) recommended)
* bundler
  ``$ gem install bundler``
* required rubies
  ``$ bundle``
* texlive
* texlive-metapost
* fontforge
* lcdf-typetools
* [sfnt2woff](http://people.mozilla.com/~jkew/woff/)
* [ttf2eot](https://github.com/metaflop/ttf2eot)
* t1utils
* python
* python libs: fontforge, argparse
* mysql
* mysql development files (see [Getting started with DataMapper](http://datamapper.org/getting-started.html))

## Getting started

1. Install the prerequisites above
2. Create a mysql database named *metaflop_development*
3. Copy the file *config/db.yml.sample* to *config/db.yml* and update the mysql username and password
4. `$ rackup`
5. Go to [localhost:9292](http://localhost:9292)

## Deployment

Create a file *.env* with the content

    PARTY_FOUL_OAUTH_TOKEN=<github repo oauth token>

in */path/to/shared* on your server.

## License

The sourcecode of this project is licensed under the [GPL v3](http://www.gnu.org/copyleft/gpl.html).
All generated fonts of this project are dual licensed under the [GPL v3](http://www.gnu.org/copyleft/gpl.html) and the [OFL](http://scripts.sil.org/OFL).

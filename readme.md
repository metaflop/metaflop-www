# Metaflop

Metaflop is a web application aimed at the generation of experimental fonts. It generates custom and flexible digital fonts by the programming language [Metafont](http://en.wikipedia.org/wiki/Metafont). For the first time users are able to transform a Metafont online simply by adjusting typographically relevant parameters. The user doesn't have to deal with the complexity of the language and the geometrical construction of all the single characters anymore and can focus on the creative and typographic decisions.

Metaflop is...

* ... a javascript powered web interface
* ... a sinatra based backend
* ... an extensive external tool chain that generates the preview images and output fonts

The output is a downloadable [opentype font](http://en.wikipedia.org/wiki/OpenType).

## Prerequisites

* ruby >= 1.9.2 ([rvm](http://beginrescueend.com/) recommended)
* bundler
  ``$ gem install bundler``
* required rubies
  ``$ bundle``
* texlive
* texlive-metapost
* fontforge
* dvipng
* lcdf-typetools
* dvisvgm
* imagemagick (convert)
* [sfnt2woff](http://people.mozilla.com/~jkew/woff/)
* [ttf2eot](https://github.com/greyfont/ttf2eot)
* t1utils

## License

The sourcecode of this project is licensed under the [GPL v3](http://www.gnu.org/copyleft/gpl.html).
All generated fonts of this project are dual licensed under the [GPL v3](http://www.gnu.org/copyleft/gpl.html) and the [OFL](http://scripts.sil.org/OFL).

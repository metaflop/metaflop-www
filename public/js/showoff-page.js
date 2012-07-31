/*
 * metaflop - web interface
 * © 2012 by alexis reigel
 * www.metaflop.com
 *
 * licensed under gpl v3
 */

$(function () {
    var slideshow = $('#slideshow');
    var progress = slideshow.parents('.preview-box').find('h2 span');
    var initSlideshow = function() {
        slideshow.bjqs({
            width: 704,
            height: 500,
            nextText: '',
            prevText: '',
            rotationSpeed: 400000,
            showControls: false,
            showMarkers: false,
            mouseNav: true,
            nextImageLoaded: function(position, slideCount) {
              progress.html(position + 1 + "/" + slideCount);
            }
        });
    };

    initSlideshow();
});

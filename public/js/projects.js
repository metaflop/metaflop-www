/*
 * metaflop - web interface
 * © 2012 by alexis reigel
 * www.metaflop.com
 *
 * licensed under gpl v3
 */

$(function () {
    var slideshow = $('#slideshow');
    var initSlideshow = function() {
        slideshow.bjqs({
            width: 704,
            height: 340,
            nextText: '',
            prevText: '',
            rotationSpeed: 7000
        });
    };

    initSlideshow();

    $('#menu').on('click', '.dynamic-menu', function(e){
        e.preventDefault();

        slideshow.fadeTo(0, 0.5).spin('large');
        
        var link = $(this);

        $.ajax({
            url: $(this).attr('href'),
            success: function(data) {
                // update slideshow
                var html = '';
                console.debug(data);
                data.images.each(function(image) {
                    html += '<li><img src="' + image + '" /></li>';
                });
                slideshow.find('ul.bjqs').html(html);
                initSlideshow();
                
                // update description
                $('#parameter-panel').find('.box-content').html(data.description);

                // toggle active menu entry
                $('#menu').find('.dynamic-menu').removeClass('active');
                link.addClass('active').blur();

                slideshow.fadeTo(0, 1).spin(false);
            }
        });

        return false;
    });
    
});

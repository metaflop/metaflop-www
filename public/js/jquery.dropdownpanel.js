/*
 * metaflop - web interface
 * © 2012 by alexis reigel
 * www.metaflop.com
 *
 * licensed under gpl v3
 */

(function ($) {

    var defaults = {
        panelToggleDuration: 500,
        panelToggleEasing: 'easeInOutExpo',
        onClicked: function() {}
    };

    $.fn.dropdownpanel = function(options) {
        return this.each(function() {
            var $this = $(this);

            // settings
            var settings = $.extend({}, defaults, options);

            $this.hide();

            // current value -> display
            var selectedOption = $this.find('option:selected');
            var $div = $('<div class="static-value dropdown-value">' + selectedOption.html() + '</div>');
            var ul = '<ul class="dropdown-list">';

            // list of all available options
            $this.find('option').each(function() {
                ul += '<li id="'
                     + $(this).val() + '-' + $this[0].id
                     + '"><a href="#">' + $(this).html() + '</a></li>';
            });

            ul += '</ul>';
            var $ul = $(ul);
            var lis = $ul.find('li');
            // mark the currently selected option
            lis.filter(function() { return $(this).find('a').html() == selectedOption.html() }).addClass('active');

            lis.click(function(e) {
                e.preventDefault();

                var selectEl = $this;
                var listItems = lis;
                var li = $(this);
                var displayEl = $div;

                listItems.removeClass('active');
                li.addClass('active');

                // set select value
                selectEl.val(this.id.split('-')[0]);

                // set display value
                displayEl.html(li.find('a').text());

                // hide
                displayEl.click();

                settings.onClicked();
            });

            $this.after($ul);
            $this.after($div);

            // toggle panel
            $div.click(function() {
                var parent = $(this).parent();
                parent.find('.dropdown-value').toggleClass('active');
                parent.find('.dropdown-list')
                    .animate({ height: 'toggle' }, settings.panelToggleDuration, settings.panelToggleEasing);
            });
        });
    };

})(jQuery);

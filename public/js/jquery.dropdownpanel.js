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
                     + $(this).val() + $this[0].id
                     + '"><span class="action">' + $(this).html() + '</span></li>';
            });

            ul += '</ul>';
            var $ul = $(ul);
            var lis = $ul.find('li');
            // mark the currently selected option
            lis.filter(function() { return $(this).find('span').html() == selectedOption.html() }).addClass('active');
            lis.click(function() {
                var selectEl = $this;
                var listItems = lis;
                var li = $(this);
                var displayEl = $div;

                listItems.removeClass('active');
                li.addClass('active');

                // set select value
                selectEl.val(this.id.toNumber() + '');

                // set display value
                displayEl.html(li.find('span').text());

                // hide
                displayEl.click();

                settings.onClicked();
            });

            $this.after($ul);
            $this.after($div);

            // toggle panel
            $div.click(function() {
                $(this).parent().find('.dropdown-list')
                    .animate({ height: 'toggle' }, settings.panelToggleDuration, settings.panelToggleEasing);
            });
        });
    };

})(jQuery);

/*
 * JQuery Dropdown Panel plugin (v 0.1.0)
 *
 * Replaces an html select element with a
 * simple, animated dropdown.
 *
 * https://github.com/metaflop/jquery-dropdownpanel
 *
 * © 2012 by Alexis Reigel
 *
 * Licensed under the GPL v3
 *
 */

(function ($) {

    var defaults = {
        panelToggleDuration: 500,
        panelToggleEasing: 'easeInOutExpo',
        wrapperCssClass: 'dropdown-value',
        listCssClass: 'dropdown-list',
        onClicked: function() {}
    };

    $.fn.dropdownpanel = function(options) {
        return $.each(this, function(index, select) {
            var select = $(select);

            // settings
            var settings = $.extend({}, defaults, options);

            select.hide();

            // current value -> display
            var selectedOption = select.find('option:selected');
            var wrapper = $('<div class="' + settings.wrapperCssClass + '">' + selectedOption.html() + '</div>');
            var ul = '<ul class="' + settings.listCssClass + '">';

            // list of all available options
            $.each(select.find('option'), function(index, option) {
                option = $(option);
                ul += '<li id="' + option.val() + '-' + select[0].id + '">' +
                      '<a href="#">' + option.html() + '</a>' +
                      '</li>';
            });

            ul += '</ul>';
            ul = $(ul);

            var lis = ul.find('li');
            // mark the currently selected option
            $($.grep(lis, function(li) {
              return $(li).find('a').html() == selectedOption.html()
            })).addClass('active');

            lis.click(function(e) {
                e.preventDefault();

                var selectEl = select;
                var listItems = lis;
                var li = $(this);
                var displayEl = wrapper;

                listItems.removeClass('active');
                li.addClass('active');

                // set select value
                selectEl.val(this.id.split('-')[0]);

                // set display value
                displayEl.html(li.find('a').text());

                // hide
                displayEl.click();

                // callback
                settings.onClicked();
            });

            select.after(ul);
            select.after(wrapper);

            // toggle panel
            wrapper.click(function() {
                var parent = $(this).parent();
                parent.find('.' + settings.wrapperCssClass).toggleClass('active');
                parent.find('.' + settings.listCssClass).animate(
                    { height: 'toggle' },
                    settings.panelToggleDuration,
                    settings.panelToggleEasing
                );
            });
        });
    };

})(jQuery);

/*
 * JQuery Dropdown Panel plugin (v 0.2.0)
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

    $.fn.dropdownpanel = function(options) {

        var defaults = {
            panelToggleDuration: 500,
            panelToggleEasing: 'easeInOutExpo',
            wrapperCssClass: 'dropdown-value',
            listCssClass: 'dropdown-list',
            onClicked: function() {}
        };

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
                ul += '<li data-value="' + option.val() + '">' +
                      '<a href="#">' + option.html() + '</a>' +
                      '</li>';
            });

            ul += '</ul>';
            ul = $(ul);

            var lis = ul.find('li');
            // mark the currently selected option
            $($.grep(lis, function(li) {
              return $(li).find('a').html() == selectedOption.html();
            })).addClass('active');

            // listen for clicks on our custom dropdown
            lis.click(function(e) {
                e.preventDefault();

                var selectEl = select;
                var listItems = lis;
                var li = $(this);
                var displayEl = wrapper;

                listItems.removeClass('active');
                li.addClass('active');

                // set select value
                selectEl.val(li.data('value'));

                // set display value
                displayEl.html(li.find('a').text());

                // hide
                displayEl.click();

                // callback
                settings.onClicked();
            });

            // listen for changes on the original select
            select.change(function(e) {
                var selectEl = select;
                var listItems = lis;
                var displayEl = wrapper;

                var value = $(this).val();
                var activeLi = $(lis.filter('[data-value="' + value + '"]'));

                listItems.removeClass('active');
                activeLi.addClass('active');

                displayEl.html(activeLi.find('a').text());
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

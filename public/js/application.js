/*
 * metaflop - web interface
 * © 2012 by alexis reigel
 * www.metaflop.com
 *
 * licensed under gpl v3
 */

$(function () {

    // create a namespace for later use
    $.fn.metaflop = {
        ready: false // is set to true when the initial preview has been generated (i.e. the UI is ready)
    };

    // set background to corresponding inputs
    var setActiveInputs = function(inputField) {
        var suffix = (inputField.id || inputField[0].id).remove(/^\w+-/);
        $('.adjuster input').removeClass('active');
        $('input[id$=' + suffix + ']').addClass('active');
    }

    // increase/decrease the inputField's value
    var changeValue = function(inputField, cssClass){
        var number = cssClass.remove(/\D/g).toNumber() / 100.0;
        var method = cssClass.remove(/\d+$/);

        var value = inputField.val().toNumber() || 0;

        if (method == 'add') value = value + number;
        else if (method == 'sub') value = value - number;

        setValue(inputField, value);
    }

    var setValue = function(inputField, value) {
        if (!value && value !== 0){
            value = inputField.val() || 0;
        }

        value = String(value).replace(',', '.').toNumber();

        inputField.val(value);
        // add init class to prevent tooltips and recursion
        inputField.addClass('init');

        var sliderInput = getTwinInput(inputField);
        // update the associated slider too
        if (value >= sliderInput.attr('data-range-from') && value <= sliderInput.attr('data-range-to')) {
            sliderInput.val(value);
            fdSlider.updateSlider(sliderInput[0].id);
        }

        previewImage();
    }

    // finds the corresponding counterpart input field
    // for a "param-" the corresponding "slider-" and vice versa
    // input is a jquery object or a dom element
    var getTwinInput = function(input) {
        var element = input.length === undefined ? input : input[0];
        var id = element.id.has('slider')
                 ? element.id.replace('slider-', 'param-')
                 : element.id.replace('param-', 'slider-');
        return $('#' + id);
    }

    var stopRequest = function() {
        if (window.stop !== undefined) {
            window.stop();
        }
        else if (document.execCommand !== undefined) {
            document.execCommand("Stop", false);
        }
    }

    // we habe 2 preview images, the next preview is loaded into the invisible one
    var previewImageCall = function(){
        var previewBox = $('.preview-box.active');
        var loading = previewBox.find('.preview-loading');
        var loadingText = previewBox.find('.preview-loading-text');
        var image = previewBox.find('.preview-image:visible');
        var preloadImage = previewBox.find('.preview-image:hidden');
        var content = previewBox.find('.preview-box-content');
        var previewType = previewBox.attr('id').remove('preview-');

        var queryString = $.fn.metaflop.queryString = '?' +
            $.makeArray($('input:text,textarea').not('[id^=slider-]')).map(function(element){
                return element.id.remove('param-') + '=' + element.value
            })
            // add the selected character param
            .add('char-number' + '=' + ($('div.char-chooser a.active').attr('href') || '1').remove('#'))
            .join("&");

        var url = '/preview/' + previewType + queryString;

        var done = function(error) {
            preloadImage.unbind('load');
            preloadImage.unbind('error');

            if (error) {
                preloadImage.attr('src', '/img/error.png');
                preloadImage.addClass('error');

                content.tipsy({
                    trigger: 'manual',
                    fallback: 'The entered value is out of a valid range.\nPlease correct your parameters.',
                    gravity: 's'
                }).tipsy('show');
            }
            else {
                preloadImage.removeClass('error');
                image.removeClass('error');
            }

            content.fadeTo(0, 1);
            loadingText.hide();
            loading.spin(false);
            content.find('textarea').hide();
            image.hide();
            preloadImage.show();

            $.fn.metaflop.preloadImageInProgress = false;

            if (!$.fn.metaflop.ready) {
                // add tooltips to the sliders (only after the initial preview has been loaded,
                // we don't want to show them prematurely)
                $('.fd-slider-handle').tipsy({ title: 'aria-valuetext', gravity: 's' });
                $.fn.metaflop.ready = true;
            }
        };

        // there is already a request on its way -> cancel it
        if ($.fn.metaflop.preloadImageInProgress) {
            stopRequest();
        }
        else {
            content.tipsy('hide');
            content.fadeTo(0, 0.5);
            loadingText.show();
            loading.spin('large');

            $.fn.metaflop.preloadImageInProgress = true;
        }

        // events when image is loaded
        preloadImage.unbind('load');
        preloadImage.unbind('error');

        preloadImage.bind('load', function() {
            done();
        });

        preloadImage.bind('error', function() {
            done(true);
        });

        // start preloading
        preloadImage.attr('src', url);
    }

    var timeout;
    var previewImage = function(){
        if (timeout) clearTimeout(timeout);
        timeout = setTimeout(previewImageCall, 300);
    }

    var isAllowedTrailingCharacter = function(keyCode) {
        return [190, 188].some(keyCode);
    }

    var isAllowedMetaKey = function(keyCode) {
        return [16, 17, 18].some(keyCode) || // meta
               [46, 9, 35, 36, 37, 39].some(keyCode); // backspace, delete, tab, cursors
    }

    var paramInputs = $('.adjuster input.param');

    paramInputs
        .focus(function() {
            $this = $(this);
            setActiveInputs($this);
        })
        .keydown(function(event) {
            // allow backspace, delete, tab, cursors and metakeys
            if (isAllowedMetaKey(event.keyCode)) {
            }
            // allow delete
            else if (event.keyCode == 8){
            }
            // up increase value
            else if (event.keyCode == 38) {
            }
            // down decrease value
            else if (event.keyCode == 40) {
                changeValue($(this), 'sub1');
            }
            // allow decimal point (".", ",")
            else if (isAllowedTrailingCharacter(event.keyCode)) {
            }
            else {
                // stop keypress if NaN
                if ((event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
                    event.preventDefault();
                }
            }

        })
        .keyup(function(event) {
            // defer evaluation when allowed trailing characters (e.g. ".", wait for the next number)
            // ignore meta keys
            if (!(isAllowedTrailingCharacter(event.keyCode) || isAllowedMetaKey(event.keyCode))) {
                setValue($(this));
            }
        })
        .blur(function() {
            setValue($(this), null);
        });

    // reset
    $('#action-reset-values').click(function(e) {
        e.preventDefault();

        paramInputs.each(function() {
            var $this = $(this);

            var sliderInput = getTwinInput($this);
            // add init class to prevent tooltips
            $this.addClass('init');

            setValue($this, sliderInput.attr('data-default'));
        });

        return false;
    });

    // randomize
    $('#action-randomize-values').click(function(e) {
        e.preventDefault();

        paramInputs.each(function() {
            var $this = $(this);

            var sliderInput = getTwinInput($this);
            // add init class to prevent tooltips
            $this.addClass('init');

            var from = sliderInput.attr('data-range-from');
            var to = sliderInput.attr('data-range-to');
            var value = Number.random(from * 100, to * 100) / 100;

            setValue($this, value);
        });

        return false;
    });

    // share the current settings
    $('#action-share-url').click(function(e) {
        e.preventDefault();

        var link = $(this);
        var url = "http://www.metaflop.com/" + $.fn.metaflop.queryString.escapeURL();
        var text = 'I created a nice metaflop font!';
        var textAndUrl = text + ' ' + url;

        var tipsyContent =
            '<a href="http://twitter.com/home?status=' + textAndUrl + '" target="_blank" class="action-icon share-twitter" title="post a tweet"><img src="/img/blank.png" /></a>' +
            '<a href="http://www.facebook.com/sharer.php?u=' + textAndUrl + '" target="_blank" class="action-icon share-facebook" title="post on facebook"><img src="/img/blank.png" /></a>' +
            '<a href="mailto:?subject=metaflop font&body=' + text + '" target="_blank" class="action-icon share-email" title="send by email"><img src="/img/blank.png" /></a>' +
            '<span><img src="/img/blank.png" /><object width="16" height="16" id="clippy" class="clippy" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" title="copy to clipboard"><param value="/flash/clippy.swf" name="movie"><param value="always" name="allowScriptAccess"><param value="high" name="quality"><param value="noscale" name="scale"><param value="text=' + url + '" name="FlashVars"><param value="#FFFFFF" name="bgcolor"><param value="opaque" name="wmode"><embed width="16" height="16" wmode="opaque" bgcolor="#FFFFFF" flashvars="text=' + url + '" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" allowscriptaccess="always" quality="high" name="clippy" src="/flash/clippy.swf"></object></span>';

        link.tipsy({
            trigger: 'manual',
            fallback: tipsyContent,
            gravity: 'w',
            html: true,
            className: 'tipsy-small'
        }).tipsy('show');

        // hide tipsy when clicked anywhere outside of it
        $('body').bind('click.metaflop', function() {
            link.tipsy('hide');
            $('body').unbind('click.metaflop');
        });

        return false;
    });

    // toggle the +/- buttons for the inputs
    var parameterPanel = $('#parameter-panel');
    var parameterPanelBlocks = parameterPanel.find('.adjuster');

    parameterPanelBlocks.mouseover(function() {
        var $this = $(this);
        parameterPanel.find('.adjuster a').hide();
        $this.find('a').show();

        parameterPanel.find('input').removeClass('active');
        $this.find('input').addClass('active');
    });
    parameterPanel.find('.inputblock').mouseleave(function() {
        $(this).find('a').hide();
    });


    $('.add1, .add10, .sub1, .sub10').click(function(e) {
        e.preventDefault();
        $this = $(this);
        var input = $this.parent().find('input');

        setActiveInputs(input);

        changeValue(input, $this.attr('class'));
        return false;
    });

    // sliders
    function updateValue(cbObj) {

        // update the associated input field
        var input = getTwinInput(cbObj.elem);
        input.val(cbObj.value)

        if (input.hasClass('init')) {
            input.removeClass('init');
        }
        else {
            input.blur();

            // update the tooltip
            $(cbObj.elem).siblings().find('.fd-slider-handle').tipsy('show');
        }
    }
    parameterPanel.find('.slider input').each(function() {
        fdSlider.createSlider({
            inp: this,
            step: "0.01",
            maxStep: 1, // (for keyboard users)
            min: $(this).attr('data-range-from'),
            max: $(this).attr('data-range-to'),
            animation:"timed",
            hideInput: true,
            callbacks:{
                "change":[updateValue]
            }
        });
    });

    // character chooser for single preview
    var charLinks = $('div.char-chooser a');
    charLinks.click(function(e) {
        e.preventDefault();

        if ($(this).parents('.preview-box.active').length > 0) {
            charLinks.removeClass('active');
            $(this).addClass('active').blur();
            previewImage();
        }

        return false;
    });
    charLinks.first().addClass('active');

    $('a.char-chooser').click(function(e) {
        e.preventDefault();
        var $this = $(this);
        var div = $('div.char-chooser');
        var activeItem = div.find('li.active');
        var items = div.find('li');

        var nextItem = $($this.hasClass('right')
            ? activeItem.next()[0] || items.first()
            : activeItem.prev()[0] || items.last());

        items.removeClass('active');
        nextItem.addClass('active');
        div.scrollTo(nextItem, 400, { easing: 'easeInOutExpo', axis: "x" });

        return false;
    });

    // activate preview box
    $('.preview-box').click(function(e) {
        e.preventDefault();

        var $this = $(this);
        if ($this.not('.active').length > 0) {
            $('.preview-box.active').removeClass('active').find('textarea').hide();
            $this.addClass('active');

            previewImage();
        }
        // show textarea
        else if ($this[0].id == 'preview-typewriter') {
            $this.find('textarea').show().focus();
        }

        return false;
    });

    // edit/view mode for typewriter preview (textarea on/off)
    $('#preview-typewriter').find('.toggle-mode').click(function(e) {
        e.preventDefault();

        var $this = $(this);
        var textarea = $this.siblings('textarea');

        if ($this.hasClass('edit-mode')) {
            textarea.hide();
            previewImage();
            $this.attr('title', 'enter edit mode');
        }
        else {
            textarea.show();
            $this.attr('title', 'exit edit mode');
        }

        $this.toggleClass('edit-mode');

        return false;
    });

    // switch basic/pro mode for parameter panel
    var parameterPanelToggleMode = $('.parameter-panel-mode-toggle span');
    parameterPanelToggleMode.click(function() {
        var $this = $(this);
        var parameterPanel = $('#parameter-panel');
        var adjusters = parameterPanel.find('.adjuster');
        var sliders = parameterPanel.find('.slider');

        parameterPanelToggleMode.removeClass('active');
        $this.addClass('active');

        if ($this.hasClass('sliders')) {
            sliders.show();
            adjusters.hide();
        }
        else {
            adjusters.show();
            sliders.hide();
        }
    });

    // toggle the information header
    var informationToggle = $('#menu').find('.action');
    informationToggle.click(function() {
        informationToggle.toggleClass('active');
        $('#info-panel').toggle(500, 'easeInOutExpo');
    });

    // fancybox links
    $('.popup').fancybox({
        'titleShow' : false,
        'width' : 1000,
        'height' : 650,
        'autoDimensions' : false,
        'showNavArrows' : false,
        'transitionIn' : 'face',
        'transitionOut' : 'fade',
        'easingIn' : 'easeOutBack',
        'easingOut' : 'easeInBack'
    });
    $('.popup-back').live('click', function(e) {
        e.preventDefault();

        $.fancybox.prev();

        return false;
    });

    // load the first image
    previewImage();
});

$(function () {

    // set background to corresponding inputs
    var setActiveInputs = function(inputField) {
        var suffix = (inputField.id || inputField[0].id).remove(/^\w+-/);
        $('.adjuster input').removeClass('active');
        $('input[id$=' + suffix + ']').addClass('active');
    }

    // increase/decrease the inputField's value
    var changeValue = function(inputField, cssClass){
        var number = cssClass.remove(/\D/g).toNumber() / 10.0;
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

        value = String(value).replace(',', '.');

        inputField.val(value);

        previewImage();
    }

    var stripPercentSign = function(inputField) {
        var value = inputField.val().toNumber();
        if (value || value === 0) {
            inputField.val(value);
        }
    }

    var previewImage = function(){
        var previewBox = $('.preview-box.active');
        var loading = previewBox.find('.preview-loading');
        var image = previewBox.find('.preview-image');
        var previewType = previewBox.attr('id').remove('preview-');
        image.hide();
        loading.show();
        loading.spin("large");
        // http://stackoverflow.com/questions/4285042/can-jquery-ajax-load-image
        var url = '/preview/' + previewType + '?' + 
            $.makeArray($('input:text')).map(function(value){ return value.id.remove('param-') + '=' + value.value.remove(/\D+$/) }).join("&");
        image.attr('src', url).load(function(responseText, textStatus, XMLHttpRequest) {
            loading.spin(false);
            image.show();
            loading.hide();
        });
    }

    var isAllowedTrailingCharacter = function(keyCode) {
        return [190, 188].some(keyCode);
    }
    
    var isAllowedMetaKey = function(keyCode) {
        return [16, 17, 18].some(keyCode) || // meta
               [46, 9, 35, 36, 37, 39].some(keyCode); // backspace, delete, tab, cursors
    }

    $('.adjuster input')
        .focus(function() {
            $this = $(this);
            setActiveInputs($this);
            stripPercentSign($this);
        })
        .keydown(function(event) {
            // allow backspace, delete, tab, cursors and metakeys
            if (isAllowedMetaKey(event.keyCode)) {
            }
            // allow delete
            else if (event.keyCode == 8){
                stripPercentSign($(this));
            }
            // up increase value
            else if (event.keyCode == 38) {
                changeValue($(this), 'add1');
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
            console.debug(event.keyCode, isAllowedTrailingCharacter(event.keyCode), [16, 17, 18].none(event.keyCode));
            
            // defer evaluation when allowed trailing characters (e.g. ".", wait for the next number)
            // ignore meta keys
            if (!(isAllowedTrailingCharacter(event.keyCode) || isAllowedMetaKey(event.keyCode))) {
                setValue($(this));
            }
        })
        .blur(function() {
            setValue($(this), null);
        });

    // toggle the +/- buttons for the inputs
    var parameterPanel = $('#parameter-panel');
    var parameterPanelInputs = parameterPanel.find('input');
    parameterPanelInputs.mouseover(function() {
        parameterPanel.find('a').hide();
        parameterPanelInputs.not(":focus").removeClass('active');
        
        $(this).addClass('active').siblings('a').show();
    });
    parameterPanel.find('.inputblock').mouseleave(function() {
        $(this).find('a').hide();
    });
    parameterPanel.find('.slider').mouseenter(function() {
        $(this).parent().find('a').hide();
    });
    
    $('.add1, .add10, .sub1, .sub10').click(function(e) {
        e.preventDefault();
        $this = $(this);
        var input = $this.parent().find('input');

        setActiveInputs(input);

        changeValue(input, $this.attr('class'));
        return false;
    });

});


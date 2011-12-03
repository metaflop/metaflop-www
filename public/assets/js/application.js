$(function () {

    // set background to corresponding inputs
    var setActiveInputs = function(inputField) {
        var suffix = (inputField.id || inputField[0].id).remove(/^\w+-/);
        $('.adjuster input').removeClass('active');
        $('input[id$=' + suffix + ']').addClass('active');
    }

    // increase/decrease the inputField's value
    var changeValue = function(inputField, cssClass, addPercentSign){
        if (addPercentSign === undefined){
            addPercentSign = true;
        }

        var number = cssClass.remove(/\D/g).toNumber();
        var method = cssClass.remove(/\d+$/);

        var value = inputField.val().toNumber() || 0;

        if (method == 'add') value = value + number;
        else if (method == 'sub') value = value - number;

        setValue(inputField, value, addPercentSign);
    }

    var setValue = function(inputField, value, addPercentSign) {
        if (!value && value !== 0){
            value = inputField.val().toNumber() || 0;
        }

        if (addPercentSign) {
            value = value + '%';
        }

        inputField.val(value);

        // the linked input too
        var suffix = inputField[0].id.remove(/^\w+-/);
        $('input[id$=' + suffix + ']').val(value);


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
            console.debug(responseText, textStatus, XMLHttpRequest);
            loading.spin(false);
            image.show();
            loading.hide();
        });
    }

    $('.adjuster input')
        .focus(function() {
            $this = $(this);
            setActiveInputs($this);
            stripPercentSign($this);
        })
        .keydown(function(event) {
            // allow backspace, delete, tab, cursors
            if ([46, 9, 35, 36, 37, 39].some(event.keyCode)) {
            }
            // allow delete
            else if (event.keyCode == 8){
                stripPercentSign($(this));
            }
            // up increase value
            else if (event.keyCode == 38) {
                changeValue($(this), 'add1', false);
            }
            // down decrease value
            else if (event.keyCode == 40) {
                changeValue($(this), 'sub1', false);
            }
            else {
                // stop keypress if NaN
                if ((event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
                    event.preventDefault();
                }
            }

        })
        .keyup(function() {
            setValue($(this));
        })
        .blur(function() {
            setValue($(this), null, true);
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


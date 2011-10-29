$(function () {

    // set background to corresponding inputs
    var setActiveInputs = function(inputField) {
        var suffix = (inputField.id || inputField[0].id).remove(/^\w+-/);
        $('.adjuster input').removeClass('active');
        $('input[id$=' + suffix + ']').addClass('active');
    }
    
    // increase/decrease the inputField's value
    var changeValue = function(inputField, cssClass){
        var number = cssClass.remove(/\D/g).toNumber();
        var method = cssClass.remove(/\d+$/);
        
        var value = inputField.val().toNumber() || 0;
        
        if (method == 'add') value = value + number;
        else if (method == 'sub') value = value - number;
        
        setValue(inputField, value, true);
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
    }
        
    var stripPercentSign = function(inputField) {
        var value = inputField.val().toNumber();
        if (value || value === 0) {
            inputField.val(value);
        }
    }


    $('.adjuster input')
        .focus(function() {
            $this = $(this);
            setActiveInputs($this);
            stripPercentSign($this);
        })
        .keydown(function(event) {
            // allow backspace, delete, tab, cursors
            if ([46, 9, 37, 39].some(event.keyCode)) {
            }
            // allow delete
            else if (event.keyCode == 8){
                stripPercentSign($(this));
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
    
    $('.add1, .add10, .sub1, .sub10').click(function() {
        $this = $(this);
        var input = $this.parent().find('input');
        
        setActiveInputs(input);
        
        changeValue(input, $this.attr('class'));
    });
    
});

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
        
        value = value + '%';
        inputField.val(value);
        
        // the linked input too
        var suffix = inputField[0].id.remove(/^\w+-/);
        $('input[id$=' + suffix + ']').val(value);
    }

    $('.adjuster input').focus(function() {
        setActiveInputs(this);
    });
    
    $('.add1, .add10, .sub1, .sub10').click(function() {
        $this = $(this);
        var input = $this.parent().find('input');
        
        setActiveInputs(input);
        
        changeValue(input, $this.attr('class'));
    });

});

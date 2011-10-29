$(function () {

    // set background to corresponding inputs
    var setActiveInputs = function(element) {
        var suffix = element.id.remove(/^\w+-/);
        $('.adjuster input').removeClass('active');
        $('input[id$=' + suffix + ']').addClass('active');
    }

    $('.adjuster input').focus(function() {
        setActiveInputs(this);
    });
    
    $('.add1, .add2, .sub1, .sub2').click(function() {
        var element = $(this).parent().find('input');
        setActiveInputs(element[0]);
    });

});

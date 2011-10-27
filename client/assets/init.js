$(function () {

    var livePanelAdjuster = {
        items: [
            {class: 'body-height', title: 'body height'}
        ]
    };

    var html = $.mustache($('#livePanelAdjuster').html(), livePanelAdjuster);
    
    $('#live-panel').append(html);
    
    
    // kill the spinner
    $("#loading").spin(false);
});

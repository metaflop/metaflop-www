$(function () {

    var params = {
        capitalHeight:  { name: 'capital-height', title: 'capital height' },
        xHeight:  { name: 'x-height', title: 'x height' },
        barHeight:  { name: 'bar-height', title: 'bar height' },
        ascHeight:  { name: 'asc-height', title: 'ascender height' },
        descHeight:  { name: 'desc-height', title: 'descender height' },
        penType:  { name: 'pen-type', title: 'pen type' }
    };

    var templates = [
        // live panel
        {
            name: 'livePanelAdjuster',
            items: [ 
                params.capitalHeight,
                params.xHeight,
                params.barHeight,
                params.ascHeight,
                params.descHeight
            ],
            action : function(html) { $('#live-panel').append(html) }
        },
        // parameter panel, standard
        {
            name: 'parameterPanelAdjusterStandard',
            items: [ 
                params.capitalHeight,
                params.xHeight,
                params.barHeight,
                params.ascHeight,
                params.descHeight
            ],
            action: function(html) { $('#parameter-panel').append(html) }
        },
        // parameter panel, pen
        {
            name: 'parameterPanelAdjusterPen',
            items: [ params.penType ],
            action: function(html) { $('#parameter-panel').append(html) }
        }
    ]

    $.each(templates, function(i, template) {
        var html = $.mustache($('#' + template.name).html(), template);
        template.action(html);
    });
    
    
    // stop the spinner
    $('#loading').spin(false);
    $('.adjuster').show();
    $('#parameter-panel').show();
});

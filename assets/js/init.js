$(function () {

    var params = {
        capitalHeight:  { name: 'capital-height', title: 'capital height', css: { height: '128px', top: '6px', left: '212px' } },
        xHeight:        { name: 'x-height', title: 'x height', css: { height: '67px', top: '67px', left: '534px' } },
        barHeight:      { name: 'bar-height', title: 'bar height', css: { height: '67px', top: '67px', left: '415px' } },
        ascHeight:      { name: 'asc-height', title: 'ascender height', css: { height: '134px', top: '0', left: '616px' } },
        descHeight:     { name: 'desc-height', title: 'descender height', css: { height: '35px', top: '135px', left: '855px' } },
        penType:        { name: 'pen-type', title: 'pen type' }
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

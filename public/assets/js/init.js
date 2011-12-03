$(function () {

    var params = {
        boxHeight:      { title: 'box height', html: '<div class="static-value">100%</div>', css: { height: 'inherit', top: 'inherit', left: 'inherit' } },
        unitWidth:      { title: 'unit width', html:'', css: { height: '128px', top: '6px', left: '212px' } },
        capHeight:      { title: 'cap height', html:'', css: { height: '128px', top: '6px', left: '212px' } },
        meanHeight:     { title: 'mean height', css: { height: '67px', top: '67px', left: '534px' } },
        barHeight:      { title: 'bar height', css: { height: '67px', top: '67px', left: '415px' } },
        ascHeight:      { title: 'ascender height', css: { height: '134px', top: '0', left: '616px' } },
        descHeight:     { title: 'descender height', css: { height: '35px', top: '135px', left: '855px' } },
        horizontalInc:  { title: 'horizontal increase' },
        verticalInc:    { title: 'vertical increase' },
        superness:      { title: 'superness' },
        penType:        { title: 'pen type' },
        drawingMode:    { title: 'mode' },
        penX:           { title: 'pen x' },
        penY:           { title: 'pen y' },
        penAngle:       { title: 'pen angle' },
        contrast:       { title: 'contrast' }
    };
    
    // enhance each object with a name (used as html/css id)
    Object.extended(params).each(function(item, i){
        params[item].name = function(){ return params[item].title.dasherize(); }
    });

    var templates = [
        // live panel
        {
            name: 'livePanelAdjuster',
            items: [
                params.boxHeight,
                params.capHeight,
                params.meanHeight,
                params.barHeight,
                params.ascHeight,
                params.descHeight
            ],
            action : function(html) { $('#live-panel').append(html) }
        },
        // parameter panel, standard
        {
            name: 'parameterPanelAdjusterStandard',
            groups: [
                {
                    title: "Dimension",
                    items: [
                        params.boxHeight,
                        params.unitWidth
                    ]
                },
                {
                    title: "Proportion",
                    items: [
                        params.capHeight,
                        params.meanHeight,
                        params.barHeight,
                        params.ascHeight,
                        params.descHeight
                    ]
                },
                {
                    title: "Shape",
                    items: [
                        params.horizontalInc,
                        params.verticalInc,
                        params.superness
                    ]
                },
                {
                    title: "Drawing mode",
                    items: [
                        params.drawingMode,
                        params.penX,
                        params.penY,
                        params.penAngle,
                        params.contrast,
                    ]
                }
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

    templates.each(function(template, i) {
        // sequence numbering for tab navigation
        var sequence = template.items || Object.extended(template.groups);
        sequence.each(function(item, j) {
            item["tabindex"] = (i + 1) + "" + (j + 1);
        });
        var html = $.mustache($('#' + template.name).html(), template);
        template.action(html);
    });


    // stop the spinner
    $('#loading').spin(false);
    $('.adjuster').show();
    $('#parameter-panel').show();
});


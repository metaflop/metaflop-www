$(function () {

    var params = {
        boxHeight:      { title: 'box height', html: '<div class="static-value">100%</div>', css: { height: 'inherit', top: 'inherit', left: 'inherit' } },
        unitWidth:      { title: 'unit width', default: '1.7', css: { height: '128px', top: '6px', left: '212px' } },
        capHeight:      { title: 'cap height', default: '1', css: { height: '128px', top: '6px', left: '212px' } },
        meanHeight:     { title: 'mean height', default: '0.7', css: { height: '67px', top: '67px', left: '534px' } },
        barHeight:      { title: 'bar height', default: '0.5', css: { height: '67px', top: '67px', left: '415px' } },
        ascHeight:      { title: 'ascender height', default: '0.97', css: { height: '134px', top: '0', left: '616px' } },
        descHeight:     { title: 'descender height', default: '0.35', css: { height: '35px', top: '135px', left: '855px' } },
        horizontalInc:  { title: 'horizontal increase', default: '0.8' },
        verticalInc:    { title: 'vertical increase', default: '0.5' },
        superness:      { title: 'superness', default: '0.73' },
        penType:        { title: 'pen type', default: '' },
        drawingMode:    { title: 'mode', default: '' },
        penX:           { title: 'pen x', default: '0.3' },
        penY:           { title: 'pen y', default: '0.3' },
        penAngle:       { title: 'pen angle', default: '' },
        contrast:       { title: 'contrast', default: '1' }
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
    
    // single preview char chooser
    var sets = [];
    var number = 0;
    [
        ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
        ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'],
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
    ].each(function(set, i) {
        sets[i] = { items: [] };
        set.each(function(item, j) {
            number = number + 1;
            sets[i].items[j] = {
                title: item,
                number: number
            };
        });
    });
    
    var charChooser = $.mustache($('#charChooser').html(), {
        sets : sets
    });
        
    $('div.char-chooser').html(charChooser);

    // create a namespace for later use
    $.fn.metaflop = {
    
    };
});


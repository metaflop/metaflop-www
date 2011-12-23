$(function () {

    var params = {
        boxHeight:      { title: 'box height', html: '<div class="static-value">100%</div>' },
        unitWidth:      { title: 'unit width', default: '1.7' },
        spacing:        { title: 'spacing', default: '0.1' },

        capHeight:      { title: 'cap height', default: '1' },
        meanHeight:     { title: 'mean height', default: '0.7' },
        barHeight:      { title: 'bar height', default: '0.5' },
        ascHeight:      { title: 'ascender height', default: '0.97' },
        descHeight:     { title: 'descender height', default: '0.35' },

        overshoot:      { title: 'overshoot', default: '0.0' },
        horizontalInc:  { title: 'horizontal increase', default: '0.8' },
        verticalInc:    { title: 'vertical increase', default: '0.5' },
        apperture:      { title: 'apperture', default: '0.35' },
        superness:      { title: 'superness', default: '0.73' },

        penSize:        { title: 'pen size', default: '0.3' },
        contrast:       { title: 'contrast', default: '1' }
    };

    // enhance each object with a name (used as html/css id)
    Object.extended(params).each(function(item, i){
        params[item].name = function(){ return params[item].title.dasherize(); }
    });

    var templates = [
        // parameter panel, standard
        {
            name: 'parameterPanelAdjusterStandard',
            groups: [
                {
                    title: "Dimension",
                    items: [
                        params.boxHeight,
                        params.unitWidth,
                        params.spacing
                    ]
                },
                {
                    title: "Proportion",
                    items: [
                        params.capHeight,
                        params.meanHeight,
                        params.barHeight,
                        params.ascHeight,
                        params.descHeight,
                        params.overshoot
                    ]
                },
                {
                    title: "Shape",
                    items: [
                        params.horizontalInc,
                        params.verticalInc,
                        params.apperture,
                        params.superness
                    ]
                },
                {
                    title: "Drawing mode",
                    items: [
                        params.penSize,
                        params.contrast,
                    ]
                }
            ],
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

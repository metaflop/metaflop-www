/*
 * metaflop - web interface
 * © 2012 by alexis reigel
 * www.metaflop.com
 *
 * licensed under gpl v3
 */

$(function() {
  if (!$('#main').hasClass('modulator')) {
    return;
  }

  // create a namespace for later use
  $.fn.metaflop = {
    ready: false, // is set to true when the initial preview has been generated (i.e. the UI is ready)
    settings: {
      panelToggleDuration: 100,
      panelToggleEasing: 'easeInOutExpo',
      shareUrls: {
        twitter: 'http://twitter.com/home?status=%{title} %{url}',
        facebook: 'https://www.facebook.com/sharer/sharer.php?u=%{url}',
        email: 'mailto:?subject=metaflop font&body=%{title} %{url}',
      }
    },
    parameterPanel: $('#parameter-panel'),
    messagePanel: $('#message-panel'),
    progressPanel: $('#progress-panel'),
    typeWriterTextArea: $('#preview-typewriter').find('textarea')
  };

  var showProgress = function(message) {
    showMessage(message);
    $.fn.metaflop.progressPanel.html('&nbsp;').spin('tiny');
  };

  var hideProgress = function() {
    showMessage('');
    $.fn.metaflop.progressPanel.spin(false);
  };

  var showMessage = function(message) {
    $.fn.metaflop.messagePanel.removeClass('error');
    $.fn.metaflop.messagePanel.text(message);
  };

  var showErrorMessage = function(message) {
    hideProgress();
    showMessage(message);
    $.fn.metaflop.messagePanel.addClass('error');
    $.fn.metaflop.progressPanel.html('<i class="fa fa-warning error"></i>');
  };

  // session storage
  var setSessionStorage = function(key, value) {
    sessionStorage.setItem('history', JSON.stringify(value));
  };

  var getSessionStorage = function(key) {
    return JSON.parse(sessionStorage.getItem(key)) || [];
  };

  // undo
  var popUndoStep = function() {
    var history = getSessionStorage('history');
    // drop the current setting, while leaving at least one item
    if (history.length > 1) {
      history.pop();
    }
    var previousStep = history[history.length - 1];
    setSessionStorage('history', history);
    return previousStep;
  };

  var pushUndoStep = function(step) {
    var history = getSessionStorage('history');
    var lastStep = history[history.length - 1];
    // don't add the same setting again
    if (!Object.equal(step, lastStep)) {
      history.push(step);
    }
    setSessionStorage('history', history);
  };

  var clearHistory = function() {
    setSessionStorage('history', []);
  };

  var getHistoryLength = function() {
    return getSessionStorage('history').length;
  };

  var addUndo = function() {
    var inputFields = getInputFields();
    var currentSetting = {};
    inputFields.each(function() {
      currentSetting[this.id] = $(this).val();
    });

    pushUndoStep(currentSetting);
    toggleUndoActionDisabled();
  };

  var applyUndo = function() {
    var undoSetting = popUndoStep();
    if (undoSetting) {
      // set all values
      Object.keys(undoSetting).each(function(key) {
        var value = undoSetting[key];
        $('#' + key).val(value);
      });
      // trigger the preview
      generatePreview(false);
      toggleUndoActionDisabled();
    }
  };

  var toggleUndoActionDisabled = function() {
    var undoAction = $('#action-undo');

    if (getHistoryLength() == 1) {
      undoAction.addClass('disabled');
    }
    else {
      undoAction.removeClass('disabled');
    }
  };

  $.fn.metaflop.parameterPanel.on('click', '#action-undo',function(e) {
    e.preventDefault();

    var undoAction = $(e.target);

    if (!undoAction.hasClass('disabled')) {
      applyUndo();
    }
  });

  var getInputFields = function() {
    return $('#parameter-panel, #menu')
      .find('input:text,select')
      // exclude the slider's inputs
      .not('[id^=slider-]');
  };

  // set background to corresponding inputs
  var setActiveInputs = function(inputField) {
    var suffix = (inputField.id || inputField[0].id).remove(/^\w+-/);
    $('.adjuster input').removeClass('active');
    $('input[id$=' + suffix + ']').addClass('active');
  };

  // increase/decrease the inputField's value
  var changeValue = function(inputField, cssClass){
    var number = cssClass.remove(/\D/g).toNumber() / 100.0;
    var method = cssClass.remove(/\d+$/);

    var value = inputField.val().toNumber() || 0;

    if (method == 'add') value = value + number;
    else if (method == 'sub') value = value - number;

    setValue(inputField, value);
  };

  var setValue = function(inputField, value) {
    if (!value && value !== 0){
      value = inputField.val() || 0;
    }

    value = String(value).replace(',', '.').toNumber();

    inputField.val(value);
    // add init class to prevent tooltips and recursion
    inputField.addClass('init');

    var sliderInput = getTwinInput(inputField);
    // update the associated slider too
    if (value >= sliderInput.attr('data-range-from') && value <= sliderInput.attr('data-range-to')) {
      sliderInput.val(value);
      fdSlider.updateSlider(sliderInput[0].id);
    }

    generatePreview();
  };

  // finds the corresponding counterpart input field
  // for a "param-" the corresponding "slider-" and vice versa
  // input is a jquery object or a dom element
  var getTwinInput = function(input) {
    var element = input.length === undefined ? input : input[0];
    var id = element.id.has('slider') ?
      element.id.replace('slider-', 'param-') :
      element.id.replace('param-', 'slider-');
    return $('#' + id);
  };

  var stopRequest = function() {
    if (window.stop !== undefined) {
      window.stop();
    }
    else if (document.execCommand !== undefined) {
      document.execCommand("Stop", false);
    }
  };

  // don't create new url each time for unchanged setting
  // makes an ajax request with async:false, as with the copy
  // clipboard callback from the flahs clippy async doesn't work.
  // TODO: as this is deprecated as of 1.8, find a new solution
  var callWithFontHash = function(success, complete) {
    complete = complete || function() {
      hideProgress();
    };
    success = success || function() {};

    if ($.fn.metaflop.shortenendUrl) {
      success($.fn.metaflop.shortenendUrl);
      complete();
    }
    else {
      $.ajax({
        async: false,
        url: '/modulator/font/create' + $.fn.metaflop.queryString,
        success: function(data) {
          $.fn.metaflop.shortenendUrl = data;
          success(data);
        },
        complete: function() {
          complete();
        }
      });
    }
  };

  var createQueryString = function() {
    var inputFields = getInputFields();

    $.fn.metaflop.queryString = '?' +
      $.makeArray(inputFields).map(function(element){
        return element.id.remove('param-') + '=' + $(element).val();
      }).join("&");

    return $.fn.metaflop.queryString;
  };

  var generatePreviewCall = function(addUndoStep) {
    addUndoStep = addUndoStep === undefined ? true : addUndoStep;
    var content = $('.box:visible');

    // clear cached shortend url
    $.fn.metaflop.shortenendUrl = null;

    // there is already a request on its way -> cancel it
    if ($.fn.metaflop.preloadImageInProgress) {
      stopRequest();
    }
    else {
      content.fadeTo(0, 0.5);
      showProgress('Updating previews...');

      $.fn.metaflop.preloadImageInProgress = true;
    }

    $.ajax({
      url: '/modulator/preview' + createQueryString(),
      complete: function() {
        $.fn.metaflop.preloadImageInProgress = false;

        if (!$.fn.metaflop.ready) {
          // add tooltips to the sliders (only after the initial preview has been loaded,
          // we don't want to show them prematurely)
          $('.fd-slider-handle').tipsy({ title: 'aria-valuetext', gravity: 's' });
          $.fn.metaflop.ready = true;
        }

        // autogrow textarea (do this in any case, as on initial load
        // we need to do this at least once)
        $.fn.metaflop.typeWriterTextArea.autogrow();
      },
      success: function(data) {
        if (addUndoStep) {
          addUndo();
        }
        hideProgress();
        content.fadeTo(0, 1);

        // TODO only find once initially
        for (var i = 0; i < document.styleSheets.length; ++i) {
          var styleSheet = document.styleSheets[i];
          if (styleSheet.ownerNode.id == 'font-face-css') {
            styleSheet.deleteRule(0);

            rule =
              "@font-face {" +
              "    font-family: 'preview';" +
              "    src: url(data:font/opentype;base64," + data + ") format('opentype');" +
              "}";
            styleSheet.insertRule(rule, 0);

            break;
          }
        }
      },
      error: function(jqXHR) {
        showErrorMessage(jqXHR.responseText);
      }
    });
  };

  var timeout;
  var generatePreview = function(addUndoStep){
    if (timeout) clearTimeout(timeout);
    timeout = setTimeout(function() { generatePreviewCall(addUndoStep); }, 300);
  };

  var isAllowedTrailingCharacter = function(keyCode) {
    return [190, 188].some(keyCode);
  };

  var isAllowedMetaKey = function(keyCode) {
    return [16, 17, 18].some(keyCode) || // meta
      [46, 9, 35, 36, 37, 39].some(keyCode); // backspace, delete, tab, cursors
  };

  $.fn.metaflop.parameterPanel.on('focus', '.adjuster input.param', function() {
    var $this = $(this);
    setActiveInputs($this);
  })
  .on('keydown', '.adjuster input.param', function(event) {
    // allow backspace, delete, tab, cursors and metakeys
    if (isAllowedMetaKey(event.keyCode)) {
    }
    // allow delete
    else if (event.keyCode == 8){
    }
    // up increase value
    else if (event.keyCode == 38) {
    }
    // down decrease value
    else if (event.keyCode == 40) {
      changeValue($(this), 'sub1');
    }
    // allow decimal point (".", ",")
    else if (isAllowedTrailingCharacter(event.keyCode)) {
    }
    else {
      // stop keypress if NaN
      if ((event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
        event.preventDefault();
      }
    }

  })
  .on('keyup', '.adjuster input.param', function(event) {
    // defer evaluation when allowed trailing characters (e.g. ".", wait for the next number)
    // ignore meta keys
    if (!(isAllowedTrailingCharacter(event.keyCode) || isAllowedMetaKey(event.keyCode))) {
      setValue($(this));
    }
  })
  .on('blur', '.adjuster input.param', function() {
    setValue($(this), null);
  });

  // parameter list dropdown menus
  var initParameterDropdowns = function() {
    $.fn.metaflop.parameterPanel.find('select:visible').dropdownpanel({
      panelToggleDuration: $.fn.metaflop.settings.panelToggleDuration,
      onClicked: generatePreview
    });
  };
  initParameterDropdowns();

  var updateAnatomy = function() {
    var fontface = $('#param-fontface').val();
    $('#info-panel img').removeClass('active');
    $('#info-panel img[data-fontface="' + fontface + '"]').addClass('active');
  };

  // select typeface
  $('#menu').find('select:visible').dropdownpanel({
    panelToggleDuration: $.fn.metaflop.settings.panelToggleDuration,
    onClicked: function() {
      showProgress('Loading parameter panel...');
      $.fn.metaflop.parameterPanel.fadeTo(0, 0.5);

      clearHistory();

      var activeNerdMode = $('.parameter-panel-mode-toggle.active.adjusters');

      $.ajax({
        url: '/modulator/char_chooser/partial' + createQueryString(),
        success: function(data) {
          $('#preview-single').find('div.char-chooser').html(data);
          $.ajax({
            url: '/modulator/parameter_panel/partial' + createQueryString(),
            success: function(data) {
              $('#parameter-panel').html(data);
              initSliders();
              initParameterDropdowns();
              resetParameters();
              if (activeNerdMode.length > 0) togglePanelMode(activeNerdMode);
              $.fn.metaflop.parameterPanel.fadeTo(0, 1);
              generatePreview();
              updateAnatomy();
            },
            error: function() {
              hideProgress();
              showMessage('The parameter panel could not be loaded.');
            }
          });
        }
      });
    }
  });

  // reset parameter values
  var resetParameters = function(){
    $('.adjuster input.param').each(function() {
      var $this = $(this);

      var sliderInput = getTwinInput($this);
      // add init class to prevent tooltips
      $this.addClass('init');

      setValue($this, sliderInput.attr('data-default'));
    });
  };

  $('#action-reset-values').click(function(e) {
    e.preventDefault();

    resetParameters();

    return false;
  });

  // randomize
  $('#action-randomize-values').click(function(e) {
    e.preventDefault();

    // randomize the slider inputs
    $('#parameter-panel input.param').each(function() {
      var $this = $(this);

      var sliderInput = getTwinInput($this);
      // add init class to prevent tooltips
      $this.addClass('init');

      var from = sliderInput.attr('data-range-from');
      var to = sliderInput.attr('data-range-to');
      var value = Number.random(from * 100, to * 100) / 100;

      setValue($this, value);
    });

    // randomize the dropdowns
    $('#parameter-panel select').each(function() {
      $this = $(this);

      options = $this.find('option');
      var optionsIndex = Number.random(0, options.length - 1);

      var value = $(options[optionsIndex]).val();
      $this.val(value).trigger('change');
    });

    return false;
  });

  // gets the absolute shareable font url for the
  var getFontUrl = function(shortenendUrl) {
    var url = $.url();
    var baseUrl = url.attr('source').remove(url.attr('relative'));
    return baseUrl + "/modulator/font/" + shortenendUrl;
  };

  // share the current settings
  // this function is called from flash clippy
  $.fn.metaflop.getFlashShareUrl = function() {
    var container = $('#action-share-url');

    if (!$.fn.metaflop.shortenendUrl) {
      showProgress('Generating share url...');

      callWithFontHash();
    }

    return getFontUrl($.fn.metaflop.shortenendUrl);
  };

  $('#action-share-url a').click(function(e) {
    e.preventDefault();
    var $this = $(this);

    showProgress('Generating share url...');

    var success = function(data) {
      var url = getFontUrl(data);
      var title = 'I created a nice metaflop font!';
      var type = $this.attr('data-type');

      var link = $.fn.metaflop.settings.shareUrls[type]
        .replace('%{title}', title)
        .replace('%{url}', url);

      if (type == 'email') {
        window.location = link;
      }
      // open in new window
      else {
        window.open(link);
      }
    };

    callWithFontHash(success);
  });

  // export the font
  $('.export-font').click(function(e) {
    e.preventDefault();

    var $this = $(this);
    showProgress('Exporting the font...');

    callWithFontHash(function(data) {
      var url = "/modulator/export/font/" + $this.attr('data-type') + "/" + $('#param-fontface').val() + "/" + data;

      // make an ajax request first, only after that redirect to force the download, because:
      // 1. we can show a spinner while the export gets generated
      // 2. we can handle errors and display a message
      $.ajax({
        url: url,
        success: function(data) {
          hideProgress();
          window.location = url;
        },
        error: function(jqXHR) {
          showErrorMessage(jqXHR.responseText);
        }
      });
    }, function() {}); // don't call "hideProgress"
  });

  // toggle the +/- buttons for the inputs
  $.fn.metaflop.parameterPanel.on('mouseover', '.adjuster', function() {
    var $this = $(this);
    $.fn.metaflop.parameterPanel.find('.adjuster a').hide();
    $this.find('a').show();

    $.fn.metaflop.parameterPanel.find('input').removeClass('active');
    $this.find('input').addClass('active');
  });
  $.fn.metaflop.parameterPanel.on('mouseleave', '.inputblock', function() {
    $(this).find('.adjuster a').hide();
  });


  $.fn.metaflop.parameterPanel.on('click', '.add1, .add10, .sub1, .sub10', function(e) {
    e.preventDefault();
    var $this = $(this);
    var input = $this.parent().find('input');

    setActiveInputs(input);

    changeValue(input, $this.attr('class'));
    return false;
  });

  // sliders
  var updateValue = function(cbObj) {
    // update the associated input field
    var input = getTwinInput(cbObj.elem);

    if (input.hasClass('init')) {
      input.removeClass('init');
    }
    else {
      input.val(cbObj.value);
      input.blur();

      // update the tooltip
      $(cbObj.elem).siblings().find('.fd-slider-handle').tipsy('show');
    }
  };
  var initSliders = function() {
    $.fn.metaflop.parameterPanel.find('.slider input').each(function() {
      fdSlider.createSlider({
        inp: this,
        step: "0.01",
        maxStep: 1, // (for keyboard users)
        min: $(this).attr('data-range-from'),
        max: $(this).attr('data-range-to'),
        animation:"timed",
        hideInput: true,
        callbacks:{
          "change":[updateValue]
        }
      });
    });
  };
  initSliders();

  // character chooser for single preview
  var charChooser = $('div.char-chooser');
  charChooser.on('click', 'a', function(e) {
    e.preventDefault();

    $this = $(this);
    var box = $this.parents('.box');
    charChooser.find('a').removeClass('active');
    $this.addClass('active').blur();
    box.find('.preview-text').text($this.text());

    return false;
  });

  $('a.char-chooser').click(function(e) {
    e.preventDefault();

    var $this = $(this);
    var div = $('div.char-chooser');
    var activeItem = div.find('li.active');
    var items = div.find('li');

    var nextItem = $($this.hasClass('right') ?
        activeItem.next()[0] || items.first() :
        activeItem.prev()[0] || items.last());

    items.removeClass('active');
    nextItem.addClass('active');
    div.scrollTo(nextItem, 400, { easing: 'easeInOutExpo', axis: "x" });

    return false;
  });

  var togglePanelMode = function(element) {
    var adjusters = $.fn.metaflop.parameterPanel.find('.adjuster');
    var sliders = $.fn.metaflop.parameterPanel.find('.slider');

    $('.parameter-panel-mode-toggle').removeClass('active');
    element.addClass('active');

    if (element.hasClass('sliders')) {
      sliders.show();
      adjusters.hide();
    }
    else {
      adjusters.show();
      sliders.hide();
    }
  };

  // switch basic/pro mode for parameter panel
  $.fn.metaflop.parameterPanel.on('click', '.parameter-panel-mode-toggle',function(e) {
    e.preventDefault();

    var $this = $(this);

    togglePanelMode($this);

    $this.blur();
  });

  // toggle the information header
  var informationToggle = $('#menu').find('.toggle-info-panel');
  informationToggle.click(function(e) {
    e.preventDefault();

    var $this = $(this);

    if (!$this.is('.active')) {
      informationToggle.toggleClass('active');
      $('#info-panel').slideToggle(
          $.fn.metaflop.settings.panelToggleDuration,
          $.fn.metaflop.settings.panelToggleEasing);
    }

    $this.blur();
  });

  // toggle the glyph/chart preview
  var glyphChartPreviewToggle = $('#menu').find('.toggle-glyph-chart-preview');
  glyphChartPreviewToggle.click(function(e) {
    e.preventDefault();

    var $this = $(this);
    if (!$this.is('.active')) {
      glyphChartPreviewToggle.toggleClass('active');
      $('#preview-single, #preview-chart').slideToggle(
          $.fn.metaflop.settings.panelToggleDuration,
          $.fn.metaflop.settings.panelToggleEasing);
    }

    $this.blur();
  });

  // change type writer font size
  var typeWriterFontSizeDropdown= $('#typewriter-font-size');
  typeWriterFontSizeDropdown.dropdownpanel({
    panelToggleDuration: $.fn.metaflop.settings.panelToggleDuration,
    onClicked: function() {
      // grey out the typewriter
      $('#preview-typewriter').fadeTo(0, 0.5);
      // wait for the dropdown
      // to have finished its animation.
      setTimeout(function() {
        $('#preview-typewriter').fadeTo(0, 1);
      }, $.fn.metaflop.settings.panelToggleDuration);

      $.fn.metaflop.typeWriterTextArea.css('font-size', typeWriterFontSizeDropdown.val() + 'px');

      // force autoload to redraw
      $.fn.metaflop.typeWriterTextArea.autogrow();
    }
  });

  // change typewriter text
  var typeWriterFontTextDropdown = $('#typewriter-text');
  typeWriterFontTextDropdown.dropdownpanel({
    panelToggleDuration: $.fn.metaflop.settings.panelToggleDuration,
    onClicked: function() {
      // grey out the typewriter
      $('#preview-typewriter').fadeTo(0, 0.5);
      // wait for the dropdown
      // to have finished its animation.
      setTimeout(function() {
        $('#preview-typewriter').fadeTo(0, 1);
      }, $.fn.metaflop.settings.panelToggleDuration);

      $.fn.metaflop.typeWriterTextArea.val(typeWriterFontTextDropdown.val());

      // force autoload to redraw
      $.fn.metaflop.typeWriterTextArea.autogrow();
    }
  });

  // insertRule is not supported by IE < 9, which also don't
  // support otf font faces
  if (Modernizr.fontface && document.styleSheets[0].insertRule) {
    clearHistory();
    // load the first image
    generatePreview();
  }
  else {
    var unsupported = $(
        '<div id="modulator-unsupported" style="height: ' +
        $('#main').height() +
        'px;"><p>Your browser <a href="http://caniuse.com/ttf">' +
        'is not supported</a> by our modulator.<br />' +
        'Please try to upgrade to a more contemporary browser.</p>' +
        '</div>');
    $('#main').append(unsupported);
    unsupported.fadeTo(0, 0.9);
  }
});

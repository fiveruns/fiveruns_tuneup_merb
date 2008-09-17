var _window   = window.parent,    // window obj of the main page
    page = $(_window.document); // document obj of the main page
        
$(window).ready(function() {
  
  page.find('#tuneup .with_children .tuneup-title a.tuneup-step-name').toggle(
    // Note: Simple 'parent' lookup with selector doesn't seem to work
    function() { TuneUp.parentStepOf($(this)).addClass('tuneup-opened'); },
    function() { TuneUp.parentStepOf($(this)).removeClass('tuneup-opened'); }                
  );
  
  page.find('.tuneup-step-extras').hide();
  page.find('#tuneup .with_children .tuneup-title a.tuneup-step-extras-link').toggle(
    function() { TuneUp.parentStepOf($(this)).find('> .tuneup-step-extras').show(); },
    function() { TuneUp.parentStepOf($(this)).find('> .tuneup-step-extras').hide(); }
  );
  
  page.find('#fiveruns_tuneup_state').toggle(
    function () {
      var link = $(this);
      $.getScript('/fiveruns_tuneup_merb/off.js', function() {
        link.html('Turn On');
      });
    },
    function () {
      var link = $(this);
      $.getScript('/fiveruns_tuneup_merb/on.js', function() {
        link.html('Turn Off');
      });
    }
  );
  TuneUp.adjustFixedElements(page);
});

var TuneUp = {
  parentStepOf: function(e) {
    return e.parent().parent().parent();
  },
  adjustFixedElements: function(e) {
    page.find('*').each(function() {
      if($(this).css({position: 'fixed'})) {
        TuneUp.adjustElement(e);
      }
  	});
  },
  adjustElement: function(e) {
    var element = $(e)
  	var top = parseFloat(element.css('top') || 0);
  	var adjust = 0;
  	if(!element.hasClass('tuneup-flash-adjusted')) {
      adjust = page.find('#tuneup-flash.tuneup-show').length ? 27 : -27;
    	element.addClass('tuneup-flash-adjusted');
    }
  	if (element.hasClass('tuneup-adjusted')) {
  	  element.css({top: (top + adjust) + 'px'});
  	} else {
  	  element.css({top: (top + 50 + adjust) + 'px'});
  		element.addClass('tuneup-adjusted');
  	}
  },
  adjustAbsoluteElements: function(base) {
    $(base).find('> *[id!=tuneup]').each(function() {
      switch($(this).css('position')) {
      case 'absolute':
        TuneUp.adjustElement(this);
    		TuneUp.adjustAbsoluteElements(this);
        break;
      case 'relative':
        // Nothing
        break;
      default:
        TuneUp.adjustAbsoluteElements(this);
      }
    });
  }
}
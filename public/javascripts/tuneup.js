var _window   = window.parent,    // window obj of the main page
    page = $(_window.document); // document obj of the main page
        
$(window).ready(function() {
  
  page.find('#tuneup ul ul.children').hide();
  page.find('#tuneup ul > li > ul.children ul.children').slice(0, 2).show().each(function() {
    $(this).parent('li').addClass('disclosed');
  });
  page.find('#tuneup li > span').toggle(
    function() { var parent = $(this).parent('li'); if(parent.hasClass('parent)')) parent.addClass('disclosed').find('> ul.children').show(); },
    function() { var parent = $(this).parent('li'); if(parent.hasClass('parent)')) parent.removeClass('disclosed').find('> ul.children').hide(); }                
  );

  var bars = page.find('#tuneup .bar');
  var total = page.find(bars[0]).attr('title');
  
  page.find('#tuneup ul.bar li.mvc').each(function() {
    var barTime = $(this).parent('.bar').attr('title');
    var maxWidth = barTime / total * 200;
    var portion = $(this).attr('title');
    var width = maxWidth * portion;
    $(this).attr('title', (barTime * portion).toFixed(1) + 'ms / ' + (barTime / total * portion * 100).toFixed(2) + '%');
    $(this).css({
      width:      width + 'px'
    });
    if (width < 12)
      $(this).html('&nbsp;');
  });
  $(bars).each(function() {
    var barTime = $(this).attr('title');
    var width = barTime / total * 200;
    $(this).css({marginRight: (200 - width) + 'px'});
  });
  // TuneUp.adjustFixedElements(page);
});

var TuneUp = {
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
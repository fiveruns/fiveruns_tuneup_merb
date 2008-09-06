$(document).ready(function() {
  var colors = {
    M: '#FF9800',
    V: 'green',
    C: 'blue'
  };
  $('#tuneup ul ul.children').hide();
  $('#tuneup li').toggle(
     function() { if($(this).find('ul').length > 1) $(this).addClass('disclosed').find('> ul.children').show(); },
     function() { if($(this).find('ul').length > 1) $(this).removeClass('disclosed').find('> ul.children').hide(); }                
  );
  var bars = $('#tuneup .bar');
  var total = $(bars[0]).attr('title');

  $('#tuneup ul.bar li.mvc').each(function() {
    var barTime = $(this).parent('.bar').attr('title');
    var maxWidth = barTime / total * 200;
    var portion = $(this).attr('title');
    var width = maxWidth * portion;
    $(this).attr('title', (barTime * portion).toFixed(1) + 'ms / ' + (barTime / total * portion * 100).toFixed(2) + '%');
    $(this).css({
      width:      width + 'px',
      background: colors[$(this).html()],
    });
    if (width < 12)
      $(this).html('&nbsp;');
  });
  $(bars).each(function() {
    var barTime = $(this).attr('title');
    var width = barTime / total * 200;
    $(this).css({marginRight: (200 - width) + 'px'});
  });
});
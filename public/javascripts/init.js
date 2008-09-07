// Vanilla wait-for-DOM
setTimeout(function() {
	var iframe = document.createElement('iframe');
	iframe.src = '/slices/fiveruns_tuneup_merb/javascripts/sandbox.html';
	
	var style        = iframe.style;
	style.visibility = 'hidden';
	style.width      = '0';
	style.height     = '0';
	
	document.body.appendChild(iframe);
}, 50);
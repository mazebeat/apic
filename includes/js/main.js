$(document).ready(function () {
	/* Hack related to: https://github.com/twbs/bootstrap/issues/10236 */
	$(window).on('load resize', function () {
		$(window).trigger('scroll');
	});

	/* Smooth scrolling */
	$('a.scrollto').on('click', function (e) {
		e.preventDefault();

		try {
			var target = this.hash;
			$('body').scrollTo(target, 800, { offset: 0, 'axis': 'y' });
		}
		catch (ex) {
			console.error(ex);
		}
	});	
});

/* Prism.plugins.NormalizeWhitespace.setDefaults({
	'remove-trailing': true,
	// 'remove-indent': true,
	'left-trim': true,
	'right-trim': true,
	// 'break-lines': 80,
	// 'indent': 0,
	// 'remove-initial-line-feed': true,
	// 'tabs-to-spaces': 4,
	// 'spaces-to-tabs': 4
} );*/
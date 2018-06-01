jQuery(document).ready(function($) {
    /* Hack related to: https://github.com/twbs/bootstrap/issues/10236 */
    $(window).on('load resize', function() {
        $(window).trigger('scroll');
    });

    /* Smooth scrolling */
    $('a.scrollto').on('click', function(e) {
        e.preventDefault();

        try {
            var target = this.hash;
            $('body').scrollTo(target, 800, {
                offset: 5,
                'axis': 'y'
            });
        } catch (ex) {
            console.error(ex);
        }
    });


    $(window).scroll(function() {
        if ($(this).scrollTop() < 200) {
            $('#smoothup').fadeOut();
        } else {
            $('#smoothup').fadeIn();
        }
    });

    $('#smoothup').on('click', function() {
        $('html, body').animate({
            opacity: 0.5,
           	scrollTop: 0,
        }, "fast",
        function() {
            $(this).fadeTo("fast", 1);
        });
        return false;
    });
});
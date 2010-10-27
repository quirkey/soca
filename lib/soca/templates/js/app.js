(function($) {

  var app = $.sammy('#container', function() {
    this.use('Couch');

  });

  $(function() {
    app.run();
  });

})(jQuery);

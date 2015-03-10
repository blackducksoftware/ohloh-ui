String.prototype._f = function(d) {
  var format = this;
  for(var p in d) {
    if( d.hasOwnProperty(p) && d[p] ) {
      format = format.replace( new RegExp('[\\$|#]\\{' + p + '}','ig'), d[p].toString());
    }
  }
  return format;
};

(function($){
  $(function() {
    ohloh.ui.init();
  });
})(jQuery);

var ohloh = (function builder($) {
  return {
    ui: {
      init: function(){
        var $scope = $('.ux-dropdown');
        var $search_text_field = $scope.find('.text');
        var dropdownHead = $('a span.selection', $scope);
        var getSelectedValue = function() {
          return dropdownHead.first().attr('val');
        };
        $('.dropdown-menu li a', $scope).click(function() {
          var selectedText = $(this).attr('val')
          dropdownHead.attr('val',selectedText)
          dropdownHead.html( $(this).html() )
          dropdownHead.parents('form').attr('action',selectedText)
          if(selectedText != "//code.ohloh.net/search"){
            dropdownHead.parents('form').removeAttr('target');
          }
        });
        $('ul.dropdown-menu li a', $scope).on('click', 'a', function() {
          var $this = $(this);
          var section_name = $this.text();

          $('ul.dropdown-menu li a', $scope).removeClass('selected');

          $this.addClass('selected');

          $('.ux-dropdown a span.selection', $scope).html(section_name);
        });

        $(document).ajaxStop($.unblockUI);

        if( (/\/p(\/|\?|$)/ig).test(window.location.href) ) {
          $('a', $scope).removeClass('default');
          $('a[val="p"]', $scope).addClass('default');
        }

        if( (/\/orgs(\/|\?|$)/ig).test(window.location.href) ) {
          $('a', $scope).removeClass('default');
          $('a[val="orgs"]', $scope).addClass('default');
        }

        if( (/\/(posts|forums)(\/|\?|$)/ig).test(window.location.href) ) {
          $('a', $scope).removeClass('default');
          $('a[val="posts"]', $scope).addClass('default');
        }

        if( (/\/(people|accounts|committers)(\/|\?|$)/ig).test(window.location.href) ) {
          $('a', $scope).removeClass('default');
          $('a[val="people"]', $scope).addClass('default');
        }

        $('a.default', $scope).trigger('click');

        $('.dropdown-menu li a', $scope).on('click', 'a', function(){
          $('input[name="query"].search').trigger('click').focus();
        });

        if( (/\?[query]=.{1,}/ig).test(window.location.href) ) {
          var q = window.location.href.split('?')[1].split('=')[1];

          if( q.indexOf('&') > -1 ) {
            q = q.split('&')[0];
          }
        }

        $search_text_field.keydown(function(e){
          if(e.which == 13) {
            e.preventDefault();
            $(this).siblings('.submit').trigger('click');
            return false;
          }
        });

        $search_text_field.siblings('.submit').click(function(e) {
          var search_term = $.trim($search_text_field.val());

          if(search_term.length > 0) {
            e.preventDefault();

            var section = getSelectedValue(),
              url_format = "/#{activator}?"+$search_text_field.attr('name')+"=#{query}";

            var data = {
              activator: section,
              query: search_term
            };

            if($search_text_field.attr('name') == 's')
              url_format += "&ref=Open%20Hub";

            if(window.location.href.indexOf("sort=") > -1) {
              sort_value = window.location.href.split('sort=')[1].split('&')[0];
              url_format += "&sort=" + sort_value;
            }

            window.location.href = url_format._f(data);
          }

          return false;
        });
      }
    },
    load: function(){
      this.ui.init();
    }
  };
})(jQuery);

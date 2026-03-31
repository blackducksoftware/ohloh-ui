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
        var $search_text_field = $scope.find('.text').add($scope.siblings('.header-search-input'));
        var dropdownHead = $('button span.selection, a span.selection', $scope);
        $('.dropdown-menu .dropdown-item', $scope).click(function() {
          var selectedText = $(this).attr('val')
          dropdownHead.attr('val',selectedText)
          dropdownHead.html( $(this).html() )
          // Do NOT set form action here; URL will be built on submit
          // Update active class
          $('.dropdown-menu .dropdown-item', $scope).removeClass('active')
          $(this).addClass('active')
          if(selectedText != "//code.ohloh.net/search"){
            dropdownHead.parents('form').removeAttr('target');
          }
        });
        $('.dropdown-menu .dropdown-item', $scope).on('click', function() {
          var $this = $(this);
          var section_name = $this.text();

          $('.dropdown-menu .dropdown-item', $scope).removeClass('selected');

          $this.addClass('selected');

          $('.ux-dropdown button span.selection', $scope).html(section_name);
        });

        $(document).ajaxStop($.unblockUI);

        if( (/\/p(\/|\?|$)/ig).test(window.location.href) ) {
          $('.dropdown-item', $scope).removeClass('default');
          $('.dropdown-item[val="p"]', $scope).addClass('default');
        }

        if( (/\/orgs(\/|\?|$)/ig).test(window.location.href) ) {
          $('.dropdown-item', $scope).removeClass('default');
          $('.dropdown-item[val="orgs"]', $scope).addClass('default');
        }

        if( (/\/(posts|forums)(\/|\?|$)/ig).test(window.location.href) ) {
          $('.dropdown-item', $scope).removeClass('default');
          $('.dropdown-item[val="posts"]', $scope).addClass('default');
        }

        if( (/\/(people|accounts|committers)(\/|\?|$)/ig).test(window.location.href) ) {
          $('.dropdown-item', $scope).removeClass('default');
          $('.dropdown-item[val="people"]', $scope).addClass('default');
        }

        $('.dropdown-item.default', $scope).trigger('click');

        $('.dropdown-menu .dropdown-item', $scope).on('click', function(){
          $('input[name="query"].search').trigger('click').focus();
        });

        // Handle custom sort dropdown
        $('.custom-sort-dropdown .sort-dropdown-item').on('click', function(e) {
          e.preventDefault();
          var $item = $(this);
          var $dropdown = $item.closest('.custom-sort-dropdown');
          var selectedValue = $item.data('value');
          var selectedLabel = $item.text();

          // Update button text
          $dropdown.find('.selection').text(selectedLabel).data('value', selectedValue);

          // Update hidden input
          $dropdown.find('.sort-value-input').val(selectedValue);

          // Update active class
          $dropdown.find('.sort-dropdown-item').removeClass('active');
          $item.addClass('active');

          // Submit form
          $dropdown.closest('form').submit();
        });

        // Handle search input with cancel button
        $('#query').on('input', function() {
          var $input = $(this);
          var $cancelBtn = $input.siblings('.search-cancel-btn');

          if ($input.val().length > 0) {
            $cancelBtn.show();
          } else {
            $cancelBtn.hide();
          }
        });

        // Handle search cancel button
        $('.search-cancel-btn').on('click', function() {
          var $input = $('#query');
          $input.val('');
          $(this).hide();
          $input.focus();
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
            $(this).siblings('.submit, .header-search-btn').trigger('click');
            return false;
          }
        });

        $search_text_field.siblings('.submit, .header-search-btn').click(function(e) {
          var $btn = $(this);
          var $field = $btn.siblings('.text, .header-search-input');
          var $local_scope = $btn.closest('form').find('.ux-dropdown');
          var localDropdownHead = $('button span.selection, a span.selection', $local_scope);
          var search_term = $.trim($field.val());

          if(search_term.length > 0) {
            e.preventDefault();

            var section = localDropdownHead.first().attr('val');
            var url = "/" + section + "?query=" + encodeURIComponent(search_term);

            if($field.attr('name') == 's')
              url += "&ref=Open%20Hub";

            if(window.location.href.indexOf("sort=") > -1) {
              sort_value = window.location.href.split('sort=')[1].split('&')[0];
              url += "&sort=" + sort_value;
            }

            window.location.href = url;
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

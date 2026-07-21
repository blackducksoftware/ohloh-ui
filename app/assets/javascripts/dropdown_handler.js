// Dropdown menu handler for logged user menu
(function($) {
  'use strict';

  function initDropdown() {
    var $dropdown = $('#logged_user_menu');

    if ($dropdown.length === 0) {
      return; // Dropdown not found (user not logged in)
    }

    var $toggle = $dropdown.find('.dropdown-toggle');
    var $menu = $dropdown.find('.dropdown-menu');

    // Remove any existing event handlers
    $toggle.off('click.userDropdown');
    $(document).off('click.userDropdown keydown.userDropdown');
    $menu.find('a').off('click.userDropdown');

    // Toggle dropdown on click
    $toggle.on('click.userDropdown', function(e) {
      e.preventDefault();
      e.stopPropagation();

      var wasOpen = $dropdown.hasClass('open');

      // Close all dropdowns first
      $('.dropdown').removeClass('open');

      // Toggle this dropdown
      if (!wasOpen) {
        $dropdown.addClass('open');
      }

      return false;
    });

    // Close dropdown when clicking outside
    $(document).on('click.userDropdown', function(e) {
      var $target = $(e.target);
      if (!$dropdown.is($target) && $dropdown.has($target).length === 0) {
        $dropdown.removeClass('open');
      }
    });

    // Close dropdown when clicking a menu item
    $menu.find('a').on('click.userDropdown', function() {
      setTimeout(function() {
        $dropdown.removeClass('open');
      }, 150);
    });

    // Close dropdown on ESC key
    $(document).on('keydown.userDropdown', function(e) {
      if (e.keyCode === 27) {
        $dropdown.removeClass('open');
      }
    });
  }

  // Initialize when DOM is ready
  $(document).ready(function() {
    initDropdown();
  });

  // Re-initialize on Turbolinks page change
  $(document).on('page:change', function() {
    initDropdown();
  });

})(jQuery);

// Language Dropdown Menu Handler
$(document).on('click', '.language-dropdown-trigger', function(e) {
  e.preventDefault();
  e.stopPropagation();

  var $trigger = $(this);
  var $wrapper = $trigger.closest('.language-dropdown-wrapper');
  var $menu = $wrapper.find('.language-dropdown-menu');
  var $icon = $trigger.find('i');

  // Close all other language dropdowns
  $('.language-dropdown-menu.active').not($menu).removeClass('active');
  $('.language-dropdown-trigger i').removeClass('icon-chevron-up').addClass('icon-chevron-down');

  // Toggle this dropdown
  $menu.toggleClass('active');

  // Update chevron icon
  if ($menu.hasClass('active')) {
    $icon.removeClass('icon-chevron-down').addClass('icon-chevron-up');
  } else {
    $icon.removeClass('icon-chevron-up').addClass('icon-chevron-down');
  }
});

// Handle language dropdown item selection
$(document).on('click', '.language-dropdown-menu .dropdown-item', function(e) {
  e.preventDefault();
  e.stopPropagation();

  var $item = $(this);
  var $menu = $item.closest('.language-dropdown-menu');
  var $wrapper = $menu.closest('.language-dropdown-wrapper');
  var $trigger = $wrapper.find('.language-dropdown-trigger');
  var $selection = $trigger.find('.selection');
  var $input = $wrapper.find('.language-input');
  var $icon = $trigger.find('i');

  // Get selected value and text
  var selectedValue = $item.data('value');
  var selectedText = $item.text().trim();

  // Update display and input
  $selection.text(selectedText);
  $input.val(selectedValue);

  // Update active state
  $menu.find('.dropdown-item').removeClass('active');
  $item.addClass('active');

  // Close dropdown
  $menu.removeClass('active');
  $icon.removeClass('icon-chevron-up').addClass('icon-chevron-down');
});

// Close language dropdowns when clicking outside
$(document).on('click', function(e) {
  if (!$(e.target).closest('.language-dropdown-wrapper').length) {
    var $openMenu = $('.language-dropdown-menu.active');
    if ($openMenu.length) {
      $openMenu.removeClass('active');
      $openMenu.closest('.language-dropdown-wrapper').find('.language-dropdown-trigger i')
        .removeClass('icon-chevron-up').addClass('icon-chevron-down');
    }
  }
});

// Initialize active item styling on page load
$(document).on('page:change', function() {
  $('.language-dropdown-wrapper').each(function() {
    var $wrapper = $(this);
    var $input = $wrapper.find('.language-input');
    var selectedValue = $input.val();

    if (selectedValue) {
      // Find and mark the matching dropdown item as active
      $wrapper.find('.dropdown-item').each(function() {
        var $item = $(this);
        if ($item.data('value') === selectedValue) {
          $item.addClass('active');
          // Update trigger display
          var $selection = $wrapper.find('.language-dropdown-trigger .selection');
          $selection.text($item.text().trim());
        }
      });
    }
  });
});

// Project Swimlanes - Show More/Less functionality
function initSwimlaneBtns() {
  var buttons = document.querySelectorAll('.show_more_btn');

  for (var i = 0; i < buttons.length; i++) {
    // Avoid double-binding
    if (buttons[i].getAttribute('data-bound')) continue;
    buttons[i].setAttribute('data-bound', 'true');

    buttons[i].addEventListener('click', function() {
      var swimlane = this.getAttribute('data-swimlane');
      var swimlaneContent = document.querySelector('.swimlane_content[data-swimlane="' + swimlane + '"]');
      var hiddenCards = swimlaneContent.querySelectorAll('.hidden_card');
      var isExpanded = this.getAttribute('data-expanded') === 'true';

      // Toggle visibility of hidden cards
      for (var j = 0; j < hiddenCards.length; j++) {
        hiddenCards[j].style.display = isExpanded ? 'none' : 'block';
      }

      // Toggle button text and state
      if (isExpanded) {
        this.textContent = this.getAttribute('data-show_text') || 'Show More';
        this.setAttribute('data-expanded', 'false');
      } else {
        this.textContent = this.getAttribute('data-hide_text') || 'Show Less';
        this.setAttribute('data-expanded', 'true');
      }
    });
  }
}

document.addEventListener('DOMContentLoaded', initSwimlaneBtns);
document.addEventListener('page:change', initSwimlaneBtns);
document.addEventListener('turbolinks:load', initSwimlaneBtns);

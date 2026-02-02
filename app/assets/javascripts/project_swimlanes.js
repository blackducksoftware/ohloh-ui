// Project Swimlanes - Show More/Less functionality
document.addEventListener('DOMContentLoaded', function() {
  var buttons = document.querySelectorAll('.show_more_btn');

  for (var i = 0; i < buttons.length; i++) {
    buttons[i].addEventListener('click', function() {
      var swimlane = this.getAttribute('data-swimlane');
      var swimlaneContent = document.querySelector('.swimlane_content[data-swimlane="' + swimlane + '"]');
      var hiddenCards = swimlaneContent.querySelectorAll('.hidden_card');
      var isExpanded = this.textContent.trim() === 'Show Less';

      // Toggle visibility of hidden cards
      for (var j = 0; j < hiddenCards.length; j++) {
        if (isExpanded) {
          hiddenCards[j].style.display = 'none';
        } else {
          hiddenCards[j].style.display = 'block';
        }
        console.log('Card', j, 'classes:', hiddenCards[j].className, 'display:', window.getComputedStyle(hiddenCards[j]).display);
      }

      // Toggle button text
      if (isExpanded) {
        this.textContent = 'Show More';
      } else {
        this.textContent = 'Show Less';
      }
    });
  }
});

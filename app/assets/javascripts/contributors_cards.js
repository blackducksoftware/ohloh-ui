// Card expand/collapse functionality (used by contributors, enlistments, and about sections)
document.addEventListener('DOMContentLoaded', function() {
  // Handle contributor and enlistment cards
  var cardItems = document.querySelectorAll('.contributor-card-item, .enlistment-card-item');

  cardItems.forEach(function(card) {
    var header = card.querySelector('.card-item-header');

    if (header) {
      header.addEventListener('click', function(e) {
        // Don't toggle if clicking on links
        if (e.target.closest('a, .contributor-link')) {
          return;
        }

        e.preventDefault();
        card.classList.toggle('expanded');
      });
    }
  });

  // Handle about code locations card
  var aboutCard = document.querySelector('.about-code-locations-card');
  if (aboutCard) {
    var aboutHeader = aboutCard.querySelector('.card-header');
    if (aboutHeader) {
      aboutHeader.addEventListener('click', function(e) {
        // Don't toggle if clicking on links
        if (e.target.closest('a')) {
          return;
        }

        e.preventDefault();
        aboutCard.classList.toggle('expanded');
      });
    }
  }
});

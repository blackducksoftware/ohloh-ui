// Contributors mobile card expand/collapse functionality
document.addEventListener('DOMContentLoaded', function() {
  const contributorCards = document.querySelectorAll('.contributor-card-item');

  contributorCards.forEach(function(card) {
    const header = card.querySelector('.card-item-header');

    if (header) {
      header.addEventListener('click', function(e) {
        // Don't toggle if clicking on the avatar/name link
        if (e.target.closest('.contributor-link')) {
          return;
        }

        e.preventDefault();
        card.classList.toggle('expanded');
      });
    }
  });
});

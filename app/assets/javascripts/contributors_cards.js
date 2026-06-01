document.addEventListener('click', function(e) {
  // Handle contributor and enlistment card headers
  var cardHeader = e.target.closest('.contributor-card-item .card-item-header, .enlistment-card-item .card-item-header');
  if (cardHeader) {
    // Skip if clicking a link
    if (e.target.closest('a, .contributor-link')) {
      return;
    }
    e.preventDefault();
    cardHeader.closest('.contributor-card-item, .enlistment-card-item').classList.toggle('expanded');
    return;
  }

  // Handle about code locations card header
  var aboutHeader = e.target.closest('.about-code-locations-card .card-header');
  if (aboutHeader) {
    aboutHeader.closest('.about-code-locations-card').classList.toggle('expanded');
    return;
  }

  // Handle about account basics card header
  var basicsHeader = e.target.closest('.about-account-basics-card .card-header');
  if (basicsHeader) {
    basicsHeader.closest('.about-account-basics-card').classList.toggle('expanded');
    return;
  }

  // Handle about project basics card header
  var projectBasicsHeader = e.target.closest('.about-project-basics-card .card-header');
  if (projectBasicsHeader) {
    projectBasicsHeader.closest('.about-project-basics-card').classList.toggle('expanded');
  }
});

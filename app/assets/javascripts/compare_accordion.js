// Mobile Compare Projects Accordion Functionality
document.addEventListener('click', function(e) {
  var accordionHeader = e.target.closest('.accordion-header');
  if (accordionHeader) {
    e.preventDefault();

    var section = accordionHeader.parentElement;
    var content = section.querySelector('.accordion-content');
    var icon = accordionHeader.querySelector('i');
    var isOpen = section.classList.contains('active');

    if (isOpen) {
      // Close this section
      section.classList.remove('active');
      content.style.maxHeight = null;
      if (icon) {
        icon.classList.remove('icon-chevron-up');
        icon.classList.add('icon-chevron-down');
      }
    } else {
      // Open this section
      section.classList.add('active');
      content.style.maxHeight = content.scrollHeight + 'px';
      if (icon) {
        icon.classList.remove('icon-chevron-down');
        icon.classList.add('icon-chevron-up');
      }
    }
  }
});

// Rotating Stats Animation for Homepage
document.addEventListener('DOMContentLoaded', function() {
  const globalStats = document.getElementById('global_statistics');

  if (!globalStats) return;

  const statElements = globalStats.querySelectorAll('p');

  if (statElements.length === 0) return;

  let currentIndex = 0;

  // Show first stat initially
  statElements[0].classList.remove('hide');

  // Rotate stats every 2 seconds
  setInterval(function() {
    // Hide current stat
    statElements[currentIndex].classList.add('hide');

    // Move to next stat
    currentIndex = (currentIndex + 1) % statElements.length;

    // Show next stat after a brief delay
    setTimeout(function() {
      statElements[currentIndex].classList.remove('hide');
    }, 300);
  }, 2000);
});

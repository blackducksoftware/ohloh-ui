// Responsive Pictogram Handler
class ResponsivePictogram {
  constructor() {
    this.init();
  }

  init() {
    this.setupScrollIndicators();
    this.setupTouchEnhancements();
    this.setupResponsiveResizing();
  }

  setupScrollIndicators() {
    const pictogramWrapper = document.querySelector('.pictogram-wrapper');
    if (!pictogramWrapper) return;

    // Only add scroll indicators on mobile/tablet
    if (window.innerWidth <= 768) {
      this.addScrollIndicators(pictogramWrapper);
    }

    // Handle scroll events
    pictogramWrapper.addEventListener('scroll', () => {
      this.updateScrollIndicators(pictogramWrapper);
    }, { passive: true });

    // Initial check for scroll indicators
    setTimeout(() => {
      this.updateScrollIndicators(pictogramWrapper);
    }, 100);
  }

  addScrollIndicators(wrapper) {
    // Add CSS classes to trigger pseudo-element indicators
    wrapper.classList.add('responsive-scroll-wrapper');
    
    // Check if content overflows
    const hasOverflow = wrapper.scrollWidth > wrapper.clientWidth;
    if (hasOverflow) {
      this.updateScrollIndicators(wrapper);
    }
  }

  updateScrollIndicators(wrapper) {
    const scrollLeft = wrapper.scrollLeft;
    const scrollWidth = wrapper.scrollWidth;
    const clientWidth = wrapper.clientWidth;
    const maxScroll = scrollWidth - clientWidth;

    // Show/hide left indicator
    if (scrollLeft > 10) {
      wrapper.classList.add('show-left-indicator');
    } else {
      wrapper.classList.remove('show-left-indicator');
    }

    // Show/hide right indicator
    if (scrollLeft < maxScroll - 10) {
      wrapper.classList.add('show-right-indicator');
    } else {
      wrapper.classList.remove('show-right-indicator');
    }
  }

  setupTouchEnhancements() {
    if (!('ontouchstart' in window)) return;

    const pictogramLinks = document.querySelectorAll('#org_infographic a, #org_infographic .pictogram_link_active');
    
    pictogramLinks.forEach(link => {
      // Add touch feedback
      link.addEventListener('touchstart', function() {
        this.classList.add('touch-active');
      }, { passive: true });

      link.addEventListener('touchend', function() {
        setTimeout(() => {
          this.classList.remove('touch-active');
        }, 150);
      }, { passive: true });

      // Prevent double-tap zoom on interactive elements
      link.addEventListener('touchend', function(e) {
        e.preventDefault();
        // Simulate click after touch
        setTimeout(() => {
          if (this.href) {
            window.location.href = this.href;
          } else if (this.onclick) {
            this.onclick();
          }
        }, 50);
      });
    });
  }

  setupResponsiveResizing() {
    let resizeTimeout;
    
    window.addEventListener('resize', () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(() => {
        this.handleResize();
      }, 250);
    });

    // Handle orientation change
    window.addEventListener('orientationchange', () => {
      setTimeout(() => {
        this.handleResize();
      }, 500);
    });
  }

  handleResize() {
    const pictogramWrapper = document.querySelector('.pictogram-wrapper');
    if (!pictogramWrapper) return;

    // Update scroll indicators based on new size
    this.updateScrollIndicators(pictogramWrapper);

    // Re-initialize scroll indicators for mobile if needed
    if (window.innerWidth <= 768) {
      if (!pictogramWrapper.classList.contains('responsive-scroll-wrapper')) {
        this.addScrollIndicators(pictogramWrapper);
      }
    } else {
      // Remove mobile-specific classes on larger screens
      pictogramWrapper.classList.remove('show-left-indicator', 'show-right-indicator');
    }

    // Ensure infographic is centered after resize
    this.centerPictogram();
  }

  centerPictogram() {
    const pictogramWrapper = document.querySelector('.pictogram-wrapper');
    if (!pictogramWrapper) return;

    // Center the pictogram content if it doesn't overflow
    const hasOverflow = pictogramWrapper.scrollWidth > pictogramWrapper.clientWidth;
    if (!hasOverflow) {
      pictogramWrapper.scrollLeft = 0;
    } else {
      // Center the content in the viewport
      const centerPosition = (pictogramWrapper.scrollWidth - pictogramWrapper.clientWidth) / 2;
      pictogramWrapper.scrollLeft = centerPosition;
    }
  }

  // Method to programmatically scroll the pictogram
  scrollPictogram(direction, amount = 200) {
    const pictogramWrapper = document.querySelector('.pictogram-wrapper');
    if (!pictogramWrapper) return;

    const scrollAmount = direction === 'left' ? -amount : amount;
    pictogramWrapper.scrollBy({
      left: scrollAmount,
      behavior: 'smooth'
    });
  }

  // Method to reset pictogram to optimal view
  resetPictogramView() {
    const pictogramWrapper = document.querySelector('.pictogram-wrapper');
    if (!pictogramWrapper) return;

    // Scroll to center or beginning based on content size
    this.centerPictogram();
  }
}

// Initialize responsive pictogram when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  // Only initialize if we're on an organization page with pictogram
  if (document.querySelector('.org-pictogram') && document.querySelector('#org_infographic')) {
    window.responsivePictogram = new ResponsivePictogram();
  }
});

// Cleanup on page unload
window.addEventListener('beforeunload', function() {
  if (window.responsivePictogram) {
    window.responsivePictogram = null;
  }
});

// Export for potential external use
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ResponsivePictogram;
}

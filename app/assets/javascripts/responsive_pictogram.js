// Responsive Pictogram Handler - ES5 Compatible
(function() {
  'use strict';

  function ResponsivePictogram() {
    this.init();
  }

  ResponsivePictogram.prototype.init = function() {
    this.setupScrollIndicators();
    this.setupTouchEnhancements();
    this.setupResponsiveResizing();
  };

  ResponsivePictogram.prototype.setupScrollIndicators = function() {
    var self = this;
    var pictogramWrapper = document.querySelector('.pictogram-wrapper');
    if (!pictogramWrapper) return;

    // Only add scroll indicators on mobile/tablet
    if (window.innerWidth <= 768) {
      this.addScrollIndicators(pictogramWrapper);
    }

    // Handle scroll events
    pictogramWrapper.addEventListener('scroll', function() {
      self.updateScrollIndicators(pictogramWrapper);
    }, false);

    // Initial check for scroll indicators
    setTimeout(function() {
      self.updateScrollIndicators(pictogramWrapper);
    }, 100);
  };

  ResponsivePictogram.prototype.addScrollIndicators = function(wrapper) {
    // Add CSS classes to trigger pseudo-element indicators
    wrapper.classList.add('responsive-scroll-wrapper');
    
    // Check if content overflows
    var hasOverflow = wrapper.scrollWidth > wrapper.clientWidth;
    if (hasOverflow) {
      this.updateScrollIndicators(wrapper);
    }
  };

  ResponsivePictogram.prototype.updateScrollIndicators = function(wrapper) {
    var scrollLeft = wrapper.scrollLeft;
    var scrollWidth = wrapper.scrollWidth;
    var clientWidth = wrapper.clientWidth;
    var maxScroll = scrollWidth - clientWidth;

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
  };

  ResponsivePictogram.prototype.setupTouchEnhancements = function() {
    if (!('ontouchstart' in window)) return;

    var pictogramLinks = document.querySelectorAll('#org_infographic a, #org_infographic .pictogram_link_active');
    
    for (var i = 0; i < pictogramLinks.length; i++) {
      var link = pictogramLinks[i];
      
      // Add touch feedback
      link.addEventListener('touchstart', function() {
        this.classList.add('touch-active');
      }, false);

      link.addEventListener('touchend', function() {
        var element = this;
        setTimeout(function() {
          element.classList.remove('touch-active');
        }, 150);
      }, false);

      // Prevent double-tap zoom on interactive elements
      link.addEventListener('touchend', function(e) {
        e.preventDefault();
        var element = this;
        // Simulate click after touch
        setTimeout(function() {
          if (element.href) {
            window.location.href = element.href;
          } else if (element.onclick) {
            element.onclick();
          }
        }, 50);
      });
    }
  };

  ResponsivePictogram.prototype.setupResponsiveResizing = function() {
    var self = this;
    var resizeTimeout;
    
    window.addEventListener('resize', function() {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(function() {
        self.handleResize();
      }, 250);
    });

    // Handle orientation change
    window.addEventListener('orientationchange', function() {
      setTimeout(function() {
        self.handleResize();
      }, 500);
    });
  };

  ResponsivePictogram.prototype.handleResize = function() {
    var pictogramWrapper = document.querySelector('.pictogram-wrapper');
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
  };

  ResponsivePictogram.prototype.centerPictogram = function() {
    var pictogramWrapper = document.querySelector('.pictogram-wrapper');
    if (!pictogramWrapper) return;

    // Center the pictogram content if it doesn't overflow
    var hasOverflow = pictogramWrapper.scrollWidth > pictogramWrapper.clientWidth;
    if (!hasOverflow) {
      pictogramWrapper.scrollLeft = 0;
    } else {
      // Center the content in the viewport
      var centerPosition = (pictogramWrapper.scrollWidth - pictogramWrapper.clientWidth) / 2;
      pictogramWrapper.scrollLeft = centerPosition;
    }
  };

  // Method to programmatically scroll the pictogram
  ResponsivePictogram.prototype.scrollPictogram = function(direction, amount) {
    amount = amount || 200;
    var pictogramWrapper = document.querySelector('.pictogram-wrapper');
    if (!pictogramWrapper) return;

    var scrollAmount = direction === 'left' ? -amount : amount;
    
    // Use scrollBy if available, otherwise use scrollLeft
    if (pictogramWrapper.scrollBy) {
      pictogramWrapper.scrollBy({
        left: scrollAmount,
        behavior: 'smooth'
      });
    } else {
      pictogramWrapper.scrollLeft += scrollAmount;
    }
  };

  // Method to reset pictogram to optimal view
  ResponsivePictogram.prototype.resetPictogramView = function() {
    var pictogramWrapper = document.querySelector('.pictogram-wrapper');
    if (!pictogramWrapper) return;

    // Scroll to center or beginning based on content size
    this.centerPictogram();
  };

  // Initialize responsive pictogram when DOM is ready
  function initializeResponsivePictogram() {
    // Only initialize if we're on an organization page with pictogram
    if (document.querySelector('.org-pictogram') && document.querySelector('#org_infographic')) {
      window.responsivePictogram = new ResponsivePictogram();
    }
  }

  // DOM ready check
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeResponsivePictogram);
  } else {
    initializeResponsivePictogram();
  }

  // Cleanup on page unload
  window.addEventListener('beforeunload', function() {
    if (window.responsivePictogram) {
      window.responsivePictogram = null;
    }
  });

  // For jQuery/Turbolinks compatibility
  if (typeof $ !== 'undefined') {
    $(document).on('page:change', function() {
      initializeResponsivePictogram();
    });
    
    $(document).on('turbo:load', function() {
      initializeResponsivePictogram();
    });
  }

  // Export for potential external use (if module system is available)
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = ResponsivePictogram;
  }

})();

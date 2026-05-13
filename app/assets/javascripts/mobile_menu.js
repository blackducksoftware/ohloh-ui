// Mobile Menu Toggle Functionality
var MobileMenu = {
  init: function() {
    this.bindEvents();
  },

  toggleMenu: function() {
    var mobileMenu = document.getElementById('mobile-menu');

    if (mobileMenu) {
      if (mobileMenu.classList.contains('show')) {
        mobileMenu.classList.remove('show');
      } else {
        mobileMenu.classList.add('show');
      }
    }
  },

  closeMenu: function() {
    var mobileMenu = document.getElementById('mobile-menu');
    if (mobileMenu) {
      mobileMenu.classList.remove('show');
    }
  },

  bindEvents: function() {
    var self = this;
    var toggleBtn = document.getElementById('mobile-menu-toggle');

    if (toggleBtn) {
      toggleBtn.onclick = function(e) {
        e.preventDefault();
        self.toggleMenu();
        return false;
      };
    }

    // Close menu when clicking on a link
    var mobileMenuLinks = document.querySelectorAll('.mobile-menu-items a, .mobile-menu-user a, .mobile-menu-signin a');

    for (var i = 0; i < mobileMenuLinks.length; i++) {
      mobileMenuLinks[i].onclick = function() {
        self.closeMenu();
      };
    }

    // Close menu when window is resized to desktop size
    window.addEventListener('resize', function() {
      if (window.innerWidth >= 1024) {
        self.closeMenu();
      }
    });
  }
};

// Initialize on DOM ready
if (typeof $ !== 'undefined') {
  $(document).on('page:change', function() {
    MobileMenu.init();
  });

  $(document).ready(function() {
    MobileMenu.init();
  });
} else {
  // Fallback if jQuery is not available
  document.addEventListener('DOMContentLoaded', function() {
    MobileMenu.init();
  });
}

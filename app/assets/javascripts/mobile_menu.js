// Mobile Menu Toggle Functionality
var MobileMenu = {
  init: function() {
    console.log('MobileMenu: Initializing...');
    this.bindEvents();
  },

  toggleMenu: function() {
    console.log('MobileMenu: Toggle clicked!');
    var mobileMenu = document.getElementById('mobile-menu');

    if (mobileMenu) {
      if (mobileMenu.classList.contains('show')) {
        mobileMenu.classList.remove('show');
        console.log('MobileMenu: Menu closed');
      } else {
        mobileMenu.classList.add('show');
        console.log('MobileMenu: Menu opened');
      }
    } else {
      console.log('MobileMenu: WARNING - Mobile menu element not found!');
    }
  },

  closeMenu: function() {
    var mobileMenu = document.getElementById('mobile-menu');
    if (mobileMenu) {
      mobileMenu.classList.remove('show');
      console.log('MobileMenu: Menu closed');
    }
  },

  bindEvents: function() {
    var self = this;
    var toggleBtn = document.getElementById('mobile-menu-toggle');

    console.log('MobileMenu: Toggle button found?', !!toggleBtn);

    if (toggleBtn) {
      toggleBtn.onclick = function(e) {
        e.preventDefault();
        self.toggleMenu();
        return false;
      };
      console.log('MobileMenu: Click handler attached');
    } else {
      console.log('MobileMenu: WARNING - Mobile menu toggle button not found!');
    }

    // Close menu when clicking on a link
    var mobileMenuLinks = document.querySelectorAll('.mobile-menu-items a, .mobile-menu-user a, .mobile-menu-signin a');
    console.log('MobileMenu: Found', mobileMenuLinks.length, 'menu links');

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
    console.log('MobileMenu: page:change event fired');
    MobileMenu.init();
  });

  $(document).ready(function() {
    console.log('MobileMenu: document.ready event fired');
    MobileMenu.init();
  });
} else {
  // Fallback if jQuery is not available
  document.addEventListener('DOMContentLoaded', function() {
    console.log('MobileMenu: DOMContentLoaded event fired');
    MobileMenu.init();
  });
}

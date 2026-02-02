// Theme Toggle Functionality
var ThemeToggle = {
  init: function() {
    console.log('ThemeToggle: Initializing...');
    var savedTheme = this.getSavedTheme();
    console.log('ThemeToggle: Saved theme is', savedTheme);
    this.applyTheme(savedTheme);
    this.bindEvents();
  },

  getSavedTheme: function() {
    try {
      return localStorage.getItem('theme') || 'light';
    } catch (e) {
      return 'light';
    }
  },

  applyTheme: function(theme) {
    var html = document.documentElement;
    var moonIcon = document.getElementById('theme-icon-moon');
    var sunIcon = document.getElementById('theme-icon-sun');

    if (theme === 'dark') {
      html.classList.add('dark');
      if (moonIcon) moonIcon.classList.add('hidden');
      if (sunIcon) sunIcon.classList.remove('hidden');
    } else {
      html.classList.remove('dark');
      if (moonIcon) moonIcon.classList.remove('hidden');
      if (sunIcon) sunIcon.classList.add('hidden');
    }

    try {
      localStorage.setItem('theme', theme);
    } catch (e) {
      console.log('Could not save theme preference');
    }
  },

  toggleTheme: function() {
    var currentTheme = this.getSavedTheme();
    var newTheme = currentTheme === 'light' ? 'dark' : 'light';
    this.applyTheme(newTheme);
  },

  bindEvents: function() {
    var self = this;
    var themeToggleBtn = document.getElementById('theme-toggle');

    console.log('ThemeToggle: Theme toggle button found?', !!themeToggleBtn);

    if (themeToggleBtn) {
      themeToggleBtn.onclick = function(e) {
        e.preventDefault();
        console.log('ThemeToggle: Toggle clicked!');
        self.toggleTheme();
        return false;
      };
      console.log('ThemeToggle: Click handler attached');
    } else {
      console.log('ThemeToggle: WARNING - Theme toggle button not found!');
    }
  }
};

// Initialize on DOM ready
$(document).on('page:change', function() {
  ThemeToggle.init();
});

// Also initialize immediately if DOM is already loaded
$(document).ready(function() {
  ThemeToggle.init();
});

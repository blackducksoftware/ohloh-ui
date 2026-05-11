// Theme Toggle Functionality
var ThemeToggle = {
  COOKIE_NAME: 'theme_preference',
  COOKIE_DAYS: 365,

  init: function() {
    var self = this;
    this.isAuthenticated = this.checkAuthentication();

    if (this.isAuthenticated) {
      this.loadServerThemePreference(function(theme) {
        self.applyTheme(theme);
        self.bindEvents();
      });
    } else {
      var savedTheme = this.getSavedTheme();
      this.applyTheme(savedTheme);
      this.bindEvents();
    }
  },

  checkAuthentication: function() {
    var metaTag = document.querySelector('meta[name="current-user"]');
    return metaTag && metaTag.getAttribute('content');
  },

  getCurrentUserId: function() {
    var metaTag = document.querySelector('meta[name="current-user"]');
    return metaTag ? metaTag.getAttribute('content') : null;
  },

  loadServerThemePreference: function(callback) {
    var userId = this.getCurrentUserId();
    if (!userId) {
      callback(this.getSystemTheme());
      return;
    }

    var self = this;
    fetch('/accounts/' + userId + '/theme_preference.json', {
      method: 'GET',
      credentials: 'same-origin',
      headers: {
        'Accept': 'application/json'
      }
    })
    .then(function(response) {
      if (!response.ok) {
        return callback(self.getSystemTheme());
      }
      return response.json();
    })
    .then(function(data) {
      if (data && data.theme_preference) {
        callback(data.theme_preference);
      } else {
        callback(self.getSystemTheme());
      }
    })
    .catch(function(error) {
      callback(self.getSystemTheme());
    });
  },

  saveServerThemePreference: function(theme) {
    if (!this.isAuthenticated) {
      return;
    }

    var userId = this.getCurrentUserId();
    if (!userId) {
      return;
    }

    fetch('/accounts/' + userId + '/set_theme_preference', {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.getCsrfToken()
      },
      body: JSON.stringify({ theme: theme })
    })
    .then(function(response) {
      return response.json();
    })
    .catch(function(error) {
      // Silent fail - cookie already set
    });
  },

  getCsrfToken: function() {
    var token = document.querySelector('meta[name="csrf-token"]');
    return token ? token.getAttribute('content') : '';
  },

  getCookie: function(name) {
    var nameEQ = name + '=';
    var cookies = document.cookie.split(';');
    for (var i = 0; i < cookies.length; i++) {
      var cookie = cookies[i].trim();
      if (cookie.indexOf(nameEQ) === 0) {
        return cookie.substring(nameEQ.length);
      }
    }
    return null;
  },

  setCookie: function(name, value, days) {
    var expires = '';
    if (days) {
      var date = new Date();
      date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
      expires = '; expires=' + date.toUTCString();
    }
    document.cookie = name + '=' + value + expires + '; path=/; SameSite=Lax';
  },

  getSystemTheme: function() {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
    return 'light';
  },

  getSavedTheme: function() {
    var cookieTheme = this.getCookie(this.COOKIE_NAME);
    if (cookieTheme && (cookieTheme === 'light' || cookieTheme === 'dark')) {
      return cookieTheme;
    }
    return this.getSystemTheme();
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

    this.setCookie(this.COOKIE_NAME, theme, this.COOKIE_DAYS);

    if (typeof Charts !== 'undefined') {
      Charts.updateWatermarks(theme === 'dark');
    }
  },

  toggleTheme: function() {
    var currentTheme = this.getSavedTheme();
    var newTheme = currentTheme === 'light' ? 'dark' : 'light';
    this.applyTheme(newTheme);
    if (this.isAuthenticated) {
      this.saveServerThemePreference(newTheme);
    }
  },

  bindEvents: function() {
    var self = this;
    var themeToggleBtn = document.getElementById('theme-toggle');

    if (themeToggleBtn) {
      themeToggleBtn.onclick = function(e) {
        e.preventDefault();
        self.toggleTheme();
        return false;
      };
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

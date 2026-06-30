// Show loader immediately when user clicks a link to a slow page.
// Hide it once the destination page's DOM is ready.

(function() {
  var SLOW_PAGE_PATTERNS = [
    /^\/people(\/|\?|$)/,
    /^\/explore\/projects(\/|\?|$)/,
    /^\/explore\/orgs(\/|\?|$)/,
    /^\/committers(\/|\?|$)/,
    /^\/accounts(\/|\?|$)/,
    /^\/p\/[^/]+\/commits(\/|\?|$)/
  ];

  function isSlowPage(url) {
    try {
      var path = new URL(url, window.location.origin).pathname;
      return SLOW_PAGE_PATTERNS.some(function(pattern) {
        return pattern.test(path);
      });
    } catch (e) {
      return false;
    }
  }

  function showLoader() {
    var loader = document.getElementById('page-loader');
    if (loader) loader.classList.remove('hidden');
  }

  function hideLoader() {
    var loader = document.getElementById('page-loader');
    if (loader) loader.classList.add('hidden');
  }

  // Show loader when clicking links to slow pages
  document.addEventListener('click', function(e) {
    // Skip if event was already prevented or not a left-click
    if (e.defaultPrevented || e.button !== 0) return;
    // Skip if modifier keys held (would open in new tab/window)
    if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;

    var link = e.target.closest('a[href]');
    if (!link) return;

    // Skip if link targets something other than current window
    if (link.target && link.target.toLowerCase() !== '_self') return;

    var href = link.getAttribute('href');
    // Skip hash-only links
    if (!href || href.charAt(0) === '#') return;

    if (isSlowPage(href)) {
      showLoader();
    }
  });

  // Hide loader once this page's DOM is ready
  document.addEventListener('DOMContentLoaded', hideLoader);

  // Hide loader when page is restored from bfcache (browser back/forward)
  window.addEventListener('pageshow', function(e) {
    if (e.persisted) hideLoader();
  });
})();

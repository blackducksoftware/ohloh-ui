(function() {
  var calculateHighVulns, calculateLowVulns, calculateMediumVulns, filterReleases, filterReleasesByMajorVersion, filterReleasesByYear, loadCurrentRelease, noReportedVulnerabilities, reRenderChart, renderNoData, updateVersionFilter;

  this.getReleaseData = function() {
    var data, releaseObjects;
    releaseObjects = document.getElementById('vulnerability_filter_major_version').dataset.releases;
    return data = JSON.parse(releaseObjects);
  };

  this.find_release_by_version = function(version) {
    var release;
    release = void 0;
    $.each(getReleaseData(), function(i, r) {
      if (r.version === version) {
        release = r;
        return false;
      }
    });
    return release;
  };

  this.find_release_by_id = function(id) {
    var release;
    release = void 0;
    id = parseInt(id);
    $.each(getReleaseData(), function(i, r) {
      if (r.id === id) {
        release = r;
        return false;
      }
    });
    return release;
  };

  this.getProjectUrl = function() {
    return window.location.href.match(/\/p\/.+\//)[0];
  };

  this.extendVulnerabilityChartOptions = function(options) {
    return options.plotOptions['series'] = {
      cursor: 'pointer',
      point: {
        events: {
          click: function(event) {
            var currentRelease, oldReleaseId;
            currentRelease = find_release_by_version(this.category);
            oldReleaseId = parseInt($('#vulnerability_filter_version').val());
            return loadCurrentRelease(currentRelease, oldReleaseId);
          }
        }
      }
    };
  };

  this.reDrawVulnerabilityChart = function() {
    var releases;
    releases = filterReleases();
    if (releases.length === 0) {
      return renderNoData(releases);
    } else {
      return reRenderChart(releases);
    }
  };

  this.refreshVulnerabilityTable = function() {
    var currentRelease, oldReleaseId, releases;
    releases = filterReleases().reverse();
    currentRelease = releases[0];
    if (!currentRelease) {
      return noReportedVulnerabilities();
    }
    oldReleaseId = parseInt($('#vulnerability_filter_version').val());
    updateVersionFilter(releases);
    return loadCurrentRelease(currentRelease, oldReleaseId);
  };

  this.fetchVulnerabilityData = function(queryStr) {
    return $.ajax({
      url: getProjectUrl().concat('vulnerabilities_filter'),
      data: queryStr,
      beforeSend: function() {
        return $('.overlay-loader').show();
      },
      success: function(vulTable) {
        $('.vulnerabilities-datatable').html(vulTable);
        return $('.overlay-loader').hide();
      }
    });
  };

  this.updateSeverityFilter = function(release) {
    $('#vulnerability_filter_severity').prop('disabled', false);
    return $.each(['low', 'medium', 'high'], function(index, severity) {
      return $("#vulnerability_filter_severity option[value=" + severity + "]").prop('disabled', release[severity] === 0);
    });
  };

  this.updateBrowserHistory = function(queryStr) {
    if (queryStr === void 0) {
      queryStr = {
        filter: {
          major_version: $('#vulnerability_filter_major_version').val(),
          period: $('#vulnerability_filter_period').val(),
          version: $('#vulnerability_filter_version').val(),
          severity: $('#vulnerability_filter_severity').find(':selected').val()
        }
      };
    }
    return window.history.pushState('', document.title, getProjectUrl() + 'security?' + $.param(queryStr));
  };

  filterReleases = function() {
    var filteredReleases, majorVersion, year;
    majorVersion = $('#vulnerability_filter_major_version').val();
    year = $('#vulnerability_filter_period').val();
    filteredReleases = filterReleasesByMajorVersion(getReleaseData(), majorVersion);
    filteredReleases = filterReleasesByYear(filteredReleases, year);
    return filteredReleases.sort(function(a, b) {
      if (a.released_on > b.released_on) {
        return 1;
      }
      if (a.released_on < b.released_on) {
        return -1;
      }
    });
  };

  filterReleasesByYear = function(releases, year) {
    var currentDate, pastDate;
    if (year === '') {
      return releases;
    }
    currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0);
    pastDate = new Date();
    pastDate.setHours(0, 0, 0, 0);
    pastDate.setFullYear(pastDate.getFullYear() - year);
    return releases.filter(function(item) {
      var releasedDate;
      releasedDate = new Date(item.released_on);
      releasedDate.setHours(0, 0, 0, 0);
      return releasedDate <= currentDate && releasedDate >= pastDate;
    });
  };

  filterReleasesByMajorVersion = function(releases, majorVersion) {
    if (majorVersion === '') {
      return releases;
    }
    return releases.filter(function(release) {
      return RegExp("^" + majorVersion + "\\.\\d+\\.\\d+$").test(release.version);
    });
  };

  calculateHighVulns = function(releases) {
    var highVulns;
    return highVulns = releases.map(function(obj) {
      return obj.high;
    });
  };

  calculateMediumVulns = function(releaseData) {
    var mediumVulns;
    return mediumVulns = releaseData.map(function(obj) {
      return obj.medium;
    });
  };

  calculateLowVulns = function(releaseData) {
    var lowVulns;
    return lowVulns = releaseData.map(function(obj) {
      return obj.low;
    });
  };

  renderNoData = function(releases) {
    var chart, renderer;
    chart = $('#vulnerability_all_version_chart').highcharts();
    renderer = new Highcharts.Renderer($('#vulnerability_all_version_chart')[0], 10, 10);
    reRenderChart(releases);
    return chart.renderer.text('There are no reported vulnerabilities', 450, 70).css({
      fontSize: '12px'
    }).add();
  };

  reRenderChart = function(releases) {
    var chart, versions;
    if ($('tspan').html() === "There are no reported vulnerabilities") {
      $('tspan').remove();
    }
    versions = releases.map(function(obj) {
      return obj.version;
    });
    chart = $('#vulnerability_all_version_chart').highcharts();
    chart.xAxis[0].update({
      categories: versions
    }, true, false);
    chart.series[0].update({
      data: calculateHighVulns(releases)
    }, false);
    chart.series[1].update({
      data: calculateMediumVulns(releases)
    }, false);
    chart.series[2].update({
      data: calculateLowVulns(releases)
    }, false);
    return chart.redraw();
  };

  noReportedVulnerabilities = function() {
    var queryStr;
    $('#vulnerability_filter_version').html("<option value=''>No versions in specified filters</option>");
    $('#vulnerability_filter_severity').prop('disabled', true);
    $('.vulnerabilities-datatable').html('<div class="no_vulnerability">There are no reported vulnerabilities</div>');
    queryStr = {
      filter: {
        major_version: $('#vulnerability_filter_major_version').val(),
        period: $('#vulnerability_filter_period').val()
      }
    };
    return updateBrowserHistory(queryStr);
  };

  loadCurrentRelease = function(currentRelease, oldReleaseId) {
    if (currentRelease.id === oldReleaseId) {
      return updateBrowserHistory();
    } else {
      return $('#vulnerability_filter_version').val(currentRelease.id).change();
    }
  };

  updateVersionFilter = function(releases) {
    var releases_option;
    releases_option = releases.map(function(release) {
      return "<option value=" + release.id + ">" + release.version + "</option>";
    }).join('');
    return $('#vulnerability_filter_version').html(releases_option);
  };

}).call(this);

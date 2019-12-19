// JS to handle account/edit
$(document).ready(function() {
  EditMap.init();
});

var EditMap = {
  init: function(lat, lng) {
    // disable form submit on enter key within the location text-box
    $('#location_scratch').keydown(function(e) {
      if(e.keyCode == 13) {
        $(this).blur();
        return false;
      } else {
        EditMap.findLocation();
      }
    });
  },

  jumpMeTo: function(lat, lng) {
    var marker = OH_Map.jumpTo(lat, lng);
    google.maps.event.addListener(marker, "dragend", function() {
        $('#account_latitude')[0].value = marker.getPosition().lat();
        $('#account_longitude')[0].value = marker.getPosition().lng();
    });
  },

  // If the google geocoder fails, try the yahoo geocoder proxy
  alternateLookup: function(address) {
    $.getJSON('/proxy/yahoo_geocoder', { location: address },
      function(json) {
        if (json.success) {
          marker = EditMap.jumpMeTo(json.latitude, json.longitude);
          $('#account_country_code').val(json.country);
          $('#account_location_mirror').html(json.location);
          $('#account_location').val(json.location);
          $('#account_latitude').val(json.latitude);
          $('#account_longitude').val(json.longitude);
          $('#spinner').hide();
        } else {
          EditMap.notFound();
        }
    });
  },

  // addAddressToMap() is called when the geocoder returns an
  // answer.  It adds a marker to the map with an open info window
  // showing the nicely formatted version of the address and the country code.
  addAddressToMap: function(response, respStatus) {
    if (respStatus == google.maps.GeocoderStatus.OK) {
      var resp = response[0]; // consider the first matched result
      var address = resp.formatted_address;
      var loc = resp.geometry.location;
      var components = resp.address_components;
      var countryCode = '';
      $.each(components, function(_, o) {
        if (/country/i.test(o.types.join())) {
          countryCode = o.short_name;
        }
      });

      marker = EditMap.jumpMeTo(loc.lat(), loc.lng());

      $('#account_country_code').val(countryCode);
      $('#account_location_mirror').html(address);
      $('#account_location').val(address);
      $('#account_latitude').val(loc.lat());
      $('#account_longitude').val(loc.lng());
      $('#spinner').hide();
    } else {
      EditMap.alternateLookup($.trim($('#location_scratch').val()));
    }
  },

  // findLocation() is called periodically after the user edits
  // the form.  It geocodes the address entered into the form
  // and officially updates the user's location if found.
  findLocation: function() {
    $('#not_found').hide();
    var l = $.trim($('#location_scratch').val());
    if(l.length > 0) {
      $('#spinner').show();
      OH_Map.geocoder.geocode({address: l}, EditMap.addAddressToMap);
    }
  },

  notFound: function() {
    $('#spinner').hide();
    $('#not_found').show();
  },

  clearLocation: function() {
    $('#account_country_code').val("");
    $('#account_location').val("");
    $('#location_scratch').val("");
    $('#account_location_mirror').html('');
    $('#account_latitude').val("");
    $('#account_longitude').val("");
    OH_Map.setCenterZoom(0, 10, 0);
    OH_Map.clearMarkers();
    $('#spinner').hide();
    $('#not_found').hide();
  }
}

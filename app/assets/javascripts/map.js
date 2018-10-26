// Map Functions
var OH_Map = {
  map: null,
  geocoder: null,
  url: null,
  onComplete: null,
  defaultIconImage: null,
  postMap: null,
  markers: [],

  // basic map initialization
  load: function(id,lat,lng,zoom) {
    OH_Map.geocoder = new google.maps.Geocoder();
    var elem = document.getElementById(id);
    OH_Map.map = new google.maps.Map(elem, {
      zoom: zoom,
      zoomControl: true,
      zoomControlOptions: { style: google.maps.ZoomControlStyle.SMALL },
      center: new google.maps.LatLng(lat, lng),
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });

    if (Map.url){
      google.maps.event.addListener(OH_Map.map,"dragend",function() { OH_Map.getMarkers() });
      google.maps.event.addListener(OH_Map.map,"zoomend",function() { OH_Map.getMarkers() });
    }
  },

  moveTo: function(lat,lng,zoom) {
    OH_Map.setCenterZoom(lat, lng, zoom);
    OH_Map.getMarkers();
    if (OH_Map.postMap != null) {
      OH_Map.postMap();
    }
  },

  setCenterZoom: function(lat, lng, zoom) {
    var point = new google.maps.LatLng(lat,lng);
    OH_Map.map.setCenter(point);
    OH_Map.map.setZoom(zoom);
  },

  // centers the map to the location and creates a marker
  jumpTo: function(lat, lng) {
    point = new google.maps.LatLng(lat,lng);
    OH_Map.map.setCenter(point);
    OH_Map.clearMarkers();
    var marker = new google.maps.Marker({position: point, map: OH_Map.map, draggable: true});
    OH_Map.markers.push(marker);
    return marker;
  },

  clearMarkers: function() {
    for (i in Map.markers) {
      OH_Map.markers[i].setMap(null);
    }
    OH_Map.markers = [];
  },

  formatBalloon: function(account_count) {
    if ($('#a_contributors').checked) {
      return "<div> Total number of Contributors: " + account_count + "</div>"
    } else {
      return "<div> Total number of Users: " + account_count + "</div>"
    }
  },

  createMarker: function(account_count,lat,lng) {
    var icon = {
      url: OH_Map.defaultIconImage || "/assets/map/map_yellow.png",
      size: new google.maps.Size(12, 20),
      anchor: new google.maps.Point(6, 20)
    };

    var point = new google.maps.LatLng(lat,lng);
    var marker = new google.maps.Marker({position: point, map: OH_Map.map, draggable: true, icon: icon});
    OH_Map.markers.push(marker);

    google.maps.event.addListener(marker,"click",function(){
      var infoWindow = new google.maps.InfoWindow({content: OH_Map.formatBalloon(account_count), maxWidth: 100});
      infoWindow.open(OH_Map.map, marker);
    });
    return marker;
  },

  parseAccountJson: function(data){
    OH_Map.clearMarkers();
    var group = {};
    for (var i=0; i<data.accounts.length; i++){
      var lat_long = data.accounts[i].latitude+','+data.accounts[i].longitude;
      if ( ! group[lat_long] ){
        group[lat_long] = [];
      }
      group[lat_long].push(data.accounts[i]);
    }
    for(var loc in group){
      lat_n_long = loc.split(",");
      var marker=OH_Map.createMarker(group[loc].length, lat_n_long[0], lat_n_long[1]);
    };
    return data;
  },

  getMarkers: function() {
    if (OH_Map.url){
      $.getJSON(Map.url, {lat: OH_Map.map.getCenter().lat(), lng: OH_Map.map.getCenter().lng(), zoom: OH_Map.map.getZoom()},
        function(data, responseCode){
          var jsonData = OH_Map.parseAccountJson(data);
          if (OH_Map.onComplete){ OH_Map.onComplete(jsonData); }
      });
    }
  }
}

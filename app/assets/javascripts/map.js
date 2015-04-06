// Map Functions
var Map = {
  map: null,
  geocoder: null,
  url: null,
  onComplete: null,
  defaultIconImage: null,
  postMap: null,
  markers: [],

  // basic map initialization
  load: function(id,lat,lng,zoom) {
    Map.geocoder = new google.maps.Geocoder();
    var elem = document.getElementById(id);
    Map.map = new google.maps.Map(elem, {
      zoom: zoom,
      zoomControl: true,
      zoomControlOptions: { style: google.maps.ZoomControlStyle.SMALL },
      center: new google.maps.LatLng(lat, lng),
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });

    if (Map.url){
      google.maps.event.addListener(Map.map,"dragend",function() { Map.getMarkers() });
      google.maps.event.addListener(Map.map,"zoomend",function() { Map.getMarkers() });
    }
  },

  moveTo: function(lat,lng,zoom) {
    Map.setCenterZoom(lat, lng, zoom);
    Map.getMarkers();
    if (Map.postMap != null) {
      Map.postMap();
    }
  },

  setCenterZoom: function(lat, lng, zoom) {
    var point = new google.maps.LatLng(lat,lng);
    Map.map.setCenter(point);
    Map.map.setZoom(zoom);
  },

  // centers the map to the location and creates a marker
  jumpTo: function(lat, lng) {
    point = new google.maps.LatLng(lat,lng);
    Map.map.setCenter(point);
    Map.clearMarkers();
    var marker = new google.maps.Marker({position: point, map: Map.map, draggable: true});
    Map.markers.push(marker);
    return marker;
  },

  clearMarkers: function() {
    for (i in Map.markers) {
      Map.markers[i].setMap(null);
    }
    Map.markers = [];
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
      url: Map.defaultIconImage || "/assets/map/map_yellow.png",
      size: new google.maps.Size(12, 20),
      anchor: new google.maps.Point(6, 20)
    };

    var point = new google.maps.LatLng(lat,lng);
    var marker = new google.maps.Marker({position: point, map: Map.map, draggable: true, icon: icon});
    Map.markers.push(marker);

    google.maps.event.addListener(marker,"click",function(){
      var infoWindow = new google.maps.InfoWindow({content: Map.formatBalloon(account_count), maxWidth: 100});
      infoWindow.open(Map.map, marker);
    });
    return marker;
  },

  parseAccountJson: function(data){
    Map.clearMarkers();
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
      var marker=Map.createMarker(group[loc].length, lat_n_long[0], lat_n_long[1]);
    };
    return data;
  },

  getMarkers: function() {
    if (Map.url){
      $.getJSON(Map.url, {lat: Map.map.getCenter().lat(), lng: Map.map.getCenter().lng(), zoom: Map.map.getZoom()},
        function(data, responseCode){
          var jsonData = Map.parseAccountJson(data);
          if (Map.onComplete){ Map.onComplete(jsonData); }
      });
    }
  }
}

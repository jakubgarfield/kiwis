document.addEventListener("DOMContentLoaded", function(event) {
  // Blueimp gallery
  var galleryLinks = document.getElementsByClassName("gallery-link");
  for (var i = 0; i < galleryLinks.length; i++) {
    galleryLinks[i].onclick = function (event) {
      event = event || window.event;
      var target = event.target || event.srcElement;
      var link = target.src ? target.parentNode : target;
      var options = {index: link, event: event};
      blueimp.Gallery(galleryLinks, options);
    };
  }

  // Leaflet map
  function _c(c) { return document.getElementsByClassName(c)[0]; }
  function round(number) { return Math.round(number * 100) / 100; }
  function format_duration(seconds) {
    var result = "";
    var hours   = Math.floor(seconds / 3600);
    var minutes = Math.floor((seconds - (hours * 3600)) / 60);

    if (hours < 10) { result += "0"; }
    result += hours;
    result += ":";
    if (minutes < 10) { result += "0"; }
    result += minutes

    return result;
  }

  function fillTrackDetails(distanceContainer, durationContainer, averageSpeedContainer, elevationGainContainer, elevationLossContainer, properties) {
    distanceContainer.textContent = round(properties.distance / 1000);
    durationContainer.textContent = format_duration(properties.moving_duration);
    averageSpeedContainer.textContent = round((properties.distance * 60 * 60) / (properties.moving_duration * 1000));
    elevationGainContainer.textContent = round(properties.uphill_elevation);
    elevationLossContainer.textContent = round(properties.downhill_elevation);
  }

  if (window.geojson !== undefined) {
    var map = new L.Map('leaflet-map');

    var tileLayer = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    var elevation = L.control.elevation({
      position: "topright",
      theme: "steelblue-theme",
      width: 600,
      height: 125,
      margins: { top: 10, right: 20, bottom: 30, left: 50 },
      useHeightIndicator: true,
      interpolation: "linear",
      hoverNumber: {
        decimalsX: 3,
        decimalsY: 0,
        formatter: undefined
      },
      xTicks: undefined,
      yTicks: undefined,
      collapsed: false
    });
    elevation.addTo(map);

    var gjl = L.geoJson(geojson,{ onEachFeature: function(feature, layer) { elevation.addData.bind(elevation)(feature, layer); } }).addTo(map);
    map.addLayer(tileLayer).fitBounds(gjl.getBounds());

    fillTrackDetails(_c('total-distance'), _c('total-duration'), _c('total-average-speed'), _c('total-elevation-gain'), _c('total-elevation-loss'), geojson.properties);

    if (geojson.features.length > 1) {
      for (var i = 0; i < geojson.features.length; i++) {
        var feature = geojson.features[i];
        var tr = document.createElement("tr");
        var description = document.createElement("td");
        var distance = document.createElement("td");
        var duration = document.createElement("td");
        var averageSpeed = document.createElement("td");
        var elevationGain = document.createElement("td");
        var elevationLoss = document.createElement("td");
        fillTrackDetails(distance, duration, averageSpeed, elevationGain, elevationLoss, feature.properties);
        description.textContent = feature.properties.name;
        tr.appendChild(description);
        tr.appendChild(distance);
        tr.appendChild(duration);
        tr.appendChild(averageSpeed);
        tr.appendChild(elevationGain);
        tr.appendChild(elevationLoss);
        _c("map-details").appendChild(tr);
      }
    }
  }

  if (window.mapCoordinates !== undefined) {
    var map = new L.Map('leaflet-map').setView([window.mapCoordinates.x, window.mapCoordinates.y], window.mapCoordinates.zoom);

    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
  }
});

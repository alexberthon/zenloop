import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';

export default class extends Controller {
  static values = {
    apiKey: String,
    markersSelected: Array,
    markersReachable: Array,
    selectedStations: Object,
    reachableStations: Object,
    strokes: Object
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
    });

    this.map.on("load", () => {
      this.map.addSource("selectedStations", this.selectedStationsValue);
      this.map.addSource("reachableStations", this.reachableStationsValue);
      this.map.addSource("strokes", this.strokesValue);
      this.map.addLayer({
        "id": "selectedStations",
        "type": "circle",
        "source": "selectedStations",
        "paint": {
          "circle-color": "#E60F05",
          "circle-radius": 6,
          "circle-stroke-width": 2,
          "circle-stroke-color": "#ffffff"
        }
      });
      this.map.addLayer({
        "id": "reachableStations",
        "type": "circle",
        "source": "reachableStations",
        "paint": {
          "circle-color": "#4264fb",
          "circle-radius": 6,
          "circle-stroke-width": 2,
          "circle-stroke-color": "#ffffff"
        }
      });
      this.map.addLayer({
        'id': 'strokes',
        'type': 'line',
        'source': 'strokes',
        'layout': {
          'line-join': 'round',
          'line-cap': 'round'
        },
        'paint': {
          'line-color': '#888',
          'line-width': 1,
          'line-dasharray': [0, 4, 3]
        }
      })
      this.addPopupToMap("selectedStations");
      this.addPopupToMap("reachableStations");
    })

    //this.addMarkersToMap();
    this.fitMapToMarkers();
  }

  addPopupToMap(layer) {
    // Create a popup, but don't add it to the map yet.
    const popup = new mapboxgl.Popup({
      closeButton: false,
      closeOnClick: false
    });

    this.map.on('mouseenter', layer, (e) => {
      // Change the cursor style as a UI indicator.
      this.map.getCanvas().style.cursor = 'pointer';

      // Copy coordinates array.
      const coordinates = e.features[0].geometry.coordinates.slice();
      const description = e.features[0].properties.description;

      // Ensure that if the map is zoomed out such that multiple
      // copies of the feature are visible, the popup appears
      // over the copy being pointed to.
      while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
        coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
      }

      // Populate the popup and set its coordinates
      // based on the feature found.
      popup.setLngLat(coordinates).setHTML(description).addTo(this.map);
    });

    this.map.on('mouseleave', layer, () => {
      this.map.getCanvas().style.cursor = '';
      popup.remove();
    });
  }

  addMarkersToMap() {
    const markers = this.markersSelectedValue.concat(this.markersReachableValue)
    markers.forEach((marker) => {
      const markerElement = document.createElement("div");
      markerElement.innerHTML = marker.marker_html;
      const popup = new mapboxgl.Popup({ closeButton: false }).setHTML(marker.popup_html);
      new mapboxgl.Marker(markerElement)
        .setLngLat([marker.longitude, marker.latitude])
        .setPopup(popup)
        .addTo(this.map);
    });
  }

  fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();
    bounds.extend(this.selectedStationsValue.data.features[0].geometry.coordinates)
    this.reachableStationsValue.data.features.forEach(feature => {
      bounds.extend(feature.geometry.coordinates.slice())
    });
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 6, duration: 0 });
  }

  fetchReachableStations() {

  }
}

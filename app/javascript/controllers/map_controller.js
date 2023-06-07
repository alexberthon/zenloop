import { Controller } from "@hotwired/stimulus";
import mapboxgl from "mapbox-gl";

export default class extends Controller {
  static values = {
    apiKey: String,
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
      this.#addSelectedStationsToMap();
      this.#addReachableStationsToMap();
      this.#addStrokesToMap();
    })

    this.#fitMapToMarkers();
  }

  #addSelectedStationsToMap() {
    this.map.addSource("selectedStations", {
      type: "geojson",
      data: this.selectedStationsValue
    });

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

    const popup = new mapboxgl.Popup({
      closeButton: false,
      closeOnClick: false
    });

    this.map.on("mouseenter", "selectedStations", (e) => {
      this.#addPopup(popup, e);
    });

    this.map.on("mouseleave", "selectedStations", () => {
      this.map.getCanvas().style.cursor = "";
      popup.remove();
    });
  }

  #addReachableStationsToMap() {
    this.map.addSource("reachableStations", {
      type: "geojson",
      data: this.reachableStationsValue
    });

    this.map.addLayer({
      "id": "reachableStations",
      "type": "circle",
      "source": "reachableStations",
      "paint": {
        "circle-color": [
          "case",
          ["boolean", ["feature-state", "hover"], false],
          "#E60F05",
          "#4264fb",
        ],
        "circle-radius": 6,
        "circle-stroke-width": 2,
        "circle-stroke-color": "#ffffff"
      }
    });

    const popup = new mapboxgl.Popup({
      closeButton: false,
      closeOnClick: false
    });

    this.map.on("mouseenter", "reachableStations", (e) => {
      this.#addPopup(popup, e);

      this.hoveredStationId = e.features[0].id;
      this.map.setFeatureState(
        { source: "reachableStations", id: this.hoveredStationId },
        { hover: true }
      );

      this.hoveredTripId = e.features[0].properties.db_trip_id;
      this.map.setFeatureState(
        { source: "strokes", id: this.hoveredTripId },
        { hover: true }
      );
    });

    this.map.on("mouseleave", "reachableStations", () => {
      this.map.getCanvas().style.cursor = "";
      popup.remove();

      this.map.setFeatureState(
        { source: "strokes", id: this.hoveredTripId },
        { hover: false }
      );
      this.map.setFeatureState(
        { source: "reachableStations", id: this.hoveredStationId },
        { hover: false }
      );
      this.hoveredTripId = null;
      this.hoveredStationId = null;
    });

    this.map.on("mousemove", "reachableStations", (e) => {
      // cursor moves from one station to another, without leaving the layer
      if(e.features[0].id !== this.hoveredStationId) {
        popup.remove();
        this.map.setFeatureState(
          { source: "reachableStations", id: this.hoveredStationId },
          { hover: false }
        );

        this.hoveredStationId = e.features[0].id;
        this.#addPopup(popup, e);
        this.map.setFeatureState(
          { source: "reachableStations", id: this.hoveredStationId },
          { hover: true }
        );
      }
    });
  }

  #addStrokesToMap() {
    this.map.addSource("strokes", {
      type: "geojson",
      data: this.strokesValue
    });

    this.map.addLayer({
      "id": "strokes",
      "type": "line",
      "source": "strokes",
      "layout": {
        "line-join": "round",
        "line-cap": "round"
      },
      "paint": {
        "line-color": [
          "case",
          ["boolean", ["feature-state", "hover"], false],
          "#000",
          "#888",
        ],
        "line-width": [
          "case",
          ["boolean", ["feature-state", "hover"], false],
          2,
          0,
        ]
      }
    });
  }

  #addPopup(popup, e) {
    this.map.getCanvas().style.cursor = "pointer";
    const coordinates = e.features[0].geometry.coordinates;
    const name = e.features[0].properties.name;
    const duration = e.features[0].properties.duration ? `${e.features[0].properties.duration} mins` : "";

    // Ensure that if the map is zoomed out such that multiple
    // copies of the feature are visible, the popup appears
    // over the copy being pointed to.
    while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
      coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
    }

    const html = `<div class="popup"><div>${name}</div><div>${duration}</div></div>`
    popup.setLngLat(coordinates).setHTML(html).addTo(this.map);
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();
    bounds.extend(this.selectedStationsValue.features[0].geometry.coordinates)
    this.reachableStationsValue.features.forEach(feature => {
      bounds.extend(feature.geometry.coordinates)
    });
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 6, duration: 0 });
  }

  #fetchReachableStations() {

  }
}

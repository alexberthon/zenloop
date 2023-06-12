import { Controller } from "@hotwired/stimulus";
import mapboxgl from "mapbox-gl";

export default class extends Controller {
  static targets = ["stations"]

  static values = {
    apiKey: String,
    journey: Object,
    selectedStations: Object,
    reachableStations: Object,
    existingLines: Object,
    tripLines: Object,
    stationListHTML: String
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;
    this.transitionDuration = 300;

    this.map = new mapboxgl.Map({
      container: "journey-map",
      style: "mapbox://styles/cecile-dzy-ncl/clisn3scx002b01pndpm47srl"
    });

    this.map.on("load", () => {
      this.#addSelectedStationsToMap();
      this.#addReachableStationsToMap();
      this.#addExistingLinesToMap();
      this.#addTripLinesToMap();
    })

    this.#fitMapToMarkers();
  }

  disconnect() {
    this.map.remove();
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
        "circle-color": "#00A18E",

        "circle-radius": 6,
        "circle-stroke-width": 2,
        "circle-stroke-color": "#b8f5ee"
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

    this.map.on("mousemove", "selectedStations", (e) => {
      // cursor moves from one station to another, without leaving the layer
      if (e.features[0].id !== this.hoveredStationId) {
        popup.remove();
        this.#addPopup(popup, e);
      }
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
          "#00A18E",
          "#0058AA",
        ],
        "circle-radius": 5,
        "circle-stroke-width": 2,
        "circle-stroke-color": "#8abceb",
        "circle-stroke-opacity": 0,
        "circle-opacity": 0,
        "circle-opacity-transition": {
          "duration": this.transitionDuration,
          "delay": 0,
        },
        "circle-stroke-opacity-transition": {
          "duration": this.transitionDuration,
          "delay": 0
        }
      }
    });

    this.map.setPaintProperty("reachableStations", "circle-opacity", 1);
    this.map.setPaintProperty("reachableStations", "circle-stroke-opacity", 1);

    const popup = new mapboxgl.Popup({
      closeButton: false,
      closeOnClick: false
    });

    this.map.on("mouseenter", "reachableStations", (e) => {
      this.#addPopup(popup, e);
      this.#setHoverStates(e);
    });

    this.map.on("mouseleave", "reachableStations", () => {
      this.map.getCanvas().style.cursor = "";
      popup.remove();
      this.#clearHoverStates();
    });

    this.map.on("mousemove", "reachableStations", (e) => {
      // cursor moves from one station to another, without leaving the layer
      if (e.features[0].id !== this.hoveredStationId) {
        popup.remove();
        this.#addPopup(popup, e);
        this.#clearHoverStates();
        this.#setHoverStates(e);
      }
    });

    this.map.on("click", "reachableStations", (e) => {
      this.clickedStationId = e.features[0].id;
      this.lineId = e.features[0].properties.line_id;
      this.#addStepToJourney(this.lineId);
    });
  }

  #addExistingLinesToMap() {
    this.map.addSource("existingLines", {
      type: "geojson",
      data: this.existingLinesValue
    });

    this.map.addLayer({
      "id": "existingLines",
      "type": "line",
      "source": "existingLines",
      "layout": {
        "line-cap": "round",
        "line-join": "round"
      },
      "paint": {
        "line-color": "#000000",
        "line-width": 1,
        "line-dasharray": [3, 3]
      }
    });
  }

  #addTripLinesToMap() {
    this.map.addSource("tripLines", {
      type: "geojson",
      data: this.tripLinesValue
    });

    this.map.addLayer({
      "id": "tripLinesBackground",
      "type": "line",
      "source": "tripLines",
      "paint": {
        "line-color": "#000000",
        "line-width": 1,
        "line-opacity": [
          "case",
          ["boolean", ["feature-state", "hover"], false],
          0,
          0,
        ]
      }
    });

    this.map.addLayer({
      "id": "tripLinesDash",
      "type": "line",
      "source": "tripLines",
      "paint": {
        "line-color": "#000000",
        "line-width": 1,
        "line-dasharray": [3, 3],
        "line-opacity": [
          "case",
          ["boolean", ["feature-state", "hover"], false],
          1,
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

  #clearHoverStates() {
    this.map.setFeatureState(
      { source: "tripLines", id: this.hoveredTripId },
      { hover: false }
    );
    this.map.setFeatureState(
      { source: "reachableStations", id: this.hoveredStationId },
      { hover: false }
    );
    this.hoveredTripId = null;
    this.hoveredStationId = null;
  }

  #setHoverStates(e) {
    this.hoveredStationId = e.features[0].id;
    this.hoveredTripId = e.features[0].properties.db_trip_id;
    this.map.setFeatureState(
      { source: "reachableStations", id: this.hoveredStationId },
      { hover: true }
    );
    this.map.setFeatureState(
      { source: "tripLines", id: this.hoveredTripId },
      { hover: true }
    );
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();
    const selectedFeatures = this.selectedStationsValue.features;
    bounds.extend(selectedFeatures[selectedFeatures.length - 1].geometry.coordinates)
    this.reachableStationsValue.features.forEach(feature => {
      bounds.extend(feature.geometry.coordinates)
    });
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 6, duration: 0 });
  }

  #addStepToJourney(line_id) {
    const url = `/journeys/${this.journeyValue.id}/steps`;
    const csrfToken = document.head.querySelector("[name='csrf-token']").content;

    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({
        line_id: line_id,
        credentials: "same-origin"
      })
    })
      .then(response => response.json())
      .then((data) => {
        this.map.getSource("selectedStations").setData(JSON.parse(data.selected_stations));
        this.#updateData("reachableStations", JSON.parse(data.reachable_stations));
        this.map.getSource("existingLines").setData(JSON.parse(data.existing_lines));
        this.map.getSource("tripLines").setData(JSON.parse(data.trip_lines));
        console.log(data)
        this.stationsTarget.innerHTML = data.station_list_html
      })
  }

  #updateData(layer, data) {
    this.map.setPaintProperty(layer, "circle-opacity", 0);
    this.map.setPaintProperty(layer, "circle-stroke-opacity", 0);
    setTimeout(() => {
      this.map.getSource(layer).setData(data);
      this.map.setPaintProperty(layer, "circle-opacity", 1);
      this.map.setPaintProperty(layer, "circle-stroke-opacity", 1);
    }, this.transitionDuration);
  }
}

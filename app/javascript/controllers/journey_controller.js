import { Controller } from "@hotwired/stimulus";
import mapboxgl from "mapbox-gl";
import pulsingDot from "pulsing-dot";
import html2canvas from "html2canvas";

function debounce(callback, context, timeout = 300) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => { callback.apply(context, args); }, timeout);
  };
}

export default class extends Controller {
  static targets = [
    "stations",
    "tickets",
    "ticketsHeader",
    "durationInput",
    "stationInput",
    "map",
    "journeyForm",
    "nameInput",
    "photoInput"
  ]

  static values = {
    apiKey: String,
    journey: Object,
    selectedStations: Object,
    reachableStations: Object,
    existingLines: Object,
    tripLines: Object,
    stationListHTML: String,
    stations: Array,
    currentStation: Object,
    currentStepId: String,
    stepsLines: Array,
    stepsStays: Array
  }

  initialize() {
    this.autosave = debounce(this.autosave, this, 1000);
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;
    this.transitionDuration = 300;

    this.map = new mapboxgl.Map({
      container: "journey-map",
      style: "mapbox://styles/alexberthon/cliswkobs00vl01qv25p5ax7h",
      preserveDrawingBuffer: true
    });

    this.map.on("load", () => {
      this.#addSelectedStationsToMap();
      this.#addReachableStationsToMap();
      this.#addExistingLinesToMap();
      this.#addTripLinesToMap();
      this.#addCurrentStationToMap();
      this.map.addImage("pulsing-dot", pulsingDot(this.map), { pixelRatio: 2 });
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
        "circle-radius": 6,
        "circle-stroke-width": 2,
        "circle-color": "#E6612F",
        "circle-stroke-color": "#fad9cd"
      }
    });

    const popup = new mapboxgl.Popup({
      closeButton: false,
      closeOnClick: false
    });

    this.stayPopup = new mapboxgl.Popup({
      closeButton: false,
      closeOnClick: false
    });

    this.#addStayPopup(this.currentStationValue);

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

    this.map.on("click", "selectedStations", (e) => {
      const station = e.features[0];
      this.#fetchReachableStations(station.id);
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
          "#E6612F",
          "#1A66A5",
        ],
        "circle-radius": 5,
        "circle-stroke-width": 1,
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
    }, "selectedStations");

    this.map.setPaintProperty("reachableStations", "circle-opacity", 1);
    this.map.setPaintProperty("reachableStations", "circle-stroke-opacity", 1);

    const popup = new mapboxgl.Popup({
      closeButton: false,
      closeOnClick: false
    })

    const selectedAndReachableOverlapping = (e) => {
      const hoveredFeatures = this.map.queryRenderedFeatures(e.point, { layers: ["reachableStations", "selectedStations"] });
      return hoveredFeatures.length > 0 && hoveredFeatures.some(f => f.source == "selectedStations");
    }

    this.map.on("mouseenter", "reachableStations", (e) => {
      if (selectedAndReachableOverlapping(e)) return;

      this.#addPopup(popup, e);
      this.#setHoverStates(e);
    });

    this.map.on("mouseleave", "reachableStations", () => {
      this.map.getCanvas().style.cursor = "";
      popup.remove();
      this.#clearHoverStates();
    });

    this.map.on("mousemove", "reachableStations", (e) => {
      if (selectedAndReachableOverlapping(e)) return;

      // cursor moves from one station to another, without leaving the layer
      if (e.features[0].id !== this.hoveredStationId) {
        popup.remove();
        this.#addPopup(popup, e);
        this.#clearHoverStates();
        this.#setHoverStates(e);
      }
    });

    this.map.on("click", "reachableStations", (e) => {
      if (selectedAndReachableOverlapping(e)) return;

      console.log(this);
      this.clickedStationId = e.features[0].id;
      this.lineId = e.features[0].properties.line_id;
      this.#addLineStepToJourney(this.lineId);
    });
  }

  #addCurrentStationToMap() {
    this.map.addSource("currentStation", {
      type: "geojson",
      data: this.currentStationValue
    });

    this.map.addLayer({
      "id": "currentStation",
      "type": "symbol",
      "source": "currentStation",
      "layout": {
        "icon-image": "pulsing-dot"
      }
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

        "line-color": [
          "case",
          ["boolean", ["feature-state", "hover"], false],
          "#E60F05",
          "#333"
        ],
        "line-width": [
          "case",
          ["boolean", ["feature-state", "hover"], false],
          3,
          2
        ],
        // "line-width": 2,
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

  #addStayPopup(station) {
    this.stayPopup.remove();
    const coordinates = station.geometry.coordinates;
    const html = `
      <div class="add-stay-popup">
        <a href="#" data-action="click->journey#openModal" data-journey-station-id-param="${station.id}">
          Add a stay <i class="fa-solid fa-chevron-right ms-1"></i>
        </a>
      </div>`;
    this.stayPopup.setLngLat(coordinates)
      .setHTML(html)
      .addClassName("add-stay-popup-container")
      .setOffset([60, 25])
      .addTo(this.map);
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

  #fitMapToMarkers(features) {
    const bounds = new mapboxgl.LngLatBounds();
    if (!features) {
      features = this.selectedStationsValue.features.concat(this.reachableStationsValue.features);
    }
    features.forEach((feature) => {
      bounds.extend(feature.geometry.coordinates)
    })
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 6, duration: 0 });
  }

  #fetchReachableStations(station_id) {
    const url = `/lines/search?from=${station_id}&journey_id=${this.journeyValue.id}`;
    fetch(url, {
      headers: { "Accept": "application/json" }
    })
      .then(response => response.json())
      .then((data) => {
        this.#updateMap(data);
        this.currentStepIdValue = data.current_step_id;
      })
  }

  #addLineStepToJourney(line_id) {
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
        kind: "line",
        line_id: line_id,
        step_id: this.currentStepIdValue,
        credentials: "same-origin"
      })
    })
      .then(response => response.json())
      .then((data) => {
        this.#updateMap(data);
        this.currentStepIdValue = data.current_step_id;
        this.ticketsTarget.innerHTML = data.tickets;
        this.#updateTicketsHeader();
      })
  }

  addStayStepToJourney(event) {
    event.preventDefault();
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
        kind: "stay",
        station_id: this.stationInputTarget.value,
        step_id: this.currentStepIdValue,
        duration: this.durationInputTarget.value * 24 * 60,
        credentials: "same-origin"
      })
    })
      .then(response => response.json())
      .then((data) => {
        this.#updateMap(data);
        this.currentStepIdValue = data.current_step_id;
        this.ticketsTarget.innerHTML = data.tickets;
        this.#updateTicketsHeader();
        this.modal.hide();
      })
  }

  removeStepFromJourney(event) {
    const url = `/steps/${event.params.stepId}`;
    const csrfToken = document.head.querySelector("[name='csrf-token']").content;

    fetch(url, {
      method: "DELETE",
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": csrfToken
      }
    })
      .then(response => response.json())
      .then((data) => {
        this.#updateMap(data);
        this.currentStepIdValue = data.current_step_id;
        event.target.closest(".ticket-wrap").remove();
        this.#updateTicketsHeader();
      })
  }

  #updateMap(data) {
    if (data.selected_stations) {
      const selectedStations = JSON.parse(data.selected_stations);
      this.map.getSource("selectedStations").setData(selectedStations);
      this.selectedStationsValue = selectedStations;
    }
    if (data.reachable_stations) {
      const reachableStations = JSON.parse(data.reachable_stations);
      this.#transitionData("reachableStations", reachableStations);
      this.reachableStationsValue = reachableStations;
    }
    if (data.existing_lines) {
      const existingLines = JSON.parse(data.existing_lines);
      this.map.getSource("existingLines").setData(existingLines);
      this.existingLinesValue = existingLines;
    }
    if (data.trip_lines) {
      const tripLines = JSON.parse(data.trip_lines);
      this.map.getSource("tripLines").setData(tripLines);
      this.tripLinesValue = tripLines;
    }
    if (data.current_station) {
      const currentStation = JSON.parse(data.current_station);
      this.map.getSource("currentStation").setData(currentStation);
      this.#addStayPopup(currentStation);
      this.currentStationValue = currentStation;
    }
  }

  #updateTicketsHeader() {
    if (this.ticketsTarget.children.length > 0) {
      this.ticketsHeaderTarget.classList.remove("d-none");
      this.ticketsHeaderTarget.classList.add("d-block");
    } else {
      this.ticketsHeaderTarget.classList.remove("d-block");
      this.ticketsHeaderTarget.classList.add("d-none");
    }
  }

  #transitionData(layer, data) {
    this.map.setPaintProperty(layer, "circle-opacity", 0);
    this.map.setPaintProperty(layer, "circle-stroke-opacity", 0);
    setTimeout(() => {
      this.map.getSource(layer).setData(data);
      this.map.setPaintProperty(layer, "circle-opacity", 1);
      this.map.setPaintProperty(layer, "circle-stroke-opacity", 1);
    }, this.transitionDuration);
  }

  toggleLineHighlight(event) {
    const state = this.map.getFeatureState({
      source: "existingLines",
      id: event.params.stepId
    });

    this.map.setFeatureState(
      { source: "existingLines", id: event.params.stepId },
      { hover: !state.hover }
    );
  }

  openModal(event) {
    this.modal = new bootstrap.Modal(document.getElementById("stayModal"));
    this.modal.show();
    this.stationInputTarget.value = event.params.stationId;
  }

  validateJourney() {
    this.map.setLayoutProperty("reachableStations", "visibility", "none");
    this.map.setLayoutProperty("currentStation", "visibility", "none");
    this.#fitMapToMarkers(this.selectedStationsValue.features)
    setTimeout(() => {
      html2canvas(this.mapTarget.querySelector("canvas")).then((canvas) => {
        const t = canvas.toDataURL().replace("data:image/jpeg;base64,", "");
        canvas.toBlob(data => {
          const file =  new File([data], `${new Date().getTime()}.jpeg`, { type: "image/jpeg", lastModified: new Date().getTime() });
          const dt = new DataTransfer()
          dt.items.add(file)
          this.photoInputTarget.files = dt.files
          this.journeyFormTarget.submit();
        })
        this.map.setLayoutProperty("reachableStations", "visibility", "visible");
        this.map.setLayoutProperty("currentStation", "visibility", "visible");
      })
    }, 300);
  }

  autosave(event) {
    const url = `/journeys/${this.journeyValue.id}`;
    const csrfToken = document.head.querySelector("[name='csrf-token']").content;

    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({
        name: this.nameInputTarget.value,
        credentials: "same-origin"
      })
    })
  }

  downloadBase64File(contentType, base64Data, fileName) {
    const linkSource = `data:${contentType};base64,${base64Data}`;
    const downloadLink = document.createElement("a");
    downloadLink.href = linkSource;
    downloadLink.download = fileName;
    downloadLink.click()
  }
}

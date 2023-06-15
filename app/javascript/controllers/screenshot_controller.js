import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="screenshot"
export default class extends Controller {
  static targets = ["screenshot"];

  move(event) {
    const xPos = event.offsetX / this.screenshotTarget.offsetWidth * 100;
    const yPos = event.offsetY / this.screenshotTarget.offsetHeight * 100;
    this.screenshotTarget.style.setProperty("background-position", `${xPos}% ${yPos}%`);
  }
}

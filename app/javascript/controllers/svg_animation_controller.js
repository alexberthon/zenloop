import { Controller } from "@hotwired/stimulus"
import { useIntersection } from 'stimulus-use'

// Connects to data-controller="svg-animation"
export default class extends Controller {
  connect() {
    console.log("BRAVO!!!!!!!!!!!!!!");
    useIntersection(this);
  }

  appear() {
    this.element.classList.add("animate")
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["station"]

  connect() {
    console.log("connected")
  }
  newmarker() {
    const element = this.stationTarget
    const name = element.value
    console.log(`${name}!`)
  }
}

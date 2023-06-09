import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  connect() {
    new TomSelect(this.element, {
      create: false,
      maxOptions: 10,
      labelField: 'name',
      searchField: 'name',
    });
  }

}

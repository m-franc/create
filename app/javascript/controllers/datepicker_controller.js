import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

// Connects to data-controller="datepicker"
export default class extends Controller {
  connect() {
    flatpickr(this.element, {
      mode: "range",
      enableTime: true,
      dateFormat: "Y-m-d",
      minDate: new Date(),
    })
  }
}

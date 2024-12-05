import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    this.modal = new Modal(this.element)
  }

  // Ferme la modale après une soumission réussie
  closeModal() {
    this.modal.hide()
  }
}

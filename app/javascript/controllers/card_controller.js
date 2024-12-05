import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    tab: String
  }

  connect() {
    this.element.style.cursor = 'pointer'
  }

  switchTab(event) {
    // Ne pas switcher si on clique sur un bouton ou un lien
    if (event.target.closest('button') || event.target.closest('a') || event.target.closest('.form-check')) {
      return
    }
    
    // Trouve l'onglet correspondant et le clique
    const tab = document.querySelector(`#${this.tabValue}`)
    if (tab) {
      tab.click()
    }
  }
}

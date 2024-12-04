import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "modal"]

  connect() {
    // Suppress console logging
    // console.log("Documents controller connected")
    this.initializeTab()
  }

  initializeTab() {
    // Initialize tab behavior
    const tab = document.querySelector('#document-tab')
    if (tab) {
      tab.addEventListener('shown.bs.tab', (event) => {
        this.initializeModal()
      })
    }
  }

  initializeModal() {
    const modalElement = document.querySelector('#uploadDocumentModal')
    if (!modalElement) return

    try {
      // Only initialize if not already initialized
      if (!modalElement.classList.contains('modal-initialized')) {
        const modal = new bootstrap.Modal(modalElement, {
          keyboard: true,
          backdrop: true,
          focus: true
        })
        modalElement.classList.add('modal-initialized')
      }
    } catch (error) {
      // Silently handle any initialization errors
    }
  }

  disconnect() {
    const modalElement = document.querySelector('#uploadDocumentModal')
    if (!modalElement) return

    try {
      const modal = bootstrap.Modal.getInstance(modalElement)
      if (modal) {
        modal.dispose()
        modalElement.classList.remove('modal-initialized')
      }
    } catch (error) {
      // Silently handle any cleanup errors
    }
  }
}

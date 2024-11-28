import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
    
    // Create an observer to watch for new messages
    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
    })

    // Start observing changes to the messages container
    this.observer.observe(this.element, {
      childList: true,
      subtree: true
    })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  scrollToBottom() {
    requestAnimationFrame(() => {
      this.element.scrollTop = this.element.scrollHeight
    })
  }
}
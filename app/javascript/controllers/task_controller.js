import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "text"]

  connect() {
    console.log("Task controller connected")
  }

  toggle(event) {
    event.preventDefault()
    const form = event.target.closest('form')
    const taskItem = event.target.closest('.task-item')
    const textElement = taskItem.querySelector('[data-task-target="text"]')
    
    const formData = new FormData(form)
    formData.set('completed', event.target.checked)

    fetch(form.action, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json'
      },
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        if (data.completed) {
          textElement.classList.add('text-decoration-line-through', 'text-muted')
          taskItem.classList.add('completed')
        } else {
          textElement.classList.remove('text-decoration-line-through', 'text-muted')
          taskItem.classList.remove('completed')
        }
      }
    })
    .catch(error => {
      console.error('Error:', error)
      event.target.checked = !event.target.checked
    })
  }
}

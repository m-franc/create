import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "text"]

  connect() {
    console.log("Task controller connected")
  }

  toggle(event) {
    const form = event.target.closest('form')
    const taskId = event.target.id
    const taskItem = event.target.closest('.task-item')

    fetch(form.action, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json'
      },
      body: new FormData(form)
    })
    .then(response => response.json())
    .then(data => {
      if (data.completed) {
        taskItem.classList.add('completed')
      } else {
        taskItem.classList.remove('completed')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      // Revert the checkbox state if there's an error
      event.target.checked = !event.target.checked
    })
  }
}

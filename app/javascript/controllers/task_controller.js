import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "text"]

  connect() {
    console.log("Task controller connected")
  }

  openEditModal(event) {
    // Ne pas ouvrir la modal si on clique sur le checkbox
    if (event.target.closest('.form-check')) {
      return
    }
    
    const taskItem = event.currentTarget
    const taskId = taskItem.dataset.taskId
    const editButton = document.querySelector(`.task-item[data-task-id="${taskId}"] .btn-edit`)
    if (editButton) {
      editButton.click()
    }
  }

  toggle(event) {
    event.preventDefault()
    const form = event.target.closest('form')
    const taskId = event.target.closest('.task-item').dataset.taskId
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
        // Trouver toutes les instances de la même tâche
        const allTaskItems = document.querySelectorAll(`.task-item[data-task-id="${taskId}"]`)

        allTaskItems.forEach(taskItem => {
          const textElement = taskItem.querySelector('[data-task-target="text"]')
          const checkbox = taskItem.querySelector('input[type="checkbox"]')

          // Synchroniser l'état du checkbox
          if (checkbox) checkbox.checked = data.completed

          // Synchroniser les classes CSS
          if (data.completed) {
            textElement.classList.add('text-decoration-line-through', 'text-muted')
            taskItem.classList.add('completed')
          } else {
            textElement.classList.remove('text-decoration-line-through', 'text-muted')
            taskItem.classList.remove('completed')
          }
        })
      }
    })
    .catch(error => {
      console.error('Error:', error)
      event.target.checked = !event.target.checked
    })
  }
}

// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "@popperjs/core";
import "bootstrap";
import "components/form";

import { Turbo } from "@hotwired/turbo-rails"

// Disable Turbo for specific forms
document.addEventListener('turbo:load', () => {
  const forms = document.querySelectorAll('form[data-turbo="false"]')
  forms.forEach(form => {
    form.addEventListener('submit', (e) => {
      const submitButton = form.querySelector('input[type="submit"]')
      if (submitButton) {
        submitButton.disabled = true
        submitButton.value = submitButton.dataset.disableWith || 'Processing...'
      }
    })
  })
})

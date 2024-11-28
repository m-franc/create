import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]

  connect() {
    this.suggestionTimeout = null
    this.selectedIndex = -1
    this.suggestions = []
    
    // Ajouter un gestionnaire de clic sur le document pour fermer les suggestions
    document.addEventListener('click', (e) => {
      if (!this.element.contains(e.target)) {
        this.hideSuggestions()
      }
    })
  }

  disconnect() {
    document.removeEventListener('click', this.hideSuggestions)
  }

  async search() {
    clearTimeout(this.suggestionTimeout)
    
    const query = this.inputTarget.value.trim()
    if (query.length === 0) {
      this.hideSuggestions()
      return
    }

    // Attendre un peu avant de faire la requête pour éviter trop d'appels
    this.suggestionTimeout = setTimeout(async () => {
      try {
        const response = await fetch(`/searches/suggestions?query=${encodeURIComponent(query)}`)
        const data = await response.json()
        this.suggestions = data.suggestions
        this.showSuggestions()
      } catch (error) {
        console.error('Erreur lors de la recherche:', error)
      }
    }, 300)
  }

  showSuggestions() {
    if (this.suggestions.length === 0) {
      this.hideSuggestions()
      return
    }

    const html = this.suggestions.map((suggestion, index) => {
      const isDocument = suggestion.type === 'Document'
      const className = `suggestion-item d-flex align-items-center p-2 ${index === this.selectedIndex ? 'active' : ''}`
      
      return `
        <div class="suggestion-item ${className}" data-index="${index}">
          <div class="flex-grow-1">
            <div class="d-flex justify-content-between align-items-center">
              <strong>${this.highlightMatch(suggestion.text)}</strong>
              <span class="badge bg-secondary ms-2">${suggestion.type}</span>
            </div>
            ${suggestion.context ? `<small class="text-muted d-block">${suggestion.context}</small>` : ''}
          </div>
          ${isDocument ? `
            <div class="ms-2">
              <a href="${suggestion.download_url}" class="btn btn-sm btn-outline-primary" title="Télécharger">
                <i class="fas fa-download"></i>
              </a>
            </div>
          ` : ''}
        </div>
      `
    }).join('')

    this.suggestionsTarget.innerHTML = `
      <div class="card shadow">
        <div class="list-group list-group-flush">
          ${html}
        </div>
      </div>
    `
    this.suggestionsTarget.classList.remove('d-none')

    // Ajouter les écouteurs d'événements pour chaque suggestion
    this.suggestionsTarget.querySelectorAll('.suggestion-item').forEach(item => {
      item.addEventListener('click', (e) => {
        const index = parseInt(item.dataset.index)
        const suggestion = this.suggestions[index]
        
        // Si c'est un clic sur le bouton de téléchargement, ne rien faire (l'événement sera géré par le lien)
        if (e.target.closest('.btn-outline-primary')) {
          e.preventDefault()
          return
        }
        
        // Sinon, naviguer vers l'URL principale
        window.location.href = suggestion.url
      })
    })
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add('d-none')
    this.suggestionsTarget.innerHTML = ''
    this.selectedIndex = -1
  }

  highlightMatch(text) {
    const query = this.inputTarget.value.trim().toLowerCase()
    const textLower = text.toLowerCase()
    
    let lastIndex = 0
    const matches = []
    
    // Trouver toutes les positions des caractères de la requête dans le texte
    for (let char of query) {
      const index = textLower.indexOf(char, lastIndex)
      if (index === -1) break
      matches.push(index)
      lastIndex = index + 1
    }
    
    // Si on n'a pas trouvé tous les caractères, retourner le texte tel quel
    if (matches.length !== query.length) return text
    
    // Construire le texte avec le surlignage
    let result = ''
    let currentIndex = 0
    
    matches.forEach(index => {
      result += text.substring(currentIndex, index)
      result += `<span class="highlight">${text[index]}</span>`
      currentIndex = index + 1
    })
    
    result += text.substring(currentIndex)
    return result
  }

  onKeydown(event) {
    if (!this.suggestions.length) return

    switch(event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, this.suggestions.length - 1)
        this.showSuggestions()
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.showSuggestions()
        break
      case 'Enter':
        event.preventDefault()
        if (this.selectedIndex >= 0) {
          const suggestion = this.suggestions[this.selectedIndex]
          window.location.href = suggestion.url
        }
        break
      case 'Escape':
        event.preventDefault()
        this.hideSuggestions()
        break
    }
  }
}

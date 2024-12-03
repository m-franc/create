import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar"]

  connect() {
    // Garder l'état du hover entre les navigations
    if (localStorage.getItem('sidebarExpanded') === 'true') {
      this.sidebarTarget.classList.add('expanded');
    }

    this.sidebarTarget.addEventListener('mouseenter', () => {
      this.sidebarTarget.classList.add('expanded');
      localStorage.setItem('sidebarExpanded', 'true');
    });

    this.sidebarTarget.addEventListener('mouseleave', () => {
      this.sidebarTarget.classList.remove('expanded');
      localStorage.setItem('sidebarExpanded', 'false');
    });

    // Empêcher la sidebar de se rétracter pendant la navigation
    document.addEventListener('turbo:before-render', () => {
      if (this.isHovered()) {
        this.sidebarTarget.classList.add('expanded');
      }
    });
  }

  isHovered() {
    const rect = this.sidebarTarget.getBoundingClientRect();
    const x = event.clientX;
    const y = event.clientY;

    return (
      x >= rect.left &&
      x <= rect.right &&
      y >= rect.top &&
      y <= rect.bottom
    );
  }
}

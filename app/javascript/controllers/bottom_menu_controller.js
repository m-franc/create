import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menuItem", "ellipse"];

  connect() {
    // Active le premier élément ("Home") par défaut
    const initialItem = this.menuItemTargets.find(item => item.dataset.menu === "home");
    this.activateMenu(initialItem);
  }

  selectMenu(event) {
    const selectedItem = event.currentTarget;

    // Active le menu cliqué
    this.activateMenu(selectedItem);

    // Gérer l'affichage du project_menu
    if (selectedItem.dataset.menu === "create") {
      document.getElementById("project-menu-wrapper").style.display = "flex";
    } else {
      document.getElementById("project-menu-wrapper").style.display = "none";
    }
  }

  activateMenu(item) {
    // Supprime "active" de tous les items
    this.menuItemTargets.forEach(menuItem => menuItem.classList.remove("active"));

    // Ajoute "active" à l'élément sélectionné
    item.classList.add("active");

    // Déplace l'ellipse
    this.updateEllipse(item);
  }

  updateEllipse(selectedItem) {
    const ellipse = this.ellipseTarget;

    // Récupère les dimensions et la position de l'élément sélectionné
    const itemRect = selectedItem.getBoundingClientRect();
    const menuRect = this.element.getBoundingClientRect();

    // Calcule la position horizontale (centre de l'icône active par rapport au menu)
    const itemCenter = itemRect.left + itemRect.width / 2;
    const ellipseLeft = itemCenter - menuRect.left - ellipse.offsetWidth / 2;

    // Ajustement global à gauche pour corriger le décalage
    const offsetCorrection = -150; // Ajuster cette valeur si nécessaire

    // Met à jour la position de l'ellipse
    ellipse.style.transform = `translateX(${ellipseLeft + offsetCorrection}px)`;
  }
}

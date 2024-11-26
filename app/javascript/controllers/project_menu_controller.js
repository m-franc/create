import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menuItem", "activeBlock"];

  connect() {
    const defaultItem = this.menuItemTargets.find(item => item.dataset.menu === "projects");
    this.activateMenu(defaultItem);
  }

  selectMenu(event) {
    const selectedItem = event.currentTarget;
    this.activateMenu(selectedItem);
  }

  activateMenu(selectedItem) {
    this.menuItemTargets.forEach(item => item.classList.remove("active"));
    selectedItem.classList.add("active");
    this.updateActiveBlock(selectedItem);
  }

  updateActiveBlock(selectedItem) {
    const activeBlock = this.activeBlockTarget;
    const itemRect = selectedItem.getBoundingClientRect();
    const menuRect = this.element.getBoundingClientRect();
    const left = itemRect.left - menuRect.left;

    let width = 105;
    if (selectedItem.dataset.menu === "projects" || selectedItem.dataset.menu === "schedule") {
      width = 90;
    }

    activeBlock.style.width = `${width}px`;
    activeBlock.style.left = `${left}px`;
  }
}

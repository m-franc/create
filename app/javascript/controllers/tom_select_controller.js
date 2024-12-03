import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { options: Object };

  connect() {
    const defaultOptions = {
      render: {
        option: function(data, escape) {
          return `<div class="option">${escape(data.text)}</div>`;
        },
        item: function(data, escape) {
          return `<div class="item">${escape(data.text)}</div>`;
        }
      },
      dropdownParent: 'body',
      plugins: {
        clear_button: {
          title: 'Supprimer'
        }
      }
    };

    const options = { ...defaultOptions, ...this.optionsValue };
    new TomSelect(this.element, options);
  }
}

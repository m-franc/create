document.addEventListener("turbo:load", () => {
  const pages = document.querySelectorAll(".page");
  const projectContainer = document.querySelector(".project-red");
  const header = document.querySelector(".count");
  let activePage = 1;
  const nbPage = pages.length;

  // Affiche la première page et crée les numéros de pages
  if (pages.length > 0) {
    pages[0].style.display = "block"; // Affiche la première page
    pages.forEach((page, index) => {
      let element = document.createElement("div");
      element.id = "num" + (index + 1);
      element.classList.add("page-num");
      if (activePage === index + 1) {
        element.classList.add("active-num");
      }
      element.innerHTML = index + 1;
      header.appendChild(element);
    });
  }

  // Gérer les boutons
  const nextButtons = document.querySelectorAll("button#button-n");
  for (const button of nextButtons) {
    button.addEventListener("click", pageSuivante);
  }

  // Gérer le bouton précédent
  const prevButtons = document.querySelectorAll("button#button-b");
  for (const button of prevButtons) {
    button.addEventListener("click", pagePrecedente);
  }

  function pageSuivante() {
    if (activePage < nbPage) {
      const currentPage = pages[activePage - 1];
      const nextPage = pages[activePage];

      // Applique la transformation et l'opacité pour la page actuelle
      projectContainer.style.transition = "transform 0.3s ease, opacity 0.3s ease"; // Transition fluide
      projectContainer.style.transform = "translateX(-50%)"; // Déplace le conteneur vers la gauche
      projectContainer.style.opacity = "0"; // Réduit l'opacité à 0

      setTimeout(() => {
        projectContainer.style.transform = "translateX(40%)"; // Applique la seconde transformation après la première
      }, 300); // 3
      // Cache la page actuelle et affiche la suivante après la transition
      setTimeout(() => {
        currentPage.style.display = "none"; // Cache la page actuelle
        nextPage.style.display = "block"; // Affiche la suivante

        // Redonne la position centrale à la nouvelle page
        projectContainer.style.transition = "transform 0.5s ease, opacity 0.5s ease";
        projectContainer.style.transform = "translateX(0)"; // Remet le conteneur à sa position centrale
        projectContainer.style.opacity = "1"; // Réinitialise l'opacité à 1

        // Met à jour la classe active pour la page suivante
        document.querySelector(".active-num").classList.remove("active-num");
        activePage++;
        document.querySelector("#num" + activePage).classList.add("active-num");
      }, 500); // Durée de la transition avant de cacher la page et afficher la suivante
    }
    }

  function pagePrecedente() {
    if (activePage > 1) {
      const currentPage = pages[activePage - 1];
      const prevPage = pages[activePage - 2];

      // Applique la transformation et l'opacité pour la page actuelle
      projectContainer.style.transition = "transform 0.5s ease, opacity 0.2s ease";
      projectContainer.style.transform = "translateX(50%)"; // Déplace le conteneur vers la droite
      projectContainer.style.opacity = "0"; // Réduit l'opacité à 0

      setTimeout(() => {
        projectContainer.style.transform = "translateX(-50%)"; // Applique la seconde transformation après la première
      }, 300); // 3
      // Cache la page actuelle et affiche la page précédente
      setTimeout(() => {
        currentPage.style.display = "none"; // Cache la page actuelle
        prevPage.style.display = "block"; // Affiche la page précédente

        // Redonne la position centrale à la page précédente
        projectContainer.style.transition = "transform 0.5s ease, opacity 0.5s ease";
        projectContainer.style.transform = "translateX(0)"; // Remet le conteneur à sa position centrale
        projectContainer.style.opacity = "1"; // Réinitialise l'opacité à 1

        // Met à jour la classe active pour la page précédente
        document.querySelector(".active-num").classList.remove("active-num");
        activePage--;
        document.querySelector("#num" + activePage).classList.add("active-num");
      }, 500); // Durée de la transition avant de cacher la page et afficher la précédente
    }
  }
}
)

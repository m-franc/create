document.addEventListener("turbo:load", () => {
  const pages = document.querySelectorAll(".page");
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
        element.classList.add("active");
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
      pages[activePage - 1].style.display = "none"; // Cache la page actuelle
      pages[activePage].style.display = "block"; // Affiche la suivante

      document.querySelector(".active").classList.remove("active")
      activePage++;
      console.log(pages[activePage]);

      document.querySelector("#num"+activePage).classList.add("active")
    }
  }

  function pagePrecedente() {
      pages[activePage - 1].style.display = "none"; // Cache la page actuelle
      pages[activePage - 2].style.display = "block"; // Affiche la suivante

      document.querySelector(".active").classList.remove("active")
      activePage--;
      console.log(pages[activePage]);

      document.querySelector("#num"+activePage).classList.add("active")
    }
  }
);

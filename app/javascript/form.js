const pages = document.querySelectorAll(".page");
const header = document.querySelector(".count ");
const nbPage = pages.length;
let activePage = 1;
window.onload = () => {
  document.querySelector(".page").style.display = "initial";

  pages.forEach((page, index) => {
    let element = document.createElement("div");
    element.id = "num" + (index + 1);
    element.classList.add("page-num");
    if (activePage == index + 1) {
      element.classList.add("active");
    }
    element.innerHTML = index + 1;
    header.appendChild(element);
  });
};
let buttons = document.querySelectorAll("button[type=button]");

for (let button of buttons) {
  button.addEventListener("click", pageSuivante);
}

function pageSuivante() {
  for (let page of pages) {
    page.style.display = "none";
  }

  this.parentElement.nextElementSibling.style.display = "initial";

  activePage++;
}

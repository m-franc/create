document.addEventListener("show.bs.modal", function (event) {
  const modal = event.target;
  document.body.append(modal);
});

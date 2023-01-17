function toggleForm() {
  var formContainer = document.getElementById("form-container");
  if (formContainer.style.display === "none") {
    formContainer.style.display = "block";
  } else {
    formContainer.style.display = "none";
  }

  var logo = document.querySelector(".logo");
  logo.classList.toggle("hidden");
}

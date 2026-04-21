const passwordInput = document.getElementById("password");
const togglePasswordBtn = document.getElementById("togglePassword");
const errorBox = document.getElementById("errorBox");
const loginBtn = document.getElementById("loginBtn");

togglePasswordBtn.addEventListener("click", () => {
    const visible = passwordInput.type === "text";
    passwordInput.type = visible ? "password" : "text";
    togglePasswordBtn.textContent = visible ? "Hiện" : "Ẩn";
});

loginBtn.addEventListener("click", () => {
    errorBox.hidden = true;
});

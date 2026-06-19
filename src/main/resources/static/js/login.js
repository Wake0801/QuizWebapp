const passwordInput = document.getElementById("password");
const togglePasswordBtn = document.getElementById("togglePassword");
const errorBox = document.getElementById("errorBox");
const loginBtn = document.getElementById("loginBtn");
const accountLabel = document.getElementById("accountLabel");
const accountInput = document.getElementById("account");
const accountHint = document.getElementById("accountHint");
const roleInputs = document.querySelectorAll('input[name="role"]');

function updateLoginMode({ resetInput = true } = {}) {
    const selectedRole = document.querySelector('input[name="role"]:checked')?.value;

    if (selectedRole === "SINHVIEN") {
        accountLabel.textContent = "Mã SV";
        accountInput.placeholder = "Nhập mã sinh viên, ví dụ: SV000001";
        accountInput.autocomplete = "off";
        accountHint.textContent = "Sinh viên nhập mã số sinh viên và mật khẩu sinh viên.";
    } else if (selectedRole === "PGV") {
        accountLabel.textContent = "Login";
        accountInput.placeholder = "Nhập login PGV, ví dụ: pgv1";
        accountInput.autocomplete = "username";
        accountHint.textContent = "PGV đăng nhập bằng loginname và mật khẩu riêng.";
    } else {
        accountLabel.textContent = "Login";
        accountInput.placeholder = "Nhập login giảng viên, ví dụ: gv1";
        accountInput.autocomplete = "username";
        accountHint.textContent = "Giảng viên đăng nhập bằng loginname và mật khẩu riêng.";
    }

    if (resetInput) {
        accountInput.value = "";
        passwordInput.value = "";
    }

    if (errorBox) {
        errorBox.hidden = true;
    }
}

togglePasswordBtn.addEventListener("click", () => {
    const visible = passwordInput.type === "text";
    passwordInput.type = visible ? "password" : "text";
    togglePasswordBtn.textContent = visible ? "Hiện" : "Ẩn";
});

roleInputs.forEach((input) => {
    input.addEventListener("change", () => updateLoginMode());
});

loginBtn.addEventListener("click", () => {
    if (errorBox) {
        errorBox.hidden = true;
    }
});

updateLoginMode({ resetInput: false });

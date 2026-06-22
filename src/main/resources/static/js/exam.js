const toolbar = document.querySelector(".exam-toolbar");
const form = document.getElementById("examForm");
const timerText = document.getElementById("timerText");
const answeredCounter = document.getElementById("answeredCounter");
const questionButtons = Array.from(document.querySelectorAll(".question-index"));

const attemptId = toolbar ? toolbar.dataset.attemptId : "";
const autosaveUrl = toolbar ? toolbar.dataset.autosaveUrl : "";

function formatTime(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60).toString().padStart(2, "0");
    const seconds = (totalSeconds % 60).toString().padStart(2, "0");
    return `${minutes}:${seconds}`;
}

function questionIdFromInput(input) {
    const match = input.name.match(/^answers\[(\d+)]$/);
    return match ? match[1] : "";
}

function saveAnswer(questionId, value, keepalive = false) {
    if (!attemptId || !autosaveUrl || !questionId || !value) {
        return Promise.resolve();
    }

    const body = new URLSearchParams();
    body.set("maBt", attemptId);
    body.set("cauHoi", questionId);
    body.set("dapAn", value);

    return fetch(autosaveUrl, {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
        },
        body,
        keepalive
    }).catch(() => undefined);
}

function saveCheckedAnswers(keepalive = false) {
    const selectedInputs = document.querySelectorAll(".option-list input[type='radio']:checked");
    selectedInputs.forEach((input) => {
        saveAnswer(questionIdFromInput(input), input.value, keepalive);
    });
}

function updateAnsweredState() {
    let answered = 0;
    questionButtons.forEach((button) => {
        const questionId = button.dataset.questionId;
        const selected = document.querySelector(`input[name="answers[${questionId}]"]:checked`);
        button.classList.toggle("is-answered", Boolean(selected));
        if (selected) {
            answered += 1;
        }
    });
    answeredCounter.textContent = answered.toString();
}

if (toolbar && form && timerText) {
    let remainingSeconds = Number(toolbar.dataset.remainingSeconds || 0);
    timerText.textContent = formatTime(Math.max(remainingSeconds, 0));

    const timer = window.setInterval(() => {
        remainingSeconds -= 1;
        timerText.textContent = formatTime(Math.max(remainingSeconds, 0));
        if (remainingSeconds <= 0) {
            window.clearInterval(timer);
            form.requestSubmit();
        }
    }, 1000);
}

questionButtons.forEach((button) => {
    button.addEventListener("click", () => {
        const target = document.querySelector(button.dataset.target);
        if (target) {
            target.scrollIntoView({ behavior: "smooth", block: "start" });
        }
    });
});

document.querySelectorAll(".option-list input[type='radio']").forEach((input) => {
    input.addEventListener("change", () => {
        updateAnsweredState();
        saveAnswer(questionIdFromInput(input), input.value);
    });
});

window.setInterval(() => saveCheckedAnswers(), 10000);
window.addEventListener("beforeunload", () => saveCheckedAnswers(true));

updateAnsweredState();

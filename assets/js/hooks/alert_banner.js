export default {
  mounted() {
    const TIME_TO_SHOW_ALERT = 3000;

    window.addEventListener("phx:new_alert", (e) => {
      const alertMessage = e.detail.message;
      const alertTimestamp = e.detail.timestamp;

      let banner = document.querySelector(".alert-banner");
      let alertMessageElement = banner.querySelector(".alert-message");

      if (banner) {
        banner.style.display = "flex";

        alertMessageElement.textContent = `[${alertTimestamp}] ${alertMessage}`;
        banner.classList.add("animate-fade-in");

        setTimeout(() => {
          banner.classList.remove("animate-fade-in");
          banner.style.display = "none";
        }, TIME_TO_SHOW_ALERT);
      }
    });

    const closeButton = document.querySelector(".close-btn");
    if (closeButton) {
      closeButton.addEventListener("click", () => {
        let banner = document.querySelector(".alert-banner");
        if (banner) {
          banner.style.display = "none";
        }
      });
    }
  },
};

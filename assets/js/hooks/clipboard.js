export default {
  mounted() {
    this.el.addEventListener("click", (e) => {
      // Prevent event propagation to avoid triggering other events
      e.preventDefault();
      e.stopPropagation();

      const text = this.el.dataset.copyValue;

      if (text) {
        navigator.clipboard
          .writeText(text)
          .then(() => {
            this.pushEventTo(
              this.el.getAttribute("phx-target"),
              "clipboard_copied",
              { text }
            );
          })
          .catch((err) => {
            console.error("Could not copy text: ", err);
          });
      }
    });
  },
};

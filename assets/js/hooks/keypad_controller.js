export default {
  mounted() {
    window.addEventListener("keydown", this.handleKeyDown.bind(this));
  },

  handleKeyDown(e) {
    if (e.key >= "0" && e.key <= "9") {
      this.pushEvent("keypad-press", { key: e.key });
    } else if (e.key === "Enter" || e.key === "#") {
      this.pushEvent("keypad-submit", {});
    } else if (
      e.key === "Backspace" ||
      e.key === "Delete" ||
      e.key === "Escape"
    ) {
      this.pushEvent("keypad-clear", {});
    }
  },

  destroyed() {
    window.removeEventListener("keydown", this.handleKeyDown.bind(this));
  },
};

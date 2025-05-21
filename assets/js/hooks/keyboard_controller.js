export default {
  mounted() {
    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape") {
        this.pushEvent("keyboard_escape", {});
      }
    });

    window.addEventListener("keydown", (event) => {
      if (event.key == 32 && event.target == document.body) {
        event.preventDefault();
      }
    });
  },

  destroyed() {
    document.removeEventListener("keydown", this.handleKeyDown);
  },
};

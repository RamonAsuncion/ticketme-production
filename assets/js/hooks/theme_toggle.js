// NOTE: needs to be refactored to not be included in app.js
// adds or removes the 'dark' class from <html> based on the `theme` in localStorage,
// if given, or default preference otherwise.
// function set_theme() {
//   if (
//     localStorage.theme === "dark" ||
//     (!("theme" in localStorage) &&
//       window.matchMedia("(prefers-color-scheme: dark)").matches)
//   ) {
//     document.documentElement.classList.add("dark");
//   } else {
//     document.documentElement.classList.remove("dark");
//   }
// }

// // Exposes function to toggle dark mode on and off.
// window.toggleDarkMode = () => {
//   if (
//     localStorage.theme === "dark" ||
//     (!("theme" in localStorage) &&
//       window.matchMedia("(prefers-color-scheme: dark)").matches)
//   ) {
//     localStorage.theme = "light";
//   } else {
//     localStorage.theme = "dark";
//   }
//   set_theme();
// };

export default {
  mounted() {
    this.setTheme();

    // Handle event from phoenix.
    this.handleEvent("toggle-theme", () => {
      this.toggleDarkMode();
    });
  },

  setTheme() {
    if (
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
  },

  toggleDarkMode() {
    if (
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      localStorage.theme = "light";
    } else {
      localStorage.theme = "dark";
    }
    this.setTheme();
  },
};

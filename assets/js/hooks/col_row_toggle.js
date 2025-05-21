export default {
  mounted() {
    // Retrieve view_mode from cookies first, then fallback to localStorage
    let viewMode =
      getCookie("view_mode") || localStorage.getItem("view_mode") || "grid";

    this.pushEvent("set-view-mode", { view_mode: viewMode });

    // Send stored view_mode to LiveView
    this.pushEvent("col-row-toggle", { view_mode: viewMode });

    // Event listener for toggling view mode
    this.el.addEventListener("click", () => {
      let currentMode =
        getCookie("view_mode") || localStorage.getItem("view_mode") || "grid";
      let newMode = currentMode === "grid" ? "column" : "grid";

      // TODO: Not saving what layout to local storage.

      // Save new mode in both cookies and localStorage
      setCookie("view_mode", newMode, 365);
      localStorage.setItem("view_mode", newMode);

      // Send the new mode to LiveView
      this.pushEvent("col-row-toggle", { view_mode: newMode });
    });

    // Update localStorage and cookies when LiveView requests a change
    this.handleEvent("update-local-storage", (payload) => {
      setCookie("view_mode", payload.view_mode, 365);
      localStorage.setItem("view_mode", payload.view_mode);
    });
  },
};

// Function to set a cookie
function setCookie(name, value, days) {
  let expires = "";
  if (days) {
    let date = new Date();
    date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
    expires = "; expires=" + date.toUTCString();
  }
  document.cookie = `${name}=${value}; path=/; ${expires}`;
}

// Function to get a cookie
function getCookie(name) {
  let nameEQ = `${name}=`;
  let ca = document.cookie.split(";");
  for (let i = 0; i < ca.length; i++) {
    let c = ca[i].trim();
    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
  }
  return null;
}

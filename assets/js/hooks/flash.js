const Flash = {
  mounted() {
    // Automatically hide flash messages after 5 seconds
    setTimeout(() => {
      this.el.style.opacity = "0";
      setTimeout(() => this.el.remove(), 150);
    }, 5000);
  },
};

export default Flash;

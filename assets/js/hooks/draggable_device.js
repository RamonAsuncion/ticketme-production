export default {
  /**
   * Needed to actually change viewable device box.
   * TODO: This needs fixing.
   */
  mounted() {
    this.el.addEventListener("dragstart", (e) => {
      const deviceId = this.el.dataset.deviceId;
      console.log("dragstart", deviceId);
      e.dataTransfer.setData("deviceId", deviceId);
      this.pushEventTo(this.el, "drag_start", { device: deviceId });
    });

    this.el.addEventListener("dragover", (e) => {
      e.preventDefault();
    });

    this.el.addEventListener("drop", (e) => {
      e.preventDefault();
      const deviceId = this.el.dataset.deviceId;
      const sourceId = e.dataTransfer.getData("deviceId");
      console.log("drop", deviceId, sourceId);
      this.pushEventTo(this.el, "drop", { device: deviceId, source: sourceId });
    });
  },
};

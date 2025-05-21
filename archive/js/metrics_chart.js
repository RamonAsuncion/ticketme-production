import { Chart } from "chart.js";

export default {
  mounted() {
    console.log("Mounted hook triggered!");
    const ctx = this.el.getContext("2d");
    if (!ctx) {
      console.error("Canvas context not found!");
    }
    this.chart = new Chart(ctx, {
      type: "line",
      data: this.getChartData(),
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: false,
        plugins: {
          legend: {
            display: true,
            position: "top",
          },
        },
        tooltip: {
          mode: "index",
          intersect: false,
        },
        scales: {
          x: {
            type: "category",
            title: {
              display: true,
              text: "Time",
            },
          },
          y: {
            beginAtZero: false,
            title: {
              display: true,
              text: "Value",
            },
          },
        },
      },
    });
    /**
     * This function is specifically used to handle
     * events pushed from the backend.
     */
    window.addEventListener("phx:update-points", (e) => {
      const newData = e.detail.data;
      const updatedMetrics = e.detail.metrics;

      // console.log("New data received:", newData);

      const currentData = JSON.parse(this.el.dataset.metrics || "[]");
      currentData.push(newData);
      const latestDataPoints = currentData.slice(-10); // Get the latest 10 points

      this.el.dataset.metrics = JSON.stringify(currentData);

      // TODO: Update temperature.
      this.chart.data.labels = latestDataPoints.map((m) => m.time_recorded);
      this.chart.data.datasets[0].data = latestDataPoints.map(
        (m) => m.temperature
      );
      this.chart.update();
      const metricsContainer = this.el.closest(".metrics-container");
      metricsContainer.querySelector(".current-temperature").innerText =
        updatedMetrics.current_temperature;
      metricsContainer.querySelector(".high-temperature").innerText =
        updatedMetrics.high_temperature;
      metricsContainer.querySelector(".low-temperature").innerText =
        updatedMetrics.low_temperature;
    });
  },
  /**
   * Note:
   * This is called when a component is rerendered.
   * This method does not listen for events directly.
   */
  updated() {
    // this.chart.data = this.getChartData();
    this.chart.update();
  },
  destroyed() {
    if (this.chart) {
      this.chart.destroy(); // TODO: This might need some fixing.
    }
  },
  getChartData() {
    const metrics = JSON.parse(this.el.dataset.metrics);
    // console.log(this.el.dataset.metrics);
    const latestDataPoints = metrics.slice(-10); // Get latest 10 points.
    return {
      labels: latestDataPoints.map((m) => m.time_recorded),
      /**
       * TODO: Should not be temperature. Probably a generic type and should be passed by Phoenix.
       */
      datasets: [
        {
          label: "Temperature",
          data: latestDataPoints.map((m) => m.temperature),
          borderColor: "rgb(160, 32, 140)",
          tension: 0.1,
          borderWidth: 2,
          fill: false,
          pointRadius: 5,
          pointBackgroundColor: "rgb(160, 32, 140)",
        },
      ],
    };
  },
};

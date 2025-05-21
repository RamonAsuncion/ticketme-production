import Chart from "chart.js/auto";

export default {
  mounted() {
    const ctx = this.el.getContext("2d");
    this.chart = new Chart(ctx, {
      type: "line",
      data: this.getChartData(),
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: false,
        plugins: {
          legend: {
            position: "top",
          },
          tooltip: {
            mode: "index",
            intersect: false,
          },
        },
        scales: {
          y: {
            beginAtZero: false,
          },
        },
        interaction: {
          mode: "nearest",
          axis: "x",
          intersect: false,
        },
      },
    });

    window.addEventListener("resize", () => {
      this.chart.resize();
    });
  },
  updated() {
    this.chart.data = this.getChartData();
    this.chart.update("none");
  },
  destroyed() {
    if (this.chart) {
      this.chart.destroy();
    }
  },
  getChartData() {
    const metrics = JSON.parse(this.el.dataset.metrics || "{}");
    const timestamps = metrics.timestamps || [];
    const series = metrics.series || [];

    return {
      labels: timestamps,
      datasets: series.map((s) => ({
        label: s.label,
        data: s.data,
        borderColor: s.color,
        backgroundColor: s.color + "20", // 20% transparency
        fill: false,
        tension: 0.4,
      })),
    };
  },
};

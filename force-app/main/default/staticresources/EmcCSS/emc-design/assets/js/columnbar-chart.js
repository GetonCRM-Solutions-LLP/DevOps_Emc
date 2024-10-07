
// Column chart
// ------------------------------

var ctx = document.getElementById("myChart").getContext('2d');



var myChart = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: ["Octomber", "November", "December"],
        datasets: [{
            // label: '# of Votes',
            data: [10000, 20000, 30000],
            backgroundColor: [
                'rgb(185, 189, 195)',
                'rgb(185, 189, 195)',
                'rgb(185, 189, 195)'
            ],
            hoverBackgroundColor: "rgb(49, 58, 73)",
        }],

    },
    options: {
        tooltips: {
            custom: function (tooltip) {
                if (!tooltip) return;
                // disable displaying the color box;
                tooltip.displayColors = false;
            },
            titleFontSize: 80,
            bodyFontSize: 20,
            enabled: true,
            mode: 'single',
            callbacks: {
                label: function (tooltipItems, data) {
                    return tooltipItems.yLabel;
                },

                labelColor: function (tooltipItem, chart) {
                    return {
                        backgroundColor: 'rgb(255, 0, 0)'
                    }
                },
                title: function (tooltipItem, data) {
                    return;
                }
            },
            backgroundColor: '#78bc42'
        },
        scales: {
            yAxes: [{
                ticks: {
                    beginAtZero: true
                }
            }],
            xAxes: [{
                gridLines: {
                    display: false
                }
            }]
        }
    }
});
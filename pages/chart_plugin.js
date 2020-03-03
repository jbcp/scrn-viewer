Chart.plugins.register({
    afterDraw: function (chart, easing) {
        if (chart.config.options.showValue) {
            var ctx = chart.chart.ctx;
            var fontSize = chart.config.options.showValue.fontSize || "9";
            var fontStyle = chart.config.options.showValue.fontStyle || "Arial";
            ctx.font = fontSize + "px " + fontStyle;
            ctx.textAlign = chart.config.options.showValue.textAlign || "center";
            ctx.textBaseline = chart.config.options.showValue.textAlign || "bottom";

            chart.config.data.datasets.forEach(function (dataset, i) {
                ctx.fillStyle = dataset.fontColor || chart.config.options.showValue.textColor || "#000";
                dataset.data.forEach(function (data, j) {
                    if (dataset.hideValue != true) {
                        var txt = Math.round(data * 100) / 100;
                        var xCoordinate = dataset._meta[chart.id].data[j]._model.x;
                        var yCoordinate = dataset._meta[chart.id].data[j]._model.y;
                        var yCoordinateResult;

                        if (dataset.type == 'line') {
                            yCoordinateResult = yCoordinate + 21 > chart.scales[chart.options.scales.xAxes[0].id].top ? chart.scales[chart.options.scales.xAxes[0].id].top : yCoordinate + 21;
                        } else {
                            yCoordinateResult = yCoordinate - 0;
                        }
                        ctx.fillText(txt, xCoordinate, yCoordinateResult);
                    }
                });
            });
        }
    }
});


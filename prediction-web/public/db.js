$(function() {
    function parseTime(time) {
        return time + ":00-" + time + ":59"
    }

    function createElement(prediction) {
        let { name, weekday, time, predictionValue } = prediction;
        let date = (new Date(weekday).toLocaleString(navigator.language, { weekday: 'long' }));
        return `
		<tr
		  <td>${name}</td>
		  <td>${date}</td>
		  <td>${parseTime(time)}</td>
		  <td class="prediction-value">${predictionValue}</td>
		</tr>`;
    }

    fetch("/predictions")
        .then(res => res.json())
        .then(predictions => {
            var elements = $();
            for (let x in predictions) {
                let prediction = predictions[x];
                if (prediction.name != "") {
                    elements = elements.add(createElement(prediction));
                }
            }
            $('tbody').append(elements);
        });



})
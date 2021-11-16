curl -v  http://192.168.49.2:30467/v2/subscriptions -s -S -H 'Content-Type: application/json' -d @- <<EOF
{
  "description": "A subscription to get ticket predictions",
  "subject": {
	"entities": [
  	{
    	"id": "ResTicketPrediction1",
    	"type": "ResTicketPrediction"
  	}
	],
	"condition": {
  	"attrs": [
      "predictionId",
      "socketId",
      "predictionValue",
      "name",
      "weekday",
      "time"
  	]
	}
  },
  "notification": {
	"http": {
  	"url": "http://web-service:3000/notify"
	},
	"attrs": [
      "predictionId",
      "socketId",
      "predictionValue",
      "name",
      "weekday",
      "time"
	]
  },
  "expires": "2040-01-01T14:00:00.00Z",
  "throttling": 5
}
EOF
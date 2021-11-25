curl -v  $1/v2/subscriptions -s -S -H 'Content-Type: application/json' -d @- <<EOF
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
  	"url": "http://draco:5050/v2/notify"
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
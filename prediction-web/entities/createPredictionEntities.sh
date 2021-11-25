curl $1/v2/entities -s -S -H 'Content-Type: application/json' -d @- <<EOF
{
  "id": "ReqTicketPrediction1",
  "type": "ReqTicketPrediction",
  "predictionId": {
    "value": 0,
    "type": "String"
  },
  "socketId": {
    "value": 0,
    "type": "String"
  },
  "name":{
    "value": 0,
    "type": "String"
  },
  "year":{
    "value": 0,
    "type": "Int"
  },
  "month":{
    "value": 0,
    "type": "Int"
  },
  "day":{
    "value": 0,
    "type": "Int"
  },
  "weekday": {
    "value": 0,
    "type": "Integer"
  },
  "time": {
    "value": 0,
    "type": "Integer"
  }
}
EOF




curl $1/v2/entities -s -S -H 'Content-Type: application/json' -d @- <<EOF
{
  "id": "ResTicketPrediction1",
  "type": "ResTicketPrediction",
  "predictionId": {
    "value": "0",
    "type": "String"
  },
  "socketId": {
    "value": 0,
    "type": "String"
  },
  "predictionValue":{
    "value": 0,
    "type": "Integer"
  },
  "name":{
    "value": 0,
    "type": "String"
  },
  "weekday":{
    "value": 0,
    "type": "Integer"
  },
  "time": {
    "value": 0,
    "type": "Integer"
  }
}
EOF

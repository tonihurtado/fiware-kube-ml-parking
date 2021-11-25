const express = require('express');
const app = express();
const server = require('http').Server(app);
const io = require('socket.io')(server);
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const URL_CB = process.env.URL_CB || "http://tfm.test/orion" //"http://orion:1026/v2/entities";
const PORT = process.env.PORT ? (process.env.PORT) : 3000;
const MONGO_URI = process.env.MONGO_URI || "mongodb://mongodb-svc:27017/sth_test";
const fetch = require('cross-fetch')
console.log("Orion URL: " + URL_CB);

const connectWithRetry = () => {
    mongoose.connect(MONGO_URI).then(() => {
        console.log('MongoDB is connected to the web');
    }).catch(err => {
        console.log('MongoDB connection with web unsuccessful, retry after 5 seconds.');
        setTimeout(connectWithRetry, 5000);
    })
}

connectWithRetry()

const createAttr = (attr) => {
    return { "value": attr, "type": isNaN(attr) ? "String" : "Integer" };
}



const updateEntity = (data) => {
    console.log(data);
    fetch(URL_CB, {
            body: JSON.stringify(data),
            headers: { "Content-Type": "application/json" },
            method: "PATCH"
        })
        .then(res => {
            console.log("Reply from Orion", res.ok)
            if (res.ok) {
                io.to(data.socketId.value).emit("messages", { type: "CONFIRMATION", payload: { msg: "Your request is being processed" } });
                return;
            }
            throw new Error("Error")
        })
        .catch(e => {
            io.to(data.socketId.value).emit("messages", { type: "ERROR", payload: { msg: "There has been a problem with your request" } });
            console.error(e);
        });
}

server.listen(PORT, function() {
    console.log("Listening on port " + PORT);
});


io.on('connection', function(socket) {
    console.log('New socket connection');
    socket.on('predict', (msg) => {
        const { name, year, month, day, weekday, time, predictionId } = msg;
        updateEntity({
            "name": createAttr(name),
            "year": createAttr(year),
            "month": createAttr(month),
            "day": createAttr(day),
            "weekday": createAttr(weekday),
            "time": createAttr(time),
            "predictionId": createAttr(predictionId),
            "socketId": createAttr(socket.id)
        });
    })
});

app.use(express.static(__dirname + "/public/"));
app.use(bodyParser.text());
app.use(bodyParser.json());

app.post("/notify", function(req, res) {
    if (req.body && req.body.data) {
        req.body.data.map(({ socketId, predictionId, predictionValue, name, weekday, time }) => {
            io.to(socketId.value).emit('messages', {
                type: "PREDICTION",
                payload: {
                    socketId: socketId.value,
                    name: name.value,
                    weekday: weekday.value,
                    time: time.value,
                    predictionId: predictionId.value,
                    predictionValue: predictionValue.value
                }
            });
        });
    }
    res.sendStatus(200);
});

const fromEntries = arr => Object.assign({}, ...Array.from(arr, ([k, v]) => ({
    [k]: v
})));

const Pred = mongoose.model('Pred', mongoose.Schema({
    _id: String,
    recvTime: String,
    entityId: String,
    entityType: String,
    attrName: String,
    attrType: String,
    attrValue: String,
    attrMetadata: Array
}, { collection: 'sth_x002f' }));

app.get("/predictions", async(req, res) => {
    const posts = await Pred.find()
    var obj = posts.reverse().reduce((acc, el, i) => {
        return {...acc, [el.recvTime]: [...(acc[el.recvTime] || []), [el.attrName, el.attrValue]] }
    }, {})
    for (let i in obj) {
        obj[i] = fromEntries(obj[i]);
    }
    console.log(obj)
    res.json(obj);
})

// find("sth_x002f", {}, (err, predictions) => {
//     if (err) {
//         console.log("Error fetching collection")
//         res.sendStatus(500);
//     } else {
//         console.log(predictions)
//         var obj = predictions.reverse().reduce((acc, el, i) => {return {...acc, [el.recvTime]: [...(acc[el.recvTime] || []), [el.attrValue]] }}, {})

//         for (let i in obj) {
//             obj[i] = fromEntries(obj[i]);
//         }
//         res.json(obj);
//     }

// });
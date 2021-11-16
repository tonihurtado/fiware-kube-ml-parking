# syntax=docker/dockerfile:1

FROM node:12.18.1
ENV NODE_ENV=production
ENV MONGO_URI=mongodb://mongodb-svc:27017/web
ENV URL_CB=http://orion:1026/v2/entities/ReqTicketPrediction1/attrs
WORKDIR /app
COPY ["package.json", "package-lock.json*", "./"]
RUN npm install --production
COPY . .
CMD [ "node", "app.js" ]

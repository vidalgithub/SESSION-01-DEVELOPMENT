FROM node:13.0

ADD package.json /app/

WORKDIR /app

RUN npm install

ADD hello.js /app/

CMD npm start

EXPOSE 3000

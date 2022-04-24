FROM ubuntu:5.12

ADD package.json /app/

WORKDIR /app

RUN npm install

ADD hello.js /app/

CMD npm start

EXPOSE 3000

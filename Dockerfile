FROM node:16

WORKDIR /usr/src/app

# Install dependencies before copying all files to rely on Docker cache if we update the app
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8080

CMD [ "node", "index.js" ]
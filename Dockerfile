FROM ubuntu:20.04

RUN apt-get update
# install curl 
RUN apt-get install -y curl
# get install script and pass it to execute: 
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash
# and install node 
RUN apt-get install -y nodejs
# confirm that it was successful 
RUN node -v
# npm installs automatically 
RUN npm -v

WORKDIR /usr/src/app

# Install dependencies before copying all files to rely on Docker cache if we update the app
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8080

CMD [ "node", "index.js" ]
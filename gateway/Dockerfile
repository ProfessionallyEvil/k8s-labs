FROM node:alpine as gateway
COPY . /gateway
WORKDIR /gateway
RUN yarn install
RUN npm install -g express-gateway
RUN eg users create -p "admin=true" -p "username=nevil" -p "firstname=nevil" -p "lastname=devil"
RUN eg credentials create -c nevil -t oauth2
EXPOSE 3000
CMD ["yarn", "start", "--verbose"]

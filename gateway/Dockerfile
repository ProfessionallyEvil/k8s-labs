FROM node:alpine as gateway
COPY . /gateway
WORKDIR /gateway
RUN yarn install
EXPOSE 3000
CMD ["yarn", "start", "--verbose"]

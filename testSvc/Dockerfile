FROM node:alpine as testSvc
COPY . /testSvc
WORKDIR /testSvc
RUN yarn install
EXPOSE 3000
CMD ["yarn", "start"]

FROM node:alpine as authSvc
COPY . /authSvc
WORKDIR /authSvc
RUN yarn install
EXPOSE 3000
CMD ["yarn", "start"]

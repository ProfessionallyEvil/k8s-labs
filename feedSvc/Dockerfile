FROM node:alpine as feedSvc
COPY . /feedSvc
WORKDIR /feedSvc
RUN yarn install
EXPOSE 3000
CMD ["yarn", "start"]

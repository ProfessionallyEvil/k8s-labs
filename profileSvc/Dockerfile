FROM node:alpine as profileSvc
COPY . /profileSvc
WORKDIR /profileSvc
RUN yarn install
EXPOSE 3000
CMD ["yarn", "start"]

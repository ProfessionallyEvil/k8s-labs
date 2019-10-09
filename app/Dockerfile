FROM node:latest

WORKDIR /src/
COPY ./ /src/
RUN npm install
RUN npm run export

FROM httpd:alpine
COPY --from=0 /src/__sapper__/export /usr/local/apache2/htdocs
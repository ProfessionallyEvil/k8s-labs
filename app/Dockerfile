FROM node:latest

WORKDIR /src/
COPY ./ /src/
ENV APIURL api.arrrspace.wtf
RUN npm install
RUN npm run export

FROM httpd:alpine
COPY --from=0 /src/__sapper__/export /usr/local/apache2/htdocs
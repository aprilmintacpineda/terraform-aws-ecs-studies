FROM node:18-alpine3.17

WORKDIR /app
COPY ./dist/ /app/
RUN yarn global add serve

EXPOSE 4000
CMD serve -p 4000 -s
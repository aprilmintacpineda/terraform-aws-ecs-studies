FROM alpine:latest
RUN apk add --no-cache nodejs yarn npm

WORKDIR /app
COPY apps/server/build/. /app
COPY apps/server/package.json /app
COPY yarn.lock /app
RUN yarn --prefer-offline

EXPOSE 3030
CMD ["node", "server.js"]
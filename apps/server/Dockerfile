FROM alpine:latest
RUN apk add --no-cache nodejs yarn npm

WORKDIR /app
COPY build/. /app
RUN yarn --prefer-offline

EXPOSE 3000
CMD ["node", "server.js"]
FROM node:8.15.1-jessie-slim
LABEL maintainer="Markus Kosmal - m-ko.de"

RUN apt-get update && \
    apt-get install -y -qq libxkbfile-dev libsecret-1-dev

# Ensure latest yarn.
RUN npm install -g yarn

# In the future, we can use https://github.com/yarnpkg/rfcs/pull/53 to make it use the node_modules
# directly which should be faster.
WORKDIR /src
COPY . .
RUN yarn
RUN yarn task build:server:binary

# We deploy with ubuntu so that devs have a familiar environemnt.
FROM ubuntu-debootstrap:18.10
RUN apt-get update -y -qq && \
    apt-get install -y -qq openssl net-tools
WORKDIR /root/project
COPY --from=0 /src/packages/server/cli-linux /usr/local/bin/code-server
EXPOSE 8443
# Unfortunately `.` does not work with code-server.
CMD code-server $PWD
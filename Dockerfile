from node:4.2.5

RUN npm install -g coffee-script
COPY . /src
RUN cd /src; npm install

EXPOSE 8000

ENTRYPOINT ["coffee", "/src/index.coffee"]

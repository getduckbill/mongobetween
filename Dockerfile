FROM golang:1.23 as build
WORKDIR /go/src
COPY . .
RUN CGO_ENABLED=0 make


FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /go/src/bin/mongobetween /mongobetween
ENTRYPOINT ["/mongobetween"]

ENV MONGODB_MAX_IDLE_TIME_MS=600000
ENV MONGODB_SOCKET_TIMEOUT_MS=20000
ENV MONGODB_CONNECT_TIMEOUT_MS=3000
ENV MONGODB_TIMEOUT_MS=10000
ENV MONGODB_MIN_POOL_SIZE=1
ENV MONGODB_MAX_POOL_SIZE=10

CMD ["--username=$MONGODB_USERNAME", \
    "--password=$MONGODB_PASSWORD", \
    "--ping", \
    ":27017=mongodb+srv://$MONGODB_HOST/\
        ?timeoutMS=$MONGODB_TIMEOUT_MS\
        &connectTimeoutMS=$MONGODB_CONNECT_TIMEOUT_MS\
        &socketTimeoutMS=$MONGODB_SOCKET_TIMEOUT_MS\
        &maxIdleTimeMS=$MONGODB_MAX_IDLE_TIME_MS\
        &minPoolSize=$MONGODB_MIN_POOL_SIZE\
        &maxPoolSize=$MONGODB_MAX_POOL_SIZE\
        &w=majority\
"]

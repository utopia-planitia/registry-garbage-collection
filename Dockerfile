FROM golang:1.17.6-alpine@sha256:519c827ec22e5cf7417c9ff063ec840a446cdd30681700a16cf42eb43823e27c AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.23.1@sha256:5546111938df8c8deefa653e9f7b6ce2d0624d97a1e2b87440ea27abd3469937 AS kubectl

FROM alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
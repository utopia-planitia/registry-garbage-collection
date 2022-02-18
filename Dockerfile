FROM golang:1.17.7-alpine@sha256:d030a987c28ca403007a69af28ba419fca00fc15f08e7801fc8edee77c00b8ee AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.23.2@sha256:e4d83478963b5e47425b986327eea841b3be6c06483324c880b31bd69d9a10f0 AS kubectl

FROM alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
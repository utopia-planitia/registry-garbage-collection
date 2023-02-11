FROM golang:1.20.0-alpine@sha256:8a0bdfe08747034d417c35f5a0cf7ffb37ee63ad3f14585524066b1129cc4c15 AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.25.4@sha256:af5cea3f2e40138df90660c0c073d8b1506fb76c8602a9f48aceb5f4fb052ddc AS kubectl

FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
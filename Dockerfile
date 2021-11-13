FROM golang:1.17.3-alpine@sha256:41ca88189004aa8c949735b1ba522d6c66c244a4c50ead7f83f8e3c1e6165f0b AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.22.3@sha256:5fab67a6cad3f539838ce58f1a5c6bc4e4b00c433b04ebbad483cc8c719e4afd AS kubectl

FROM alpine:3.14.3@sha256:635f0aa53d99017b38d1a0aa5b2082f7812b03e3cdb299103fe77b5c8a07f1d2
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
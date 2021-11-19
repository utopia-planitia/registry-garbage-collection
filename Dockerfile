FROM golang:1.17.3-alpine@sha256:55da409cc0fe11df63a7d6962fbefd1321fedc305d9969da636876893e289e2d AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.22.4@sha256:4bce6b35f58ff6c645099f92368d4358658625cbbb98e50bf0fa52d5f6eb671e AS kubectl

FROM alpine:3.14.3@sha256:635f0aa53d99017b38d1a0aa5b2082f7812b03e3cdb299103fe77b5c8a07f1d2
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
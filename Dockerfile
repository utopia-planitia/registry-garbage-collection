FROM golang:1.17.4-alpine@sha256:d8bd35607c405fcef71d749aa367f86954706c3a57a602fb0bcaae3581043f8f AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.22.4@sha256:4bce6b35f58ff6c645099f92368d4358658625cbbb98e50bf0fa52d5f6eb671e AS kubectl

FROM alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
FROM golang:1.17.4-alpine@sha256:d8bd35607c405fcef71d749aa367f86954706c3a57a602fb0bcaae3581043f8f AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.23.0@sha256:0662bca6b9f4d24cee983761e709d911dfa6c78a7d922ad73fff5a429ddefca2 AS kubectl

FROM alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
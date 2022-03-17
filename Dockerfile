FROM golang:1.18.0-alpine@sha256:9efe6b075e2bd5eff0fae9ce2961897ac339ef31eec24732691e15be0a154eec AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.23.4@sha256:f4902e22224b599bddafb51bf771c9bc4cda84e9767e2edca88170ce0a7ce385 AS kubectl

FROM alpine:3.15.1@sha256:d6d0a0eb4d40ef96f2310ead734848b9c819bb97c9d846385c4aca1767186cd4
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
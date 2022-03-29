FROM golang:1.18.0-alpine@sha256:65654d6dc635238af4793bac7b8cc5e04f95c8a935a026b3322daa60733b3e19 AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.23.4@sha256:f4902e22224b599bddafb51bf771c9bc4cda84e9767e2edca88170ce0a7ce385 AS kubectl

FROM alpine:3.15.3@sha256:f22945d45ee2eb4dd463ed5a431d9f04fcd80ca768bb1acf898d91ce51f7bf04
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
FROM golang:1.18.0-alpine@sha256:9ccb0ed869157f3b1630f5dda3422b5974defa9dd82c7375ca68dc3a9cbf8fae AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.23.4@sha256:f4902e22224b599bddafb51bf771c9bc4cda84e9767e2edca88170ce0a7ce385 AS kubectl

FROM alpine:3.15.2@sha256:66b861b1099af1551a0eee163c175fd008744192c3fbb7f22e998db0ce09e8ea
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
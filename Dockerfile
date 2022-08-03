FROM golang:1.19.0-alpine@sha256:f734a85923ff49da7caf82940b422bf679ca9bdec38cc56f501a4745b557d150 AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.24.3@sha256:7b0568820851c1a1072379add4954aa25c9bf616d39f1f72887a6e7bb64df254 AS kubectl

FROM alpine:3.16.1@sha256:7580ece7963bfa863801466c0a488f11c86f85d9988051a9f9c68cb27f6b7872
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
FROM golang:1.17.3-alpine@sha256:102bca942e79a30dd6e9060f780ec3bd224eba2cf6245eadf3411c4699253d50 AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.22.3@sha256:5fab67a6cad3f539838ce58f1a5c6bc4e4b00c433b04ebbad483cc8c719e4afd AS kubectl

FROM alpine:3.14.3@sha256:230cdd0ecad7d678b69b033748ac07183a26115ab1050a5d464105eafbe57859
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
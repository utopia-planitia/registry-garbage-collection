FROM golang:1.19.3-alpine@sha256:8558ae624304387d18694b9ea065cc9813dd4f7f9bd5073edb237541f2d0561b AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.25.0@sha256:bfd61d0f2f9782841fe3e7c97ba90462d224fd0d71418585aa92865a27fa279f AS kubectl

FROM alpine:3.16.2@sha256:65a2763f593ae85fab3b5406dc9e80f744ec5b449f269b699b5efd37a07ad32e
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
FROM golang:1.19.2-alpine@sha256:2baa528036c1916b23de8b304083c68fb298c5661203055f2b1063390e3cdddb AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.25.0@sha256:bfd61d0f2f9782841fe3e7c97ba90462d224fd0d71418585aa92865a27fa279f AS kubectl

FROM alpine:3.16.2@sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
FROM golang:1.19.3-alpine@sha256:d171aa333fb386089206252503bc6ab545072670e0286e3d1bbc644362825c6e AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.25.0@sha256:bfd61d0f2f9782841fe3e7c97ba90462d224fd0d71418585aa92865a27fa279f AS kubectl

FROM alpine:3.16.3@sha256:b95359c2505145f16c6aa384f9cc74eeff78eb36d308ca4fd902eeeb0a0b161b
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
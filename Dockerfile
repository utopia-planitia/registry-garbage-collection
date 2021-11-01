FROM golang:1.10.1-alpine3.7 AS deckschrubber
RUN mkdir -p src/github.com/fraunhoferfokus/deckschrubber
WORKDIR src/github.com/fraunhoferfokus/deckschrubber
RUN apk --update add git
RUN git clone https://github.com/fraunhoferfokus/deckschrubber.git .
RUN git checkout -b tag v0.6.0
RUN go get .
RUN go install .

FROM lachlanevenson/k8s-kubectl:v1.22.2@sha256:33329c939c44a6cebe58c510aa644fb501c14992d71af6670aa3beb22200d3ec AS kubectl

FROM alpine:3.14.2@sha256:e1c082e3d3c45cccac829840a25941e679c25d438cc8412c2fa221cf1a824e6a
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
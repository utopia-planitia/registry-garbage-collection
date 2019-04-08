FROM golang:1.10.1-alpine3.7 AS deckschrubber
RUN mkdir -p src/github.com/fraunhoferfokus/deckschrubber
WORKDIR src/github.com/fraunhoferfokus/deckschrubber
RUN apk --update add git
RUN git clone https://github.com/fraunhoferfokus/deckschrubber.git .
RUN git checkout -b tag v0.6.0
RUN go get .
RUN go install .

FROM lachlanevenson/k8s-kubectl:v1.13.5 AS kubectl

FROM alpine:3.9.2
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
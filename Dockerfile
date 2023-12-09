FROM golang:1.21.5-alpine@sha256:feceecc0e1d73d085040a8844de11a2858ba4a0c58c16a672f1736daecc2a4ff AS deckschrubber
RUN apk --update add git
RUN go install github.com/fraunhoferfokus/deckschrubber@v0.7.0

FROM lachlanevenson/k8s-kubectl:v1.25.4@sha256:af5cea3f2e40138df90660c0c073d8b1506fb76c8602a9f48aceb5f4fb052ddc AS kubectl

FROM alpine:3.19.0@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48
COPY --from=deckschrubber /go/bin/deckschrubber  /bin
COPY --from=kubectl       /usr/local/bin/kubectl /bin
RUN apk --update --no-cache add curl
ENTRYPOINT ["deckschrubber"]
CMD ["--help"]
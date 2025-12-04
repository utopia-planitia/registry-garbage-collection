FROM docker.io/library/golang:1.25.5-alpine@sha256:3587db7cc96576822c606d119729370dbf581931c5f43ac6d3fa03ab4ed85a10 AS deckschrubber

# renovate: datasource=github-tags depName=kubernetes/kubernetes
ENV KUBECTL_VERSION=v1.29.2
# renovate: datasource=github-tags depName=fraunhoferfokus/deckschrubber
ENV DECKSCHRUBBER_VERSION=v0.7.0

ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH:?}

RUN set -eux; \
    apk upgrade --no-cache; \
    # install deckschrubber
    CGO_ENABLED=0 GOOS=linux go install "github.com/fraunhoferfokus/deckschrubber@${DECKSCHRUBBER_VERSION:?}"; \
    /go/bin/deckschrubber -v | tee -a /dev/stderr | grep -Fq "${DECKSCHRUBBER_VERSION#v}"; \
    # install kubectl
    wget -qO /bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION:?}/bin/linux/${TARGETARCH:?}/kubectl"; \
    chmod +x /bin/kubectl; \
    /bin/kubectl version --client | tee -a /dev/stderr | grep -Fq "${KUBECTL_VERSION:?}"


FROM docker.io/library/alpine:3.23.0@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375

COPY --from=deckschrubber /bin/kubectl /go/bin/deckschrubber /bin

RUN set -eux; \
    apk upgrade --no-cache; \
    apk add --no-cache curl; \
    addgroup -g 10001 deckschrubber; \
    adduser -D -g deckschrubber -G deckschrubber -H -s /sbin/nologin -u 10001 deckschrubber

USER 10001:10001
ENTRYPOINT ["/bin/deckschrubber"]
CMD ["--help"]

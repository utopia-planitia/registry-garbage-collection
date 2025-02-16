FROM docker.io/library/golang:1.24.0-alpine@sha256:2d40d4fc278dad38be0777d5e2a88a2c6dee51b0b29c97a764fc6c6a11ca893c AS deckschrubber

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


FROM docker.io/library/alpine:3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c

COPY --from=deckschrubber /bin/kubectl /go/bin/deckschrubber /bin

RUN set -eux; \
    apk upgrade --no-cache; \
    apk add --no-cache curl; \
    addgroup -g 10001 deckschrubber; \
    adduser -D -g deckschrubber -G deckschrubber -H -s /sbin/nologin -u 10001 deckschrubber

USER 10001:10001
ENTRYPOINT ["/bin/deckschrubber"]
CMD ["--help"]

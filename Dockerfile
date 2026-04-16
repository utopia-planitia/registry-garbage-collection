FROM docker.io/library/golang:1.26.2-alpine@sha256:f85330846cde1e57ca9ec309382da3b8e6ae3ab943d2739500e08c86393a21b1 AS deckschrubber

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


FROM docker.io/library/alpine:3.23.4@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

COPY --from=deckschrubber /bin/kubectl /go/bin/deckschrubber /bin

RUN set -eux; \
    apk upgrade --no-cache; \
    apk add --no-cache curl; \
    addgroup -g 10001 deckschrubber; \
    adduser -D -g deckschrubber -G deckschrubber -H -s /sbin/nologin -u 10001 deckschrubber

USER 10001:10001
ENTRYPOINT ["/bin/deckschrubber"]
CMD ["--help"]

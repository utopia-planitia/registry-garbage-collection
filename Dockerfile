FROM docker.io/library/golang:1.23.3-alpine@sha256:09742590377387b931261cbeb72ce56da1b0d750a27379f7385245b2b058b63a AS deckschrubber

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


FROM docker.io/library/alpine:3.20.3@sha256:beefdbd8a1da6d2915566fde36db9db0b524eb737fc57cd1367effd16dc0d06d

COPY --from=deckschrubber /bin/kubectl /go/bin/deckschrubber /bin

RUN set -eux; \
    apk upgrade --no-cache; \
    apk add --no-cache curl; \
    addgroup -g 10001 deckschrubber; \
    adduser -D -g deckschrubber -G deckschrubber -H -s /sbin/nologin -u 10001 deckschrubber

USER 10001:10001
ENTRYPOINT ["/bin/deckschrubber"]
CMD ["--help"]

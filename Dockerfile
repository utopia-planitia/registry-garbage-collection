FROM docker.io/library/golang:1.23.4-alpine@sha256:6c5c9590f169f77c8046e45c611d3b28fe477789acd8d3762d23d4744de69812 AS deckschrubber

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


FROM docker.io/library/alpine:3.21.1@sha256:b97e2a89d0b9e4011bb88c02ddf01c544b8c781acf1f4d559e7c8f12f1047ac3

COPY --from=deckschrubber /bin/kubectl /go/bin/deckschrubber /bin

RUN set -eux; \
    apk upgrade --no-cache; \
    apk add --no-cache curl; \
    addgroup -g 10001 deckschrubber; \
    adduser -D -g deckschrubber -G deckschrubber -H -s /sbin/nologin -u 10001 deckschrubber

USER 10001:10001
ENTRYPOINT ["/bin/deckschrubber"]
CMD ["--help"]

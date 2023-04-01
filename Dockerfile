FROM python:3.11-alpine

RUN apk add --update --no-cache bash curl jq sudo && \
    pip install --no-cache-dir github-backup && \
    mkdir -p /data

WORKDIR /data
ENV GITHUB_USERNAME=pschmitt GITHUB_TOKEN= INTERVAL=1d DATA_DIR=/data
VOLUME /data

COPY run.sh entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

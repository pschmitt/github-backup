FROM python:3.14-alpine

RUN apk add --update --no-cache bash curl git git-lfs openssh-client jq && \
    pip install --no-cache-dir github-backup && \
    mkdir -p /data

WORKDIR /data
ENV GITHUB_USERNAME=pschmitt GITHUB_TOKEN= GITHUB_BACKUP_ARGS= \
    INTERVAL=1d DATA_DIR=/data HEALTHCHECK_URL=
VOLUME /data

COPY run.sh entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

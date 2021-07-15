FROM node
RUN \
  mkdir /app && \
  git clone https://github.com/dfletcher/jellyfin-web.git && \
  cd jellyfin-web && \
  npm i && \
  bash build.sh --type native --platform portable

FROM jellyfin/jellyfin
COPY --from=0 /bin/portable/jellyfin-web*.tar.gz /tmp/portable.tgz
RUN \
  cd /jellyfin/jellyfin-web && \
  tar xzf /tmp/portable.tgz --strip-components=1

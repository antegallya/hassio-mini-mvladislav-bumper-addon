# We use sha-74f121c instead of latest for the moment because it's the first release where there's a build for arm64.
# We'll change it to :latest when the stable release catches on.
FROM ghcr.io/mvladislav/bumper:sha-74f121c

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
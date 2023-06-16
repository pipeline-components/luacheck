FROM alpine:3.17.4 as build

WORKDIR /app/

# Lua
# hadolint ignore=DL3018
RUN apk add --no-cache --virtual .build-deps \
	gcc \
	musl-dev \
	curl \
	lua5.3-dev \
	git \
	luarocks5.3 && \
    luarocks-5.3 install --tree /app luacheck 0.23.0-1

FROM pipelinecomponents/base-entrypoint:0.5.0 as entrypoint

FROM alpine:3.17
COPY --from=entrypoint /entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
ENV DEFAULTCMD luacheck

# hadolint ignore=DL3018
RUN apk add --no-cache lua5.3

COPY --from=build /app/ /app/

ENV PATH "$PATH:/app/bin/"

# Lua paths to check /app
ENV LUA_PATH='/app/share/lua/5.3/?.lua;/app/share/lua/5.3/?/init.lua;/root/.luarocks/share/lua/5.3/?.lua;/root/.luarocks/share/lua/5.3/?/init.lua;/usr/share/lua/5.3/?.lua;/usr/share/lua/5.3/?/init.lua;/usr/share/lua/common/?.lua;/usr/share/lua/common/?/init.lua;/usr/local/share/lua/5.3/?.lua;/usr/local/share/lua/5.3/?/init.lua;/usr/local/lib/lua/5.3/?.lua;/usr/local/lib/lua/5.3/?/init.lua;/usr/lib/lua/5.3/?.lua;/usr/lib/lua/5.3/?/init.lua;./?.lua;./?/init.lua'
ENV LUA_CPATH='/app/lib/lua/5.3/?.so;/root/.luarocks/lib/lua/5.3/?.so;/usr/lib/lua/5.3/?.so;/usr/local/lib/lua/5.3/?.so;/usr/local/lib/lua/5.3/loadall.so;/usr/lib/lua/5.3/loadall.so;./?.so'


WORKDIR /code/

# Build arguments
ARG BUILD_DATE
ARG BUILD_REF

# Labels
LABEL \
    maintainer="Robbert Müller <dev@pipeline-components.dev>" \
    org.label-schema.description="Luacheck in a container for gitlab-ci" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Luacheck" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://pipeline-components.gitlab.io/" \
    org.label-schema.usage="https://gitlab.com/pipeline-components/luacheck/blob/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://gitlab.com/pipeline-components/luacheck/" \
    org.label-schema.vendor="Pipeline Components"

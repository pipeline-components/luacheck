FROM alpine:3.11 as build

WORKDIR /app/

# Lua
RUN apk add --no-cache --virtual .build-deps \
	gcc=9.2.0-r3 \
	musl-dev=1.1.24-r0 \
	curl=7.67.0-r0 \
	lua5.3-dev=5.3.5-r2 \
	git=2.24.1-r0 \
	luarocks5.3=2.4.4-r1

RUN luarocks-5.3 install --tree /app luacheck 0.23.0-1

FROM pipelinecomponents/base-entrypoint:0.2.0 as entrypoint

FROM alpine:3.11
COPY --from=entrypoint /entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
ENV DEFAULTCMD luacheck


RUN apk add --no-cache lua5.3=5.3.5-r2

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
    maintainer="Robbert Müller <spam.me@grols.ch>" \
    org.label-schema.description="_Template_ in a container for gitlab-ci" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="_Template_" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://pipeline-components.gitlab.io/" \
    org.label-schema.usage="https://gitlab.com/pipeline-components/_template_/blob/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://gitlab.com/pipeline-components/_template_/" \
    org.label-schema.vendor="Pipeline Components"

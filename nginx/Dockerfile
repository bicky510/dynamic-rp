FROM openresty/openresty:1.21.4.1-3-bullseye-fat
#COPY ./nginx.conf /etc/nginx/nginx.conf

ARG RESTY_LUAROCKS_VERSION="3.9.0"
ARG PUID=300
ARG PGID=300

# install LuaRocks
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        make \
        unzip \
        wget \
    && cd /tmp \
    && curl -fSL https://luarocks.github.io/luarocks/releases/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz -o luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${RESTY_LUAROCKS_VERSION} \
    && ./configure \
        --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit \
        --lua-suffix=jit-2.1.0-beta3 \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
    && make build \
    && make install \
    && cd /tmp \
    && rm -rf luarocks-${RESTY_LUAROCKS_VERSION} luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz

# Add LuaRocks paths
# If OpenResty changes, these may need updating:
#    /usr/local/openresty/bin/resty -e 'print(package.path)'
#    /usr/local/openresty/bin/resty -e 'print(package.cpath)'
ENV LUA_PATH="/usr/local/openresty/site/lualib/?.ljbc;/usr/local/openresty/site/lualib/?/init.ljbc;/usr/local/openresty/lualib/?.ljbc;/usr/local/openresty/lualib/?/init.ljbc;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;./?.lua;/usr/local/openresty/luajit/share/luajit-2.1.0-beta3/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?/init.lua"

ENV LUA_CPATH="/usr/local/openresty/site/lualib/?.so;/usr/local/openresty/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so"

# install a rock
RUN /usr/local/openresty/luajit/bin/luarocks install ljsyscall \
	&& /usr/local/openresty/luajit/bin/luarocks install lua-resty-ipmatcher

# create webservd user
RUN groupadd -g ${PGID} webservd \
    && useradd -u ${PUID} -g webservd -d /home/webservd -m webservd \
    && mkdir -p /home/webservd/WebContent/ROOT

COPY entrypoint.sh /
COPY ./lua /usr/local/openresty/nginx/lua

# Compile script
RUN cd /usr/local/openresty/nginx/lua/ \
    && ls *.lua | sed -e s/\.lua// | xargs -I{} luajit -b {}.lua {}.luac

EXPOSE 8080 8081
#CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
ENTRYPOINT ["sh", "/entrypoint.sh"]

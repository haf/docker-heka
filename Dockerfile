FROM golang:1.4

ENV BUILD_DEPS \
        cmake python-sphinx protobuf-compiler \
        patch libgeoip-dev debhelper fakeroot

ENV HEKA_VERSION 1d9379aa0ee33cc9df4df5eb6fea119167702041

# COPY plugin_loader.cmake /tmp/plugin_loader.cmake
# && mv /tmp/plugin_loader.cmake /usr/src/heka/cmake \

RUN apt-get update \
    && apt-get install -y libgeoip1 $BUILD_DEPS --no-install-recommends \
    && git clone https://github.com/haf/heka /usr/src/heka \
    && cd /usr/src/heka/ && git checkout $HEKA_VERSION \
    && cd /usr/src/heka/ && ./build.sh 2>&1 \
    && mv /usr/src/heka/build/heka/bin/* /usr/local/bin \
    && mv /usr/src/heka/build/heka/include/* /usr/local/include \
    && mv /usr/src/heka/build/heka/lib/* /usr/local/lib \
    && mkdir -p /usr/share/heka/lua_decoders \
    && mkdir -p /usr/share/heka/lua_encoders \
    && mkdir -p /usr/share/heka/lua_filters \
    && mkdir -p /usr/share/heka/lua_modules \
    && mkdir -p /usr/share/heka/dasher \
    && cp /usr/src/heka/sandbox/lua/decoders/* /usr/share/heka/lua_decoders \
    && cp /usr/src/heka/sandbox/lua/encoders/* /usr/share/heka/lua_encoders \
    && cp /usr/src/heka/sandbox/lua/filters/* /usr/share/heka/lua_filters \
    && cp /usr/src/heka/sandbox/lua/modules/* /usr/share/heka/lua_modules \
    && cp /usr/local/lib/luasandbox/modules/* /usr/share/heka/lua_modules \
    && cp -r /usr/src/heka/dasher/* /usr/share/heka/dasher \
    && (rm -rf /usr/src/heka || true) \
    && apt-get purge -y $BUILD_DEPS && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY dashboard.toml /etc/hekad/

EXPOSE 4352

CMD ["hekad", "--config", "/etc/hekad"]

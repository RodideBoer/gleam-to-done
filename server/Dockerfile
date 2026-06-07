ARG ERLANG_VERSION=29.0.1.0
ARG GLEAM_VERSION=v1.17.0

FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-scratch AS gleam

FROM erlang:${ERLANG_VERSION}-alpine AS build
COPY --from=gleam /bin/gleam /bin/gleam
WORKDIR /to-done/server
COPY shared/gleam.toml /to-done/shared/gleam.toml
COPY server/gleam.toml server/manifest.toml ./
RUN gleam deps download
COPY shared/ /to-done/shared/
COPY server/ ./
RUN gleam export erlang-shipment

FROM erlang:${ERLANG_VERSION}-alpine
COPY --from=build /to-done/server/build/erlang-shipment /to-done-server
WORKDIR /to-done-server
ENTRYPOINT ["/to-done-server/entrypoint.sh"]
CMD ["run"]
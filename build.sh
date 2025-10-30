#!/usr/bin/env bash
set -euo pipefail

cargo clean -p libz-sys

TARGET=x86_64-unknown-linux-gnu
export CC=clang-17
export CC_${TARGET//-/_}=clang-17
export AR=llvm-ar-17
export AR_${TARGET//-/_}=llvm-ar-17
export RANLIB=llvm-ranlib-17
export RANLIB_${TARGET//-/_}=llvm-ranlib-17

export CFLAGS="-O3 -g -flto"
export CFLAGS_${TARGET//-/_}="$CFLAGS"

export LIBZ_SYS_STATIC=1

export RUSTFLAGS="\
  -C debuginfo=2 \
  -C linker-plugin-lto \
  -C opt-level=3 \
  -C codegen-units=1 \
  -C linker=clang-17 \
  -C link-arg=-fuse-ld=lld \
  -C link-arg=-Wl,--lto-O3 \
  -C link-arg=-Wl,--time-trace
"

cargo clean
cargo build -vv --release |& tee build.log

jq '.traceEvents[] | select(.name|test("(?i)LTO|ThinLTO|import|summary|opt")) | {name, dur:.dur, args:.args}'   target/release/deps/zdriver-*.time-trace

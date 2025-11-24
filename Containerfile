FROM ghcr.io/projectbluefin/distroless:test

RUN bootc container lint || true

FROM ghcr.io/projectbluefin/egg:latest@sha256:2cbb2c9e373a9bcda0fcf190d0496565fa702a5bede612262f33fef6f06cf005

RUN bootc container lint || true

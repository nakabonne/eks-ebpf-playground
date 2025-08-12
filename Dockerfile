FROM golang:1.24 AS builder

# Install build dependencies including kernel headers
RUN apt-get update && apt-get install -y \
    clang \
    llvm \
    make \
    libbpf-dev \
    libelf-dev \
    linux-headers-amd64 \
    linux-libc-dev \
    pkg-config \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks for architecture-specific headers that may be missing
RUN mkdir -p /usr/include/asm-x86_64 && \
    ln -sf /usr/include/asm-generic /usr/include/asm && \
    ln -sf /usr/include/asm-generic/types.h /usr/include/asm/types.h || true

WORKDIR /app

COPY . .

# Build the eBPF program and Go application
RUN make build

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y libbpf0 libelf1 ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/cmd/main /main
COPY --from=builder /app/hello.bpf.o /hello.bpf.o

CMD ["/main"]

BPF_CLANG=clang
BPF_CFLAGS=-O2 -g -Wall -target bpf -D__TARGET_ARCH_x86 -I/usr/include

build:
	$(BPF_CLANG) $(BPF_CFLAGS) -c bpf/hello.bpf.c -o hello.bpf.o
	go build -o cmd/main ./cmd

build-push-image:
	docker buildx build --platform=linux/amd64 --load -t ebpf-sample .
	docker tag ebpf-sample:latest ghcr.io/${GH_USER}/ebpf-sample:latest
	docker push ghcr.io/${GH_USER}/ebpf-sample:latest

apply-k8s:
	aws eks update-kubeconfig --region ap-northeast-1 --name eks-ebpf-playground
	kubectl apply -f infra/k8s/deploy.yaml

apply:
	cd infra/terraform && terraform apply && cd - && make apply-k8s

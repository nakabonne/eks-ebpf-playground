package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/cilium/ebpf"
	"github.com/cilium/ebpf/link"
	"github.com/cilium/ebpf/rlimit"
)

func main() {
	// Remove memory limit for eBPF (important in containers)
	if err := rlimit.RemoveMemlock(); err != nil {
		log.Printf("Warning: failed to remove memory limit: %v", err)
	}

	// Load the eBPF object file
	spec, err := ebpf.LoadCollectionSpec("hello.bpf.o")
	if err != nil {
		log.Fatalf("failed to load spec: %v", err)
	}

	coll, err := ebpf.NewCollection(spec)
	if err != nil {
		log.Fatalf("failed to load collection: %v", err)
	}
	defer coll.Close()

	prog := coll.Programs["bpf_prog"]
	if prog == nil {
		log.Fatalf("program not found")
	}

	// Try to attach kprobe
	k, err := link.Kprobe("sys_execve", prog, nil)
	if err != nil {
		log.Fatalf("failed to attach kprobe: %v", err)
	}
	defer k.Close()

	log.Println("eBPF program attached successfully. Monitoring syscalls...")
	fmt.Println("Check /sys/kernel/debug/tracing/trace_pipe for output")

	// Wait for interrupt signal
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	<-c

	log.Println("Shutting down...")
}

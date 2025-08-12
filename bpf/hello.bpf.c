#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

SEC("kprobe/sys_execve")
int bpf_prog(void *ctx) {
    bpf_printk("Hello from eBPF!\n");
    return 0;
}

char LICENSE[] SEC("license") = "GPL";

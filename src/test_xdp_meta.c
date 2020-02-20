#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <linux/pkt_cls.h>
#include <linux/ip.h>
#include <linux/icmp.h>

#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

#define __round_mask(x, y) ((__typeof__(x))((y) - 1))
#define round_up(x, y) ((((x) - 1) | __round_mask(x, y)) + 1)
#define ctx_ptr(ctx, mem) (void *)(unsigned long)ctx->mem

__attribute__((__always_inline__))
static inline void swap_src_dst_mac(void *data)
{
	unsigned short *p = data;
	unsigned short dst[3];

	dst[0] = p[0];
	dst[1] = p[1];
	dst[2] = p[2];
	p[0] = p[3];
	p[1] = p[4];
	p[2] = p[5];
	p[3] = dst[0];
	p[4] = dst[1];
	p[5] = dst[2];
}

__attribute__((__always_inline__))
static inline void swap_src_dst_ip(struct iphdr *iph)
{
	__u32 addr;
	addr = iph->daddr;
	iph->daddr = iph->saddr;
	iph->saddr = addr;
}

__attribute__((__always_inline__))
static inline __u16 csum_fold_helper(__wsum sum)
{
	sum = (sum & 0xffff) + (sum >> 16);
	return ~((sum & 0xffff) + (sum >> 16));
}

SEC("t")
int ing_cls(struct __sk_buff *ctx)
{
	__u8 *data, *data_meta, *data_end;
	__u32 diff = 0;

	data_meta = ctx_ptr(ctx, data_meta);
	data_end  = ctx_ptr(ctx, data_end);
	data      = ctx_ptr(ctx, data);

	if (data + ETH_ALEN > data_end ||
	    data_meta + round_up(ETH_ALEN, 4) > data)
		return TC_ACT_SHOT;

	diff |= ((__u32 *)data_meta)[0] ^ ((__u32 *)data)[0];
	diff |= ((__u16 *)data_meta)[2] ^ ((__u16 *)data)[2];

	return diff ? TC_ACT_SHOT : TC_ACT_OK;
}

SEC("pass")
int ing_xdp_pass(struct xdp_md *ctx)
{
	__u8 *data, *data_meta, *data_end;
	int ret;

	ret = bpf_xdp_adjust_meta(ctx, -round_up(ETH_ALEN, 4));
	if (ret < 0)
		return XDP_DROP;

	data_meta = ctx_ptr(ctx, data_meta);
	data_end  = ctx_ptr(ctx, data_end);
	data      = ctx_ptr(ctx, data);

	if (data + ETH_ALEN > data_end ||
	    data_meta + round_up(ETH_ALEN, 4) > data)
		return XDP_DROP;

	__builtin_memcpy(data_meta, data, ETH_ALEN);
	return XDP_PASS;
}

SEC("tx")
int ing_xdp_tx(struct xdp_md *ctx)
{
	void *data_meta = (void *)(long)ctx->data_meta;
	int ret;
	ret = bpf_xdp_adjust_meta(ctx, -round_up(ETH_ALEN, 4));
	if (ret < 0)
		return XDP_DROP;

	void *data_end = (void *)(long)ctx->data_end;
	void *data = (void *)(long)ctx->data;

	struct ethhdr *eth = data;
	struct iphdr *iph;
	struct icmphdr *icmph;

	if (data + sizeof(*eth) + sizeof(*iph) + sizeof(*icmph)> data_end)
		return XDP_PASS;

	if (eth->h_proto != bpf_htons(ETH_P_IP))
		return XDP_PASS;

	iph = data + sizeof(*eth);
	icmph = data + sizeof(*eth) + sizeof(*iph);
	if (icmph->type != ICMP_ECHO)
		return XDP_PASS;

	swap_src_dst_mac(data);
	swap_src_dst_ip(iph);
	icmph->type = ICMP_ECHOREPLY;
	icmph->checksum += 0x0008;

	return XDP_TX;
}

char _license[] SEC("license") = "GPL";

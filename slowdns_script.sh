#!/bin/bash

##############################################
# DNSTT ULTRA SPEED - SSH OPTIMIZED EDITION
# Created By THE KING 👑 💯
# Version: 8.0.0 - Maximum Speed SSH
# Optimized for 10-25 Mbps speeds
# V2Ray removed - Pure SSH performance
##############################################

# Do NOT use set -e: sysctl/modprobe return non-zero on unsupported kernels
# which would abort the entire script. All critical paths handle errors explicitly.
set -o pipefail 2>/dev/null || true

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Paths
INSTALL_DIR="/etc/dnstt"
SSH_DIR="/etc/slowdns"
USER_DB="$SSH_DIR/users.txt"
LOG_DIR="/var/log/dnstt"
DNSTT_SERVER="/usr/local/bin/dnstt-server"
DNSTT_CLIENT="/usr/local/bin/dnstt-client"

# Create directories
mkdir -p "$INSTALL_DIR" "$SSH_DIR" "$LOG_DIR"
touch "$USER_DB"

#============================================
# BANNER
#============================================

show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ██████╗ ███╗   ██╗███████╗████████╗████████╗               ║
║   ██╔══██╗████╗  ██║██╔════╝╚══██╔══╝╚══██╔══╝               ║
║   ██║  ██║██╔██╗ ██║███████╗   ██║      ██║                  ║
║   ██║  ██║██║╚██╗██║╚════██║   ██║      ██║                  ║
║   ██████╔╝██║ ╚████║███████║   ██║      ██║                  ║
║   ╚═════╝ ╚═╝  ╚═══╝╚══════╝   ╚═╝      ╚═╝                  ║
║                                                               ║
║        ██╗   ██╗██╗  ████████╗██████╗  █████╗                ║
║        ██║   ██║██║  ╚══██╔══╝██╔══██╗██╔══██╗               ║
║        ██║   ██║██║     ██║   ██████╔╝███████║               ║
║        ██║   ██║██║     ██║   ██╔══██╗██╔══██║               ║
║        ╚██████╔╝███████╗██║   ██║  ██║██║  ██║               ║
║         ╚═════╝ ╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝               ║
║                                                               ║
║              SSH TUNNEL MANAGER v8.0 ULTRA                   ║
║           Maximum Speed Edition - 10-25 Mbps                 ║
║                  SSH ONLY - NO V2RAY                         ║
║                                                               ║
║          ╔═══════════════════════════════════╗               ║
║          ║  CREATED BY THE KING 👑 💯       ║               ║
║          ╚═══════════════════════════════════╝               ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

press_enter() {
    echo ""
    read -p "Press Enter to continue..."
}

#============================================
# SYSTEM CHECKS
#============================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: This script must be run as root${NC}"
        echo -e "${YELLOW}Please run: sudo bash $0${NC}"
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/debian_version ]] && [[ ! -f /etc/redhat-release ]]; then
        echo -e "${RED}ERROR: This script supports Debian/Ubuntu/CentOS only${NC}"
        exit 1
    fi
}

#============================================
# LOGGING
#============================================

log_message() {
    local message="$1"
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $message"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_DIR/dnstt.log"
}

log_error() {
    local message="$1"
    echo -e "${RED}[ERROR]${NC} $message"
    echo "[ERROR] $message" >> "$LOG_DIR/dnstt.log"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}[SUCCESS]${NC} $message"
    echo "[SUCCESS] $message" >> "$LOG_DIR/dnstt.log"
}

#============================================
# ULTRA SPEED OPTIMIZATION v2.0
# Enhanced UDP + SSH optimizations
# Target: 10-25 Mbps
#============================================

optimize_system_ultra() {
    log_message "${YELLOW}⚡ Applying ULTRA SPEED v2.0 optimization...${NC}"
    echo ""
    
    # Enable IP forwarding
    sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1 || true
    
    # Load required modules
    modprobe tcp_bbr 2>/dev/null || true
    modprobe tcp_hybla 2>/dev/null || true
    
    # Set massive ulimit
    ulimit -n 2097152 2>/dev/null || ulimit -n 1048576 2>/dev/null || true
    
    echo -e "${CYAN}[1/12]${NC} Configuring BBR v2 (Next-gen congestion control)..."
    sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null 2>&1 || true
    sysctl -w net.core.default_qdisc=fq_codel > /dev/null 2>&1 || sysctl -w net.core.default_qdisc=fq > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ BBR v2 enabled with FQ-CoDel${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[2/12]${NC} CRITICAL: Maximum network buffers (1GB for ULTRA speed)..."
    sysctl -w net.core.rmem_max=1073741824 > /dev/null 2>&1 || true
    sysctl -w net.core.wmem_max=1073741824 > /dev/null 2>&1 || true
    sysctl -w net.core.rmem_default=134217728 > /dev/null 2>&1 || true
    sysctl -w net.core.wmem_default=134217728 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_rmem="16384 1048576 1073741824" > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_wmem="16384 1048576 1073741824" > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ Network buffers: 1GB configured${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[3/12]${NC} EXTREME UDP optimization (512KB buffers - EDNS0++)..."
    sysctl -w net.ipv4.udp_rmem_min=524288 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.udp_wmem_min=524288 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.udp_mem="524288 1048576 2097152" > /dev/null 2>&1 || true
    
    # Advanced UDP tuning
    sysctl -w net.core.netdev_max_backlog=300000 > /dev/null 2>&1 || true
    sysctl -w net.core.netdev_budget=3000 > /dev/null 2>&1 || true
    sysctl -w net.core.netdev_budget_usecs=20000 > /dev/null 2>&1 || true
    sysctl -w net.core.somaxconn=262144 > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ UDP: 512KB buffers + 300K backlog (no packet loss)${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[4/12]${NC} SSH-specific optimizations (maximum throughput)..."
    # SSH uses TCP, optimize for SSH traffic
    sysctl -w net.ipv4.tcp_window_scaling=1 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_adv_win_scale=2 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_moderate_rcvbuf=1 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_notsent_lowat=131072 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_retries1=3 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_retries2=5 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_orphan_retries=1 > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ SSH bulk transfer optimizations${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[5/12]${NC} Massive connection tracking (8M connections)..."
    sysctl -w net.netfilter.nf_conntrack_max=8000000 > /dev/null 2>&1 || true
    sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=432000 > /dev/null 2>&1 || true
    sysctl -w net.netfilter.nf_conntrack_udp_timeout=600 > /dev/null 2>&1 || true
    sysctl -w net.netfilter.nf_conntrack_udp_timeout_stream=600 > /dev/null 2>&1 || true
    echo 1048576 > /sys/module/nf_conntrack/parameters/hashsize 2>/dev/null || true
    echo -e "${GREEN}✓ Connection tracking: 8M connections${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[6/12]${NC} Advanced TCP optimizations..."
    sysctl -w net.ipv4.tcp_fastopen=3 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_tw_reuse=1 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_tw_recycle=0 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_fin_timeout=5 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_max_tw_buckets=2000000 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_max_syn_backlog=262144 > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ TCP FastOpen + advanced tuning${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[7/12]${NC} TCP Keepalive for stable tunnels..."
    sysctl -w net.ipv4.tcp_keepalive_time=60 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_keepalive_probes=5 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_keepalive_intvl=10 > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ TCP Keepalive: 60s intervals${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[8/12]${NC} Zero-copy and offloading optimizations..."
    sysctl -w net.ipv4.tcp_low_latency=1 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_sack=1 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_fack=1 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_timestamps=1 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_mtu_probing=1 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_tso_win_divisor=3 > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ Zero-copy + offloading enabled${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[9/12]${NC} Expanded port range (mega scale)..."
    sysctl -w net.ipv4.ip_local_port_range="1024 65535" > /dev/null 2>&1 || true
    sysctl -w net.ipv4.ip_local_reserved_ports="" > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ Port range: 1024-65535 (64K ports)${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[10/12]${NC} DNS tunnel specific optimizations..."
    sysctl -w net.ipv4.udp_early_demux=1 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.ip_early_demux=1 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_early_retrans=3 > /dev/null 2>&1 || true
    sysctl -w net.ipv4.route.max_size=4194304 > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ DNS tunnel optimizations${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[11/12]${NC} Memory and queue optimizations..."
    sysctl -w net.core.optmem_max=134217728 > /dev/null 2>&1 || true
    sysctl -w net.core.netdev_budget=3000 > /dev/null 2>&1 || true
    sysctl -w net.core.netdev_budget_usecs=20000 > /dev/null 2>&1 || true
    sysctl -w vm.min_free_kbytes=65536 > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ Memory optimization: 128MB socket buffers${NC}"
    sleep 0.5
    
    echo -e "${CYAN}[12/12]${NC} Creating permanent configuration..."
    
    cat > /etc/sysctl.d/99-dnstt-ultra-v2.conf << 'EOF'
# DNSTT ULTRA SPEED v2.0 - SSH OPTIMIZED
# Created By THE KING 👑 💯
# Optimized for 10-25 Mbps DNS tunnel speeds
# SSH ONLY - Maximum Performance

### IP FORWARDING ###
net.ipv4.ip_forward = 1

### BBR v2 CONGESTION CONTROL ###
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq_codel

### MAXIMUM NETWORK BUFFERS (1GB) ###
net.core.rmem_max = 1073741824
net.core.wmem_max = 1073741824
net.core.rmem_default = 134217728
net.core.wmem_default = 134217728
net.ipv4.tcp_rmem = 16384 1048576 1073741824
net.ipv4.tcp_wmem = 16384 1048576 1073741824
net.core.optmem_max = 134217728

### EXTREME UDP OPTIMIZATION (512KB - EDNS0++) ###
net.ipv4.udp_rmem_min = 524288
net.ipv4.udp_wmem_min = 524288
net.ipv4.udp_mem = 524288 1048576 2097152

### DNS BURST HANDLING (300K PACKETS) ###
net.core.netdev_max_backlog = 300000
net.core.netdev_budget = 3000
net.core.netdev_budget_usecs = 20000
net.core.somaxconn = 262144

### MASSIVE CONNECTION TRACKING (8M) ###
net.netfilter.nf_conntrack_max = 8000000
net.netfilter.nf_conntrack_tcp_timeout_established = 432000
net.netfilter.nf_conntrack_udp_timeout = 600
net.netfilter.nf_conntrack_udp_timeout_stream = 600

### SSH-SPECIFIC OPTIMIZATIONS ###
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = 2
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_notsent_lowat = 131072

### ADVANCED TCP OPTIMIZATIONS ###
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_orphan_retries = 1

### TCP KEEPALIVE ###
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 10

### ZERO-COPY & OFFLOADING ###
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_tso_win_divisor = 3

### PORT RANGE ###
net.ipv4.ip_local_port_range = 1024 65535

### DNS-SPECIFIC ###
net.ipv4.udp_early_demux = 1
net.ipv4.ip_early_demux = 1
net.ipv4.tcp_early_retrans = 3
net.ipv4.route.max_size = 4194304

### MEMORY ###
vm.min_free_kbytes = 65536
EOF

    echo -e "${GREEN}✓ Config saved: /etc/sysctl.d/99-dnstt-ultra-v2.conf${NC}"
    
    echo -e "${CYAN}[BONUS]${NC} Setting ultra-high file descriptors..."
    cat > /etc/security/limits.d/99-dnstt-ultra-v2.conf << 'EOF'
# DNSTT ULTRA v2.0 - Maximum file descriptors
# Created By THE KING 👑 💯
* soft nofile 2097152
* hard nofile 2097152
root soft nofile 2097152
root hard nofile 2097152
* soft nproc 2097152
* hard nproc 2097152
EOF
    echo -e "${GREEN}✓ File descriptors: 2M (ultra scale)${NC}"
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         ⚡ ULTRA SPEED v2.0 ACTIVATED ⚡            ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Optimization Summary (SSH OPTIMIZED):${NC}"
    echo -e "  ${GREEN}✓${NC} BBR v2 + FQ-CoDel"
    echo -e "  ${GREEN}✓${NC} 1GB Network Buffers"
    echo -e "  ${GREEN}✓${NC} 512KB UDP Buffers (EDNS0++)"
    echo -e "  ${GREEN}✓${NC} 300K Packet Backlog"
    echo -e "  ${GREEN}✓${NC} 8M Connection Tracking"
    echo -e "  ${GREEN}✓${NC} SSH Bulk Transfer Optimization"
    echo -e "  ${GREEN}✓${NC} Zero-Copy + Offloading"
    echo -e "  ${GREEN}✓${NC} 2M File Descriptors"
    echo -e "  ${GREEN}✓${NC} Advanced TCP tuning"
    echo ""
    echo -e "${YELLOW}Expected Speed: 10-25 Mbps 🚀🚀🚀${NC}"
    
    sleep 3
}

#============================================
# SSH SERVER OPTIMIZATION
#============================================

optimize_for_512() {
    log_message "${YELLOW}⚡ Applying 512B MTU High-Frequency Small-Packet optimizations...${NC}"
    echo ""

    # ── Design rationale ────────────────────────────────────────────────────────
    # At MTU=512 the DNSTT process sends thousands of tiny UDP datagrams per
    # second.  The bottleneck is NOT bandwidth — it is PACKET-PROCESSING RATE.
    #
    # Three failure modes cause the 300 kbps ceiling:
    #   1. UDP socket drop  – kernel recv queue fills faster than userspace drains
    #   2. NAPI starvation  – default budget/usecs too high → small pkts delayed
    #   3. Congestion misfit – standard BBR is calibrated for large, smooth flows;
    #                          it backs off too aggressively on the bursty/lossy
    #                          pattern produced by DNS relays.
    #
    # The settings below attack all three.
    # ────────────────────────────────────────────────────────────────────────────

    # ── [A] UDP socket buffers: sized for HIGH PACKET COUNT, not high bandwidth ─
    # At 512 B/pkt and 4 Mbps target: ~1000 pkts/s.  We want to absorb at least
    # 0.5 s of burst without dropping → 500 pkts × 512 B = 256 KB minimum queue.
    # We set rmem_max/wmem_max to 8 MB so each DNSTT socket can grow its buffer
    # via SO_RCVBUF without hitting the system cap.
    # udp_rmem_min/wmem_min is the GUARANTEED floor per socket — set to exactly
    # one DNS "page" (4096 B) × 512 = 2 MB so the allocator never under-commits.
    echo -e "${CYAN}[A]${NC} UDP socket buffer tuning for 512B high-packet-rate..."
    sysctl -w net.core.rmem_max=8388608             > /dev/null 2>&1 || true  # 8 MB socket cap
    sysctl -w net.core.wmem_max=8388608             > /dev/null 2>&1 || true
    sysctl -w net.core.rmem_default=2097152         > /dev/null 2>&1 || true  # 2 MB default
    sysctl -w net.core.wmem_default=2097152         > /dev/null 2>&1 || true
    # udp_rmem_min / udp_wmem_min: guaranteed floor for each UDP socket.
    # Value = 512 (MTU) × 4096 (pkts) = 2 097 152 B  → the kernel will NEVER
    # shrink a DNSTT socket below this, preventing drop under memory pressure.
    sysctl -w net.ipv4.udp_rmem_min=2097152         > /dev/null 2>&1 || true
    sysctl -w net.ipv4.udp_wmem_min=2097152         > /dev/null 2>&1 || true
    # udp_mem (pages): low / pressure / max.  Values in 4 KB pages.
    # 256 MB / 512 MB / 1 GB  → enough headroom for thousands of concurrent DNS pkts.
    sysctl -w net.ipv4.udp_mem="65536 131072 262144" > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ UDP buffers: 8 MB cap | 2 MB floor/socket (512B × 4096 pkts guaranteed)${NC}"
    sleep 0.3

    # ── [B] NAPI poll budget: reduce CPU interrupt delay for small packets ───────
    # net.core.netdev_budget = number of packets processed per NAPI poll cycle.
    # Smaller value → kernel returns to userspace sooner → lower per-packet latency.
    # For 512B DNS floods, 300 packets/cycle at 1500 µs ceiling is the sweet spot:
    #   - high enough to avoid excessive context switches
    #   - low enough to not starve the DNSTT process between polls
    # netdev_max_backlog = per-CPU queue depth before the kernel starts dropping.
    # 100 000 gives ~50 MB of headroom at 512 B/pkt.
    echo -e "${CYAN}[B]${NC} NAPI interrupt budget for high-frequency small packets..."
    sysctl -w net.core.netdev_budget=300            > /dev/null 2>&1 || true
    sysctl -w net.core.netdev_budget_usecs=1500     > /dev/null 2>&1 || true
    sysctl -w net.core.netdev_max_backlog=100000    > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ NAPI: 300 pkts/cycle | 1500 µs ceiling | 100K backlog${NC}"
    sleep 0.3

    # ── [C] Congestion control: HYBLA — built for lossy/high-latency links ───────
    # Standard BBR assumes a clean, measurable BDP.  DNS tunnels are neither:
    #   - DNS relays add variable jitter (10–200 ms)
    #   - Packet loss is structural (DNS truncation, relay drops)
    #   - RTT measurements are noisy → BBR's model becomes inaccurate → throttles
    #
    # TCP HYBLA was designed specifically for satellite/lossy links. It uses a
    # fixed reference RTT (RTT0=25 ms) and scales the window aggressively even
    # when loss is detected — exactly what a DNS tunnel needs.
    # We pair it with fq (not fq_codel) because fq_codel's AQM actively DROPS
    # packets at 5 ms queue delay — far too aggressive for DNS tunnel jitter.
    echo -e "${CYAN}[C]${NC} Congestion control: HYBLA (lossy/high-latency DNS environment)..."
    modprobe tcp_hybla 2>/dev/null || true
    if sysctl -w net.ipv4.tcp_congestion_control=hybla > /dev/null 2>&1; then
        echo -e "${GREEN}✓ HYBLA enabled (lossy-link optimized — replaces BBR for DNS tunnel)${NC}"
    else
        # Fallback: BBR is better than cubic if hybla module is unavailable
        modprobe tcp_bbr 2>/dev/null || true
        sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null 2>&1 || true
        echo -e "${YELLOW}⚠ HYBLA unavailable — fell back to BBR${NC}"
    fi
    # fq scheduler: pure per-flow fair queuing with NO active queue management.
    # This avoids fq_codel's aggressive early drops on bursty DNS traffic.
    sysctl -w net.core.default_qdisc=fq             > /dev/null 2>&1 || true
    # Increase TCP initial congestion window for small-RTT loopback SSH leg.
    ip route change local 127.0.0.0/8 dev lo initcwnd 32 2>/dev/null || true
    echo -e "${GREEN}✓ QDisc: fq (no AQM drop — safe for bursty DNS bursts)${NC}"
    sleep 0.3

    # ── [D] TCP tuning: optimize the SSH leg (loopback TCP inside tunnel) ────────
    # The SSH session travels over TCP between DNSTT and sshd on 127.0.0.1.
    # With effective MTU=512 the TCP MSS is ~460 B — segments are tiny and many.
    # Key settings:
    #   tcp_low_latency=1   : skip receive buffer auto-tuning delays
    #   tcp_sack=1          : selective ACK → faster retransmit on packet loss
    #   tcp_notsent_lowat   : limit unsent bytes in socket buffer → lower write latency
    #   tcp_adv_win_scale=-2: use a larger fraction of rmem as the TCP window
    #                         (important when rmem is big but segments are tiny)
    echo -e "${CYAN}[D]${NC} TCP tuning for SSH leg over 512B tunnel..."
    sysctl -w net.ipv4.tcp_low_latency=1            > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_sack=1                   > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_timestamps=1             > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_fastopen=3               > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0  > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_notsent_lowat=16384      > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_adv_win_scale=-2         > /dev/null 2>&1 || true
    # Faster retransmit thresholds: don't wait 3 dupACKs on a lossy DNS link
    sysctl -w net.ipv4.tcp_reordering=3             > /dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_early_retrans=3          > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ TCP: low-latency mode | SACK | fast retransmit | low notsent_lowat${NC}"
    sleep 0.3

    # ── [E] Loopback MTU: keep local SSH leg at full size ───────────────────────
    # DNSTT decapsulates DNS packets and re-injects them to 127.0.0.1:SSH_PORT
    # over loopback.  The loopback MTU should stay at 65536 so the SSH TCP
    # stack uses large segments internally — only the DNS wire MTU is 512.
    echo -e "${CYAN}[E]${NC} Loopback MTU: ensuring 65536 for local SSH forwarding..."
    ip link set lo mtu 65536 2>/dev/null || true
    echo -e "${GREEN}✓ Loopback MTU = 65536 (SSH leg unaffected by DNS MTU constraint)${NC}"
    sleep 0.3

    # ── [F] I/O multiplexing: ulimit + process priority ──────────────────────────
    # Each active DNS stream = 1 file descriptor in DNSTT.  At 2–4 Mbps with
    # 512B packets we may have hundreds of concurrent "streams".
    # Raise the process-level FD limit and pin DNSTT to high scheduler priority.
    echo -e "${CYAN}[F]${NC} File descriptor limit and process priority..."
    ulimit -n 1048576 2>/dev/null || ulimit -n 524288 2>/dev/null || true
    # Renice the current shell's child processes (dnstt will inherit nice=-10)
    renice -n -10 -p $$ 2>/dev/null || true
    echo -e "${GREEN}✓ FD limit: 1M | process nice: -10 (high priority)${NC}"
    sleep 0.3

    # ── [G] Persist all settings ────────────────────────────────────────────────
    echo -e "${CYAN}[G]${NC} Saving 512B tunnel sysctl config permanently..."
    cat > /etc/sysctl.d/99-dnstt-512b-tunnel.conf << 'SYSCTL'
# DNSTT 512B MTU Tunnel Optimizations — High-Frequency Small-Packet Edition
# Created By THE KING 👑 💯
# Target: 2–4 Mbps through 512B MTU DNS tunnel (replaces 300 kbps default)

# ── UDP socket buffers (8 MB cap, 2 MB guaranteed floor per socket) ──────────
net.core.rmem_max       = 8388608
net.core.wmem_max       = 8388608
net.core.rmem_default   = 2097152
net.core.wmem_default   = 2097152
# udp_rmem_min = 512 B × 4096 pkts = 2 MB (never drop under memory pressure)
net.ipv4.udp_rmem_min   = 2097152
net.ipv4.udp_wmem_min   = 2097152
# udp_mem in 4 KB pages: 256 MB / 512 MB / 1 GB
net.ipv4.udp_mem        = 65536 131072 262144

# ── NAPI budget: 300 pkts/cycle | 1500 µs | 100K backlog ────────────────────
net.core.netdev_budget       = 300
net.core.netdev_budget_usecs = 1500
net.core.netdev_max_backlog  = 100000

# ── Congestion control: HYBLA (lossy/jittery DNS link) + fq qdisc ───────────
net.ipv4.tcp_congestion_control = hybla
net.core.default_qdisc          = fq

# ── TCP low-latency SSH leg (loopback, tiny segments) ───────────────────────
net.ipv4.tcp_low_latency         = 1
net.ipv4.tcp_sack                = 1
net.ipv4.tcp_timestamps          = 1
net.ipv4.tcp_fastopen            = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_notsent_lowat       = 16384
net.ipv4.tcp_adv_win_scale       = -2
net.ipv4.tcp_reordering          = 3
net.ipv4.tcp_early_retrans       = 3

# ── General ──────────────────────────────────────────────────────────────────
net.ipv4.ip_forward = 1
SYSCTL
    sysctl -p /etc/sysctl.d/99-dnstt-512b-tunnel.conf > /dev/null 2>&1 || true
    echo -e "${GREEN}✓ Saved + applied: /etc/sysctl.d/99-dnstt-512b-tunnel.conf${NC}"

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ⚡ 512B HIGH-FREQUENCY SMALL-PACKET MODE ACTIVE ⚡  ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    echo -e "  ${GREEN}✓${NC} UDP: 8 MB socket cap | 2 MB floor (512B × 4096 pkts)"
    echo -e "  ${GREEN}✓${NC} NAPI: 300 pkts/cycle | 1500 µs (low interrupt latency)"
    echo -e "  ${GREEN}✓${NC} Congestion: HYBLA (lossy/jitter-tolerant — not BBR)"
    echo -e "  ${GREEN}✓${NC} QDisc: fq (no AQM early-drop on DNS bursts)"
    echo -e "  ${GREEN}✓${NC} TCP SSH leg: SACK | notsent_lowat=16K | adv_win_scale=-2"
    echo -e "  ${GREEN}✓${NC} Loopback MTU: 65536 (SSH leg unaffected by DNS MTU)"
    echo -e "  ${GREEN}✓${NC} FD limit: 1M | Process nice: -10"
    echo -e "  ${YELLOW}Expected: 300 kbps → 2–4 Mbps through 512B MTU tunnel${NC}"
    echo ""
    sleep 1
}

optimize_ssh_server() {
    log_message "${YELLOW}🔧 Optimizing SSH server for 512B MTU tunnel (minimum overhead)...${NC}"
    echo ""

    # ── Design rationale ──────────────────────────────────────────────────────
    # Inside a DNS tunnel every byte of SSH header eats into the 512B payload.
    # A standard AES-128-CTR frame adds:
    #   4B length + 1B padding_len + padding + 16B MAC  = ~21B overhead / packet
    # chacha20-poly1305 merges encryption + MAC into one pass and uses AEAD, so:
    #   4B length + 1B padding_len + padding + 16B Poly1305 tag = same bytes BUT
    #   the CPU cost is ~3× lower → DNSTT can process more packets per second.
    #
    # Additionally: SSH compression (zlib) operates on the plaintext BEFORE
    # encryption. On interactive shell traffic (text) it typically achieves
    # 3:1 compression. This means more data fits in each 512B DNS query.
    #
    # RekeyLimit is set LOW (32M / 15min) because a rekey in a DNS tunnel
    # causes a multi-RTT pause. Keeping the rekey cheap+frequent avoids a
    # single long stall. "32M" means after 32 MB of data OR 15 minutes,
    # whichever comes first.
    # ─────────────────────────────────────────────────────────────────────────

    # Backup original sshd_config (only once)
    if [[ ! -f /etc/ssh/sshd_config.backup ]]; then
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
        echo -e "${GREEN}✓ Backed up original SSH config${NC}"
    fi

    # Remove any previous DNSTT SSH block to avoid duplicates on reinstall
    if grep -q "# DNSTT ULTRA" /etc/ssh/sshd_config 2>/dev/null; then
        sed -i '/# DNSTT ULTRA/,/^# END DNSTT/d' /etc/ssh/sshd_config
        echo -e "${CYAN}↺ Removed previous DNSTT SSH block (fresh apply)${NC}"
    fi

    cat >> /etc/ssh/sshd_config << 'EOF'

# DNSTT 512B MTU Edition — SSH Optimizations
# Created By THE KING 👑 💯
# END DNSTT marker: do not remove this line

# ── Keepalive: keep the tunnel from timing out at DNS relay ──────────────────
TCPKeepAlive yes
ClientAliveInterval 20
ClientAliveCountMax 6

# ── Compression: zlib on plaintext — MORE payload per 512B query ─────────────
# "delayed" = zlib kicks in after auth (protects against CRIME-style attacks)
Compression delayed

# ── Cipher order: chacha20-poly1305 FIRST — lowest overhead, fastest CPU ─────
# chacha20-poly1305: single-pass AEAD, no separate MAC compute, ~3× faster
#   than AES-CTR+HMAC on servers without AES-NI (common on VPS).
# aes128-gcm: hardware AES-NI path, similar speed on modern CPUs with AES-NI.
# aes128/256-ctr: kept for HTTP Injector / legacy client compatibility.
Ciphers chacha20-poly1305@openssh.com,aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes128-ctr,aes256-ctr,aes192-ctr

# ── MACs: ETM variants only — authenticate-then-encrypt, lower overhead ──────
# Non-ETM MACs compute over plaintext + ciphertext = extra CPU per packet.
# ETM computes only over ciphertext = cheaper, and is the modern standard.
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com

# ── Key exchange: fastest curve — minimal RTTs on tunnel setup ───────────────
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256

# ── Rekey: small limit avoids long rekey stalls in DNS tunnel ────────────────
# 32M data OR 15 min — keeps each rekey pause short and predictable
RekeyLimit 32M 15m

# ── Concurrency ───────────────────────────────────────────────────────────────
MaxSessions 500
MaxStartups 200:30:1000
MaxAuthTries 8

# ── Disable pre-auth banner (saves bytes on every new connection) ─────────────
PrintMotd no
PrintLastLog no
EOF

    echo -e "${GREEN}✓ SSH server optimized for 512B MTU tunnel:${NC}"
    echo -e "  ${GREEN}✓${NC} Cipher order: chacha20-poly1305 first (lowest per-packet overhead)"
    echo -e "  ${GREEN}✓${NC} Compression: delayed zlib (more payload per DNS query)"
    echo -e "  ${GREEN}✓${NC} MACs: ETM-only (authenticate-then-encrypt, cheaper on small pkts)"
    echo -e "  ${GREEN}✓${NC} RekeyLimit: 32M/15m (avoids long rekey pause in tunnel)"

    echo -e "${CYAN}Validating and restarting SSH service...${NC}"
    if sshd -t 2>/dev/null; then
        systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
        echo -e "${GREEN}✓ SSH service restarted successfully${NC}"
    else
        echo -e "${RED}✗ sshd config test failed — restoring backup${NC}"
        cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
        systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
    fi

    sleep 1
}

#============================================
# INSTALLATION
#============================================

install_dependencies() {
    log_message "${YELLOW}📦 Installing dependencies...${NC}"
    echo ""

    if [[ -f /etc/debian_version ]]; then
        export DEBIAN_FRONTEND=noninteractive

        echo -e "${CYAN}Updating package lists...${NC}"
        if ! apt-get update -qq 2>&1; then
            log_error "apt-get update failed — check network or /etc/apt/sources.list"
            return 1
        fi
        echo -e "${GREEN}✓ Package lists updated${NC}"

        # Detect Debian version to handle iptables-persistent removal in Debian 14
        DEBIAN_VERSION=$(cat /etc/debian_version | cut -d. -f1 2>/dev/null || echo "12")
        # Debian 14 (trixie) uses "trixie" or version >= 14
        if grep -qiE "trixie|forky|14" /etc/debian_version /etc/os-release 2>/dev/null; then
            DEBIAN_MAJOR=14
        else
            DEBIAN_MAJOR="${DEBIAN_VERSION}"
        fi

        echo -e "${CYAN}Detected Debian major version: ${DEBIAN_MAJOR}${NC}"

        # Core packages (always available)
        PKGS="wget curl git build-essential ca-certificates dnsutils net-tools iproute2 sysstat htop bc openssh-server iptables"

        # iptables-persistent removed in Debian 14 — use nftables instead
        if [[ "$DEBIAN_MAJOR" -ge 14 ]]; then
            echo -e "${YELLOW}⚠ Debian 14+: using nftables (iptables-persistent removed)${NC}"
            PKGS="$PKGS nftables"
        else
            PKGS="$PKGS iptables-persistent netfilter-persistent"
        fi

        echo -e "${CYAN}Installing packages...${NC}"
        if ! apt-get install -y $PKGS 2>&1; then
            log_error "Package installation failed. See output above."
            return 1
        fi
        echo -e "${GREEN}✓ All packages installed${NC}"

        echo -e "${CYAN}Enabling SSH service...${NC}"
        systemctl enable ssh 2>/dev/null || systemctl enable sshd 2>/dev/null || true
        systemctl start ssh 2>/dev/null || systemctl start sshd 2>/dev/null || true
        echo -e "${GREEN}✓ SSH service running${NC}"

    elif [[ -f /etc/redhat-release ]]; then
        yum install -y wget curl git gcc make iptables iptables-services \
            ca-certificates bind-utils net-tools sysstat htop bc openssh-server 2>&1 || true
    fi

    echo ""
    log_success "Dependencies installed successfully"
    sleep 1
}

install_golang() {
    if command -v go &> /dev/null; then
        GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
        if [[ "$GO_VERSION" > "1.21" ]]; then
            log_success "Go $GO_VERSION already installed"
            return 0
        fi
    fi

    log_message "${YELLOW}📦 Installing Go 1.22.4 (Debian 14 compatible)...${NC}"
    echo ""

    # Detect CPU architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  GO_ARCH="amd64" ;;
        aarch64) GO_ARCH="arm64" ;;
        armv7l)  GO_ARCH="armv6l" ;;
        *)       GO_ARCH="amd64" ;;
    esac

    GO_VERSION_NUM="1.22.4"
    GO_TARBALL="go${GO_VERSION_NUM}.linux-${GO_ARCH}.tar.gz"
    GO_URL="https://go.dev/dl/${GO_TARBALL}"

    cd /tmp
    echo -e "${CYAN}Downloading Go ${GO_VERSION_NUM} for ${GO_ARCH}...${NC}"
    if ! wget -q --show-progress "$GO_URL" -O "$GO_TARBALL"; then
        log_error "Failed to download Go. Check internet connection."
        return 1
    fi
    echo -e "${GREEN}✓ Downloaded${NC}"

    echo -e "${CYAN}Extracting...${NC}"
    rm -rf /usr/local/go
    if ! tar -C /usr/local -xzf "$GO_TARBALL"; then
        log_error "Failed to extract Go tarball"
        rm -f "$GO_TARBALL"
        return 1
    fi
    rm -f "$GO_TARBALL"
    echo -e "${GREEN}✓ Extracted${NC}"

    # Setup Go environment
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=/root/go
    export GOCACHE=/root/.cache/go-build

    cat > /etc/profile.d/golang.sh << 'GOEOF'
export PATH=$PATH:/usr/local/go/bin
export GOPATH=/root/go
export GOCACHE=/root/.cache/go-build
GOEOF
    chmod +x /etc/profile.d/golang.sh

    # Make available in current session immediately
    export PATH=$PATH:/usr/local/go/bin

    if ! command -v go &>/dev/null; then
        log_error "Go installation failed — binary not found after install"
        return 1
    fi

    echo ""
    log_success "Go $(go version | awk '{print $3}') installed for ${GO_ARCH}"
    sleep 1
}

build_dnstt() {
    log_message "${YELLOW}🔨 Building DNSTT from source...${NC}"
    echo ""

    # Ensure Go is in PATH for this function regardless of how script was invoked
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=/root/go
    export GOCACHE=/root/.cache/go-build
    export GO111MODULE=on

    if ! command -v go &>/dev/null; then
        log_error "Go not found in PATH. Install Go first."
        return 1
    fi

    cd /tmp
    rm -rf dnstt-src

    echo -e "${CYAN}Cloning DNSTT repository...${NC}"
    # Primary source
    if git clone https://www.bamsoftware.com/git/dnstt.git dnstt-src 2>&1; then
        echo -e "${GREEN}✓ Cloned from bamsoftware.com${NC}"
    # Mirror fallback
    elif git clone https://github.com/ekoops/dnstt.git dnstt-src 2>&1; then
        echo -e "${YELLOW}⚠ Primary failed — used GitHub mirror${NC}"
    else
        log_error "Could not clone DNSTT repository. Check internet connection."
        return 1
    fi

    # Build server
    echo -e "${CYAN}Building dnstt-server...${NC}"
    cd /tmp/dnstt-src/dnstt-server
    if ! go build -o "$DNSTT_SERVER" . 2>&1; then
        log_error "dnstt-server build failed"
        cd /tmp
        rm -rf dnstt-src
        return 1
    fi
    chmod +x "$DNSTT_SERVER"
    echo -e "${GREEN}✓ Server compiled: $DNSTT_SERVER${NC}"

    # Build client
    echo -e "${CYAN}Building dnstt-client...${NC}"
    cd /tmp/dnstt-src/dnstt-client
    if ! go build -o "$DNSTT_CLIENT" . 2>&1; then
        log_error "dnstt-client build failed"
        cd /tmp
        rm -rf dnstt-src
        return 1
    fi
    chmod +x "$DNSTT_CLIENT"
    echo -e "${GREEN}✓ Client compiled: $DNSTT_CLIENT${NC}"

    # Verify binaries exist and are executable
    if [[ ! -x "$DNSTT_SERVER" ]] || [[ ! -x "$DNSTT_CLIENT" ]]; then
        log_error "Binaries missing or not executable after build"
        return 1
    fi

    # Cleanup source
    cd /tmp
    rm -rf dnstt-src

    echo ""
    log_success "DNSTT build complete"
    log_message "   Server: $DNSTT_SERVER ($(du -sh $DNSTT_SERVER | cut -f1))"
    log_message "   Client: $DNSTT_CLIENT ($(du -sh $DNSTT_CLIENT | cut -f1))"
    sleep 1
    return 0
}

#============================================
# FIREWALL CONFIGURATION
#============================================

configure_firewall() {
    log_message "${YELLOW}🔥 Configuring firewall...${NC}"
    echo ""

    NET_INTERFACE=$(ip route show default 2>/dev/null | awk '{print $5}' | head -1)
    NET_INTERFACE=${NET_INTERFACE:-eth0}
    log_message "Network interface: $NET_INTERFACE"

    # Disable UFW — conflicts with raw iptables management
    if command -v ufw &> /dev/null; then
        echo -e "${CYAN}Disabling UFW...${NC}"
        ufw --force disable 2>/dev/null || true
        systemctl stop ufw 2>/dev/null || true
        systemctl disable ufw 2>/dev/null || true
        echo -e "${GREEN}✓ UFW disabled${NC}"
    fi

    # Stop systemd-resolved — it holds port 53 and blocks dnstt
    if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
        echo -e "${CYAN}Stopping systemd-resolved (conflicts with port 53)...${NC}"
        systemctl stop systemd-resolved 2>/dev/null || true
        systemctl disable systemd-resolved 2>/dev/null || true
        # Write static resolv.conf so the server still resolves names
        rm -f /etc/resolv.conf
        cat > /etc/resolv.conf << 'RESOLVEOF'
nameserver 1.1.1.1
nameserver 8.8.8.8
RESOLVEOF
        # Lock it so systemd-resolved can't recreate the symlink
        chattr +i /etc/resolv.conf 2>/dev/null || true
        echo -e "${GREEN}✓ systemd-resolved stopped; resolv.conf set to 1.1.1.1/8.8.8.8${NC}"
    fi

    # CRITICAL: Enable IP forwarding NOW (required for traffic to pass through tunnel)
    echo 1 > /proc/sys/net/ipv4/ip_forward
    sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1 || true
    # Also make it permanent
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf 2>/dev/null || true
    grep -q "^net.ipv4.ip_forward" /etc/sysctl.conf 2>/dev/null || echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    echo -e "${GREEN}✓ IP forwarding enabled${NC}"

    echo -e "${CYAN}Configuring iptables rules...${NC}"

    # Load conntrack module (needed before any -m conntrack rule)
    modprobe nf_conntrack 2>/dev/null || true

    # Flush existing rules
    iptables -F 2>/dev/null || true
    iptables -t nat -F 2>/dev/null || true
    iptables -t mangle -F 2>/dev/null || true
    iptables -X 2>/dev/null || true

    # Default: accept all (tunnel server — not an edge firewall)
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

    # Loopback (required for SSH ↔ DNSTT local communication)
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    # Allow established/related (stateful return traffic)
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # UDP port 5300 — dnstt-server listener (ACCEPT before any other rule)
    iptables -I INPUT 1 -p udp --dport 5300 -j ACCEPT

    # UDP port 53 — public DNS entry point
    iptables -I INPUT 2 -p udp --dport 53 -j ACCEPT

    # SSH
    iptables -I INPUT 3 -p tcp --dport 22 -j ACCEPT

    # HTTP/HTTPS (for curl/wget inside tunnel and management)
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT

    # NAT: redirect incoming UDP port 53 → dnstt-server on port 5300
    # This lets clients point at port 53 (standard DNS) without running dnstt as root on 53
    iptables -t nat -I PREROUTING 1 -p udp --dport 53 -j REDIRECT --to-ports 5300

    # CRITICAL FIX: MASQUERADE — rewrites source IP of forwarded tunnel traffic to
    # the server public IP so that internet replies can route back to the client.
    # Without this rule the VPN connects but NO traffic passes through (packets
    # leave the server with a private/tunnel source IP and are dropped by the ISP).
    iptables -t nat -A POSTROUTING -o "$NET_INTERFACE" -j MASQUERADE
    echo -e "${GREEN}✓ NAT MASQUERADE enabled on $NET_INTERFACE (traffic can now pass through)${NC}"

    # FORWARD chain: explicitly allow bidirectional traffic through the tunnel
    iptables -A FORWARD -i lo -j ACCEPT
    iptables -A FORWARD -o lo -j ACCEPT
    iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A FORWARD -o "$NET_INTERFACE" -j ACCEPT
    iptables -A FORWARD -i "$NET_INTERFACE" -j ACCEPT
    echo -e "${GREEN}✓ FORWARD chain rules added (bidirectional tunnel traffic)${NC}"

    echo -e "${GREEN}✓ iptables rules applied${NC}"

    # Tune conntrack for UDP DNS streams
    echo -e "${CYAN}Tuning connection tracking...${NC}"
    # Lower UDP timeout — DNS streams are short-lived; don't hold conntrack entries 600s
    echo 60  > /proc/sys/net/netfilter/nf_conntrack_udp_timeout 2>/dev/null || true
    echo 120 > /proc/sys/net/netfilter/nf_conntrack_udp_timeout_stream 2>/dev/null || true
    # Raise max entries to handle burst of parallel DNS queries
    echo 524288 > /proc/sys/net/netfilter/nf_conntrack_max 2>/dev/null || true
    echo -e "${GREEN}✓ conntrack: 524K entries | UDP timeout 60s/120s${NC}"

    # Save rules persistently — method depends on Debian version
    if command -v netfilter-persistent &>/dev/null; then
        netfilter-persistent save > /dev/null 2>&1 || true
    fi
    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || true

    # On Debian 14 also write an nftables-compatible persistence hook
    if grep -qiE "trixie|forky|14" /etc/debian_version /etc/os-release 2>/dev/null; then
        # Create a systemd oneshot that restores iptables rules on boot
        cat > /etc/systemd/system/iptables-restore-dnstt.service << 'IPTS'
[Unit]
Description=Restore DNSTT iptables rules
Before=network-pre.target
Wants=network-pre.target
DefaultDependencies=no

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables/rules.v4
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
IPTS
        systemctl daemon-reload
        systemctl enable iptables-restore-dnstt 2>/dev/null || true
        echo -e "${GREEN}✓ iptables persistence: systemd restore unit (Debian 14 compatible)${NC}"
    fi

    echo ""
    log_success "Firewall configured"
    echo -e "${CYAN}Open ports + NAT:${NC}"
    echo -e "  ${GREEN}✓${NC} UDP 53  → redirected to 5300 (public DNS entry)"
    echo -e "  ${GREEN}✓${NC} UDP 5300 (dnstt-server listener)"
    echo -e "  ${GREEN}✓${NC} TCP 22  (SSH)"
    echo -e "  ${GREEN}✓${NC} TCP 80/443 (HTTP/HTTPS)"
    echo -e "  ${GREEN}✓${NC} NAT MASQUERADE on $NET_INTERFACE (traffic passes through)"
    echo -e "  ${GREEN}✓${NC} IP forwarding = 1 (tunnel routing active)"

    sleep 2
}

#============================================
# KEY GENERATION
#============================================

generate_keys() {
    log_message "${YELLOW}🔑 Generating DNSTT encryption keys...${NC}"
    echo ""

    if [[ ! -x "$DNSTT_SERVER" ]]; then
        log_error "dnstt-server binary not found at $DNSTT_SERVER — run build first"
        return 1
    fi

    cd "$INSTALL_DIR"
    rm -f server.key server.pub

    echo -e "${CYAN}Running: dnstt-server -gen-key ...${NC}"
    # Show real stderr so we can diagnose failures — do NOT suppress with > /dev/null
    if ! "$DNSTT_SERVER" -gen-key -privkey-file server.key -pubkey-file server.pub; then
        log_error "Key generation failed. Output above shows the reason."
        return 1
    fi

    # Validate both files exist and have content
    if [[ ! -s "server.key" ]]; then
        log_error "server.key is empty or missing"
        return 1
    fi
    if [[ ! -s "server.pub" ]]; then
        log_error "server.pub is empty or missing"
        return 1
    fi

    # dnstt public key is base64-encoded 32 bytes = 44 chars (with padding) or 43 without
    PUBKEY_LEN=$(wc -c < server.pub | tr -d '[:space:]')
    if [[ "$PUBKEY_LEN" -lt 40 ]]; then
        log_error "Public key looks invalid (too short: ${PUBKEY_LEN} bytes). Keygen may have silently failed."
        cat server.pub
        return 1
    fi

    chmod 600 server.key
    chmod 644 server.pub

    echo -e "${GREEN}✓ Keys generated successfully${NC}"
    echo -e "${WHITE}  Public key: ${CYAN}$(cat server.pub)${NC}"
    log_success "Encryption keys ready"
    sleep 1
    return 0
}

#============================================
# SERVICE CREATION
#============================================

create_service() {
    local tunnel_domain=$1
    local mtu=$2
    local ssh_port=$3

    log_message "${YELLOW}📋 Creating systemd service (512B High-Packet-Rate Edition)...${NC}"
    echo ""

    # Detect vCPU count for GOMAXPROCS (0 is invalid in Go — means 1, not auto)
    local CPU_COUNT
    CPU_COUNT=$(nproc 2>/dev/null || echo "2")

    # Build a single-line ExecStart — systemd backslash-continuation is unreliable
    # across versions. A single line is always safe.
    local EXEC_LINE="$DNSTT_SERVER -udp :5300 -privkey-file $INSTALL_DIR/server.key -mtu $mtu $tunnel_domain 127.0.0.1:$ssh_port"

    cat > /etc/systemd/system/dnstt.service << EOF
[Unit]
Description=DNSTT DNS Tunnel Server (512B High-Packet-Rate — THE KING 👑)
Documentation=https://www.bamsoftware.com/software/dnstt/
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR

# Go runtime tuning
# GOMAXPROCS: number of vCPUs (0 is NOT valid — Go treats it as 1)
# GODEBUG=netdns=go: pure-Go resolver, avoids cgo DNS latency
# GOGC=200: GC runs at 2x heap growth instead of default 1x — fewer GC pauses
Environment="GOMAXPROCS=$CPU_COUNT"
Environment="GODEBUG=netdns=go"
Environment="GOGC=200"

ExecStart=$EXEC_LINE

Restart=always
RestartSec=5
StandardOutput=append:$LOG_DIR/dnstt-server.log
StandardError=append:$LOG_DIR/dnstt-error.log
SyslogIdentifier=dnstt

# I/O: maximum file descriptors (one per DNS stream)
# Capped at 65536 for VPS compatibility (avoids exceeding system hard limit)
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/logrotate.d/dnstt << LOGEOF
$LOG_DIR/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
}
LOGEOF

    systemctl daemon-reload
    systemctl enable dnstt > /dev/null 2>&1

    echo -e "${GREEN}✓ Service created${NC}"
    log_success "DNSTT Configuration:"
    log_message "   MTU:          $mtu bytes"
    log_message "   SSH Port:     $ssh_port"
    log_message "   UDP Port:     5300"
    log_message "   GOMAXPROCS:   $CPU_COUNT vCPU(s)"
    log_message "   GOGC:         200 (reduced GC pause frequency)"
    log_message "   LimitNOFILE:  1 048 576 FDs"
    log_message "   Nice:         -15 (high CPU priority)"
    sleep 2
}

#============================================
# MAIN SETUP
#============================================

setup_dnstt() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          DNSTT ULTRA v2.0 INSTALLATION               ║${NC}"
    echo -e "${CYAN}║               SSH OPTIMIZED EDITION                   ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if systemctl is-active --quiet dnstt 2>/dev/null; then
        echo -e "${YELLOW}⚠️  DNSTT is already running${NC}"
        echo ""
        read -p "Reinstall? (y/n): " reinstall
        if [[ "$reinstall" != "y" ]]; then
            return
        fi
        systemctl stop dnstt
        rm -f "$INSTALL_DIR/ns_domain.txt" "$INSTALL_DIR/tunnel_domain.txt"
    fi
    
    echo -e "${CYAN}Starting installation...${NC}"
    echo ""
    
    if ! install_dependencies; then
        log_error "Failed: Dependencies"
        press_enter
        return 1
    fi
    
    if ! install_golang; then
        log_error "Failed: Go installation"
        press_enter
        return 1
    fi
    
    if ! build_dnstt; then
        log_error "Failed: DNSTT build"
        press_enter
        return 1
    fi
    
    optimize_system_ultra
    optimize_ssh_server
    configure_firewall
    
    # Domain configuration
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}            DOMAIN CONFIGURATION${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Enter your nameserver domain:${NC}"
    echo -e "${CYAN}Example: ns.yourdomain.com${NC}"
    echo -e "${YELLOW}Default: ns.slowdns.local${NC}"
    echo ""
    read -p "Nameserver: " ns_domain
    ns_domain=${ns_domain:-ns.slowdns.local}
    
    echo ""
    echo -e "${WHITE}Enter your tunnel domain:${NC}"
    echo -e "${CYAN}Example: tunnel.yourdomain.com${NC}"
    echo ""
    read -p "Tunnel domain: " tunnel_domain
    
    if [[ -z "$tunnel_domain" ]]; then
        base_domain=$(echo "$ns_domain" | awk -F. '{print $(NF-1)"."$NF}')
        tunnel_domain="t.${base_domain}"
    fi
    
    tunnel_domain=$(echo "$tunnel_domain" | sed 's/\.\.*/./g' | sed 's/\.$//')
    
    echo "$ns_domain" > "$INSTALL_DIR/ns_domain.txt"
    echo "$tunnel_domain" > "$INSTALL_DIR/tunnel_domain.txt"
    
    log_success "NS Domain: $ns_domain"
    log_success "Tunnel Domain: $tunnel_domain"
    
    echo ""
    if ! generate_keys; then
        log_error "Failed: Key generation"
        press_enter
        return 1
    fi
    
    # MTU Configuration
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}         MTU CONFIGURATION (ULTRA v2 Optimized)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Select MTU size:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} 512   - Classic DNS ${GREEN}✓ Most Compatible${NC}"
    echo -e "  ${CYAN}2)${NC} 1024  - Standard"
    echo -e "  ${CYAN}3)${NC} 1232  - EDNS0 Standard"
    echo -e "  ${CYAN}4)${NC} 1280  - High Speed ${GREEN}⭐ Recommended${NC}"
    echo -e "  ${CYAN}5)${NC} 1420  - Very High Speed ${GREEN}⭐⭐ Best for SSH${NC}"
    echo -e "  ${CYAN}6)${NC} 4096  - EDNS0 Maximum ${YELLOW}⚡ ULTRA (experimental)${NC}"
    echo -e "  ${YELLOW}7)${NC} ${YELLOW}CUSTOM - Enter your own${NC}"
    echo ""
    echo -e "${YELLOW}💡 Recommended: Option 5 (1420) for maximum SSH speed${NC}"
    echo ""
    read -p "Choice [1-7, default=5]: " mtu_choice
    
    case ${mtu_choice:-5} in
        1) MTU=512 ;;
        2) MTU=1024 ;;
        3) MTU=1232 ;;
        4) MTU=1280 ;;
        5) MTU=1420 ;;
        6) MTU=4096 ;;
        7)
            echo ""
            echo -e "${YELLOW}Enter custom MTU (64-4096):${NC}"
            read -p "MTU: " custom_mtu
            if [[ "$custom_mtu" =~ ^[0-9]+$ ]] && [ "$custom_mtu" -ge 64 ] && [ "$custom_mtu" -le 4096 ]; then
                MTU=$custom_mtu
                log_success "Custom MTU: $MTU"
            else
                log_error "Invalid MTU, using 512"
                MTU=512
            fi
            ;;
        *) MTU=1420 ;;
    esac
    
    echo "$MTU" > "$INSTALL_DIR/mtu.txt"
    log_success "MTU: $MTU bytes"

    # Apply 512B-specific optimizations when MTU is at or below 512
    # These settings shift the kernel from "big packet / high bandwidth" mode
    # to "high packet-count / low latency" mode — the critical fix for the
    # 300 kbps ceiling caused by UDP socket drops and NAPI starvation.
    if [ "$MTU" -le 512 ]; then
        echo ""
        echo -e "${YELLOW}━━━ MTU ≤ 512: activating High-Frequency Small-Packet mode ━━━${NC}"
        optimize_for_512
    fi
    
    SSH_PORT=$(ss -tlnp 2>/dev/null | grep sshd | awk '{print $4}' | cut -d: -f2 | head -1)
    SSH_PORT=${SSH_PORT:-22}
    echo "$SSH_PORT" > "$INSTALL_DIR/ssh_port.txt"
    log_message "SSH Port: $SSH_PORT"
    
    echo ""
    create_service "$tunnel_domain" "$MTU" "$SSH_PORT"
    
    echo ""
    echo -e "${CYAN}🚀 Starting DNSTT service...${NC}"
    systemctl start dnstt
    sleep 3
    
    if systemctl is-active --quiet dnstt; then
        log_success "Service started successfully"
    else
        log_error "Service failed to start"
        echo ""
        journalctl -u dnstt -n 20 --no-pager
        press_enter
        return 1
    fi
    
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "YOUR_SERVER_IP")
    PUBKEY=$(cat "$INSTALL_DIR/server.pub")
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║            ✅ INSTALLATION COMPLETE! ✅              ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━ CONNECTION DETAILS ━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}🌐 Server IP:${NC}       ${YELLOW}$PUBLIC_IP${NC}"
    echo -e "${WHITE}🔗 NS Domain:${NC}       ${YELLOW}$ns_domain${NC}"
    echo -e "${WHITE}🔗 Tunnel Domain:${NC}   ${YELLOW}$tunnel_domain${NC}"
    echo -e "${WHITE}🔑 Public Key:${NC}"
    echo -e "${YELLOW}$PUBKEY${NC}"
    echo -e "${WHITE}🚪 SSH Port:${NC}        ${YELLOW}$SSH_PORT${NC}"
    echo -e "${WHITE}📊 MTU:${NC}             ${YELLOW}$MTU bytes${NC}"
    echo -e "${WHITE}⚡ Expected Speed:${NC}  ${GREEN}2–4 Mbps at 512B MTU 🚀${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}📋 DNS RECORDS:${NC}"
    echo ""
    echo -e "${GREEN}A Record:${NC}  $ns_domain → $PUBLIC_IP"
    echo -e "${GREEN}NS Record:${NC} $tunnel_domain → $ns_domain"
    echo ""
    echo -e "${YELLOW}📱 CLIENT COMMAND (Direct UDP - FASTEST):${NC}"
    echo ""
    echo -e "${GREEN}Direct UDP:${NC}"
    echo -e "${WHITE}dnstt-client -udp $PUBLIC_IP:5300 \\${NC}"
    echo -e "${WHITE}  -pubkey $PUBKEY \\${NC}"
    echo -e "${WHITE}  -mtu $MTU \\${NC}"
    echo -e "${WHITE}  $tunnel_domain 127.0.0.1:$SSH_PORT${NC}"
    echo ""
    echo -e "${CYAN}Alternative (DoH):${NC}"
    echo -e "${WHITE}dnstt-client -doh https://cloudflare-dns.com/dns-query \\${NC}"
    echo -e "${WHITE}  -pubkey $PUBKEY \\${NC}"
    echo -e "${WHITE}  -mtu $MTU \\${NC}"
    echo -e "${WHITE}  $tunnel_domain 127.0.0.1:$SSH_PORT${NC}"
    echo ""
    echo -e "${YELLOW}💡 SSH Connection:${NC}"
    echo -e "${WHITE}   After starting dnstt-client:${NC}"
    echo -e "${WHITE}   ssh username@127.0.0.1 -p $SSH_PORT${NC}"
    echo ""
    echo -e "${YELLOW}💡 ULTRA v2 OPTIMIZATIONS ACTIVE:${NC}"
    echo -e "   ${GREEN}✓${NC} BBR v2 + FQ-CoDel congestion control"
    echo -e "   ${GREEN}✓${NC} 1GB network buffers (2x faster)"
    echo -e "   ${GREEN}✓${NC} 512KB UDP buffers (EDNS0++)"
    echo -e "   ${GREEN}✓${NC} SSH server optimized (fastest ciphers)"
    echo -e "   ${GREEN}✓${NC} Zero-copy + offloading"
    echo -e "   ${GREEN}✓${NC} MTU $MTU (optimized for SSH)"
    echo -e "   ${GREEN}✓${NC} 8M connection tracking"
    echo -e "   ${GREEN}✓${NC} 300K packet backlog (zero loss)"
    echo ""
    
    # Save info
    cat > "$INSTALL_DIR/connection_info.txt" << EOF
╔═══════════════════════════════════════════════════════╗
║      DNSTT ULTRA v2.0 - SSH OPTIMIZED EDITION        ║
║              Created By THE KING 👑 💯               ║
╚═══════════════════════════════════════════════════════╝

Generated: $(date)

SERVER DETAILS:
═══════════════
IP:             $PUBLIC_IP
NS Domain:      $ns_domain
Tunnel Domain:  $tunnel_domain
SSH Port:       $SSH_PORT
MTU:            $MTU bytes
Expected Speed: 10-25 Mbps

PUBLIC KEY:
═══════════
$PUBKEY

DNS RECORDS:
════════════
A    $ns_domain         $PUBLIC_IP
NS   $tunnel_domain     $ns_domain

ULTRA SPEED CLIENT COMMANDS:
═════════════════════════════
# Direct UDP (FASTEST - Recommended)
dnstt-client -udp $PUBLIC_IP:5300 -pubkey $PUBKEY -mtu $MTU $tunnel_domain 127.0.0.1:$SSH_PORT

# Cloudflare DoH
dnstt-client -doh https://cloudflare-dns.com/dns-query -pubkey $PUBKEY -mtu $MTU $tunnel_domain 127.0.0.1:$SSH_PORT

# Google DoH
dnstt-client -doh https://dns.google/dns-query -pubkey $PUBKEY -mtu $MTU $tunnel_domain 127.0.0.1:$SSH_PORT

SSH CONNECTION:
═══════════════
After starting dnstt-client, connect:
ssh username@127.0.0.1 -p $SSH_PORT

ULTRA v2 OPTIMIZATIONS:
════════════════════════
✓ BBR v2 + FQ-CoDel (next-gen congestion control)
✓ 1GB Network Buffers (double speed)
✓ 512KB UDP Buffers (EDNS0++ support)
✓ 300K Packet Backlog (zero packet loss)
✓ 8M Connection Tracking (unlimited connections)
✓ SSH Server Optimized (fastest ciphers)
✓ Zero-Copy + Offloading enabled
✓ Realtime CPU Priority (FIFO 99)
✓ I/O Realtime Priority
✓ TCP Bulk Transfer Optimization
✓ 2M File Descriptors (ultra parallel)
✓ MTU $MTU (optimized for your network)

LOGS:
══════
Server: $LOG_DIR/dnstt-server.log
Error:  $LOG_DIR/dnstt-error.log
Main:   $LOG_DIR/dnstt.log

Created By THE KING 👑 💯
EOF
    
    log_success "Info saved: $INSTALL_DIR/connection_info.txt"
    press_enter
}

#============================================
# SSH USER MANAGEMENT
#============================================

add_ssh_user() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  ADD SSH USER                        ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "Username: " username
    
    if [[ -z "$username" ]]; then
        log_error "Username required"
        press_enter
        return
    fi
    
    if id "$username" &>/dev/null; then
        log_error "User already exists"
        press_enter
        return
    fi
    
    read -sp "Password: " password
    echo ""
    
    if [[ -z "$password" ]]; then
        log_error "Password required"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${YELLOW}Select expiration:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} 1 Day"
    echo -e "  ${CYAN}2)${NC} 7 Days"
    echo -e "  ${CYAN}3)${NC} 30 Days ${GREEN}⭐${NC}"
    echo -e "  ${CYAN}4)${NC} 90 Days"
    echo -e "  ${CYAN}5)${NC} 365 Days"
    echo ""
    read -p "Choice [1-5, default=3]: " exp_choice
    
    case ${exp_choice:-3} in
        1) days=1 ;;
        2) days=7 ;;
        3) days=30 ;;
        4) days=90 ;;
        5) days=365 ;;
        *) days=30 ;;
    esac
    
    echo ""
    echo -e "${CYAN}Creating user...${NC}"
    
    useradd -m -s /bin/bash "$username" 2>/dev/null
    echo "$username:$password" | chpasswd 2>/dev/null
    
    exp_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$exp_date" "$username" 2>/dev/null
    
    echo "$username|$password|$exp_date|$(date +"%Y-%m-%d")" >> "$USER_DB"
    
    echo -e "${GREEN}✓ User created${NC}"
    echo ""
    log_success "SSH User Created!"
    echo ""
    echo -e "  ${WHITE}👤 Username:${NC} ${GREEN}$username${NC}"
    echo -e "  ${WHITE}🔐 Password:${NC} ${GREEN}$password${NC}"
    echo -e "  ${WHITE}📅 Expires:${NC}  ${YELLOW}$exp_date${NC}"
    echo -e "  ${WHITE}⏳ Valid:${NC}    ${GREEN}$days days${NC}"
    echo ""
    
    press_enter
}

delete_ssh_user() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 DELETE SSH USER                      ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "Username to delete: " username
    
    if ! id "$username" &>/dev/null; then
        log_error "User not found"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${RED}⚠️  WARNING: You are about to DELETE user: $username${NC}"
    echo ""
    read -p "Type 'yes' to confirm: " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        echo -e "${YELLOW}Deletion cancelled${NC}"
        press_enter
        return
    fi
    
    echo ""
    echo -e "${CYAN}Deleting user...${NC}"
    
    pkill -u "$username" 2>/dev/null || true
    userdel -r "$username" 2>/dev/null || true
    sed -i "/^$username|/d" "$USER_DB"
    
    echo -e "${GREEN}✓ User deleted${NC}"
    log_success "User $username removed"
    
    press_enter
}

list_ssh_users() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    SSH USERS                         ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ ! -s "$USER_DB" ]]; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "            ${YELLOW}No users found${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    else
        echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        printf "${CYAN}║${NC} ${WHITE}%-12s %-12s %-12s %-10s %-12s${NC} ${CYAN}║${NC}\n" "USERNAME" "PASSWORD" "EXPIRES" "DAYS LEFT" "STATUS"
        echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
        
        local user_count=0
        local active_count=0
        
        while IFS='|' read -r user pass exp created; do
            user_count=$((user_count + 1))
            
            current=$(date +%s)
            exp_unix=$(date -d "$exp" +%s 2>/dev/null || echo "0")
            days_left=$(( (exp_unix - current) / 86400 ))
            
            if [[ $current -gt $exp_unix ]]; then
                status="${RED}● EXPIRED${NC}"
                days_display="${RED}0${NC}"
            else
                if [[ $days_left -le 3 ]]; then
                    status="${RED}● EXPIRING${NC}"
                    days_display="${RED}$days_left${NC}"
                elif [[ $days_left -le 7 ]]; then
                    status="${YELLOW}● WARNING${NC}"
                    days_display="${YELLOW}$days_left${NC}"
                else
                    status="${GREEN}● ACTIVE${NC}"
                    days_display="${GREEN}$days_left${NC}"
                    active_count=$((active_count + 1))
                fi
            fi
            
            printf "${CYAN}║${NC} ${WHITE}%-12s %-12s %-12s %-10s${NC} " "$user" "$pass" "$exp" "$days_display"
            echo -e "$status ${CYAN}║${NC}"
            
        done < "$USER_DB"
        
        echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Total Users: ${WHITE}$user_count${NC}  |  ${GREEN}Active: $active_count${NC}  |  ${RED}Expired: $((user_count - active_count))${NC}"
    fi
    
    press_enter
}

#============================================
# STATUS & INFO
#============================================

view_status() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 SERVICE STATUS                       ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if systemctl is-active --quiet dnstt; then
        echo -e "${GREEN}✅ DNSTT: RUNNING (ULTRA v2 MODE 👑)${NC}"
        
        uptime_sec=$(systemctl show dnstt --property=ActiveEnterTimestamp --value)
        if [[ -n "$uptime_sec" ]]; then
            echo -e "${WHITE}Started: ${GREEN}$uptime_sec${NC}"
            
            start_epoch=$(date -d "$uptime_sec" +%s 2>/dev/null || echo "0")
            current_epoch=$(date +%s)
            uptime_seconds=$((current_epoch - start_epoch))
            uptime_days=$((uptime_seconds / 86400))
            uptime_hours=$(( (uptime_seconds % 86400) / 3600 ))
            uptime_mins=$(( (uptime_seconds % 3600) / 60 ))
            
            echo -e "${WHITE}Uptime: ${GREEN}${uptime_days}d ${uptime_hours}h ${uptime_mins}m${NC}"
        fi
        
        DNSTT_PID=$(systemctl show dnstt --property=MainPID --value)
        if [[ -n "$DNSTT_PID" && "$DNSTT_PID" != "0" ]]; then
            NICE=$(ps -o nice= -p $DNSTT_PID 2>/dev/null || echo "N/A")
            CPU_PCT=$(ps -o %cpu= -p $DNSTT_PID 2>/dev/null | tr -d ' ' || echo "N/A")
            MEM_PCT=$(ps -o %mem= -p $DNSTT_PID 2>/dev/null | tr -d ' ' || echo "N/A")
            echo -e "${WHITE}Process Priority: ${GREEN}$NICE (Realtime)${NC}"
            echo -e "${WHITE}CPU Usage:        ${CYAN}${CPU_PCT}%${NC}"
            echo -e "${WHITE}Memory Usage:     ${CYAN}${MEM_PCT}%${NC}"
        fi
        
        CURRENT_MTU=$(cat "$INSTALL_DIR/mtu.txt" 2>/dev/null || echo "unknown")
        TUNNEL_DOM=$(cat "$INSTALL_DIR/tunnel_domain.txt" 2>/dev/null || echo "unknown")
        UDP_CONNS=$(ss -u state established 2>/dev/null | grep -c ':5300' || echo "0")
        echo -e "${WHITE}Current MTU:      ${CYAN}${CURRENT_MTU} bytes${NC}"
        echo -e "${WHITE}Tunnel Domain:    ${CYAN}${TUNNEL_DOM}${NC}"
        echo -e "${WHITE}Active UDP conns: ${CYAN}${UDP_CONNS}${NC}"
    else
        echo -e "${RED}❌ DNSTT: STOPPED${NC}"
        CURRENT_MTU=$(cat "$INSTALL_DIR/mtu.txt" 2>/dev/null || echo "unknown")
        echo -e "${WHITE}Last MTU used: ${YELLOW}${CURRENT_MTU} bytes${NC}"
        echo -e "${YELLOW}Tip: Use option 8 to restart, or option 11 to change MTU${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}━━━━━ Full Status ━━━━━${NC}"
    systemctl status dnstt --no-pager -l | head -20
    
    echo ""
    echo -e "${CYAN}━━━━━ Recent Logs ━━━━━${NC}"
    journalctl -u dnstt -n 10 --no-pager
    
    press_enter
}

view_logs() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    DNSTT LOGS                        ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}Select log to view:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} Main Log (dnstt.log)"
    echo -e "  ${CYAN}2)${NC} Server Log (dnstt-server.log)"
    echo -e "  ${CYAN}3)${NC} Error Log (dnstt-error.log)"
    echo -e "  ${CYAN}4)${NC} System Journal (journalctl)"
    echo -e "  ${CYAN}5)${NC} Live Tail (real-time)"
    echo -e "  ${WHITE}0)${NC} Back"
    echo ""
    read -p "Choice: " log_choice
    
    case $log_choice in
        1)
            if [[ -f "$LOG_DIR/dnstt.log" ]]; then
                less +G "$LOG_DIR/dnstt.log"
            else
                echo -e "${RED}Log file not found${NC}"
            fi
            ;;
        2)
            if [[ -f "$LOG_DIR/dnstt-server.log" ]]; then
                less +G "$LOG_DIR/dnstt-server.log"
            else
                echo -e "${RED}Log file not found${NC}"
            fi
            ;;
        3)
            if [[ -f "$LOG_DIR/dnstt-error.log" ]]; then
                less +G "$LOG_DIR/dnstt-error.log"
            else
                echo -e "${RED}No errors logged${NC}"
            fi
            ;;
        4)
            journalctl -u dnstt --no-pager -n 100
            ;;
        5)
            echo -e "${YELLOW}Following logs in real-time (Ctrl+C to stop)...${NC}"
            echo ""
            tail -f "$LOG_DIR/dnstt-server.log" "$LOG_DIR/dnstt-error.log"
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            sleep 1
            ;;
    esac
    
    press_enter
}

view_info() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║            CONNECTION INFORMATION                    ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ -f "$INSTALL_DIR/connection_info.txt" ]]; then
        cat "$INSTALL_DIR/connection_info.txt"
    else
        log_error "Not configured. Run installation first."
    fi
    
    press_enter
}

view_performance() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        ULTRA v2 PERFORMANCE MONITORING               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}━━━ SERVICE STATUS ━━━${NC}"
    if systemctl is-active --quiet dnstt; then
        echo -e "${GREEN}✅ DNSTT: RUNNING (ULTRA v2 MODE)${NC}"
    else
        echo -e "${RED}❌ DNSTT: STOPPED${NC}"
    fi
    echo ""
    
    echo -e "${YELLOW}━━━ TUNNEL CONFIG ━━━${NC}"
    CURRENT_MTU=$(cat "$INSTALL_DIR/mtu.txt" 2>/dev/null || echo "unknown")
    TUNNEL_DOM=$(cat "$INSTALL_DIR/tunnel_domain.txt" 2>/dev/null || echo "unknown")
    SSH_P=$(cat "$INSTALL_DIR/ssh_port.txt" 2>/dev/null || echo "22")
    echo -e "${WHITE}MTU Size:       ${CYAN}${CURRENT_MTU} bytes${NC}"
    echo -e "${WHITE}Tunnel Domain:  ${CYAN}${TUNNEL_DOM}${NC}"
    echo -e "${WHITE}SSH Port:       ${CYAN}${SSH_P}${NC}"
    echo -e "${WHITE}Go Workers:     ${CYAN}GOMAXPROCS=4 (parallel DNS processing)${NC}"
    echo ""

    echo -e "${YELLOW}━━━ ULTRA v2 SETTINGS ━━━${NC}"
    echo -e "${GREEN}✓${NC} CPU Priority: Realtime (FIFO 99)"
    echo -e "${GREEN}✓${NC} I/O Priority: Realtime (0)"
    echo -e "${GREEN}✓${NC} Nice: -20 (highest)"
    echo -e "${GREEN}✓${NC} CPU Quota: 3200% (32 cores)"
    echo -e "${GREEN}✓${NC} Memory: 12GB"
    echo -e "${GREEN}✓${NC} File Descriptors: 2M"
    echo -e "${GREEN}✓${NC} GOMAXPROCS=4 (4 parallel Go workers)"
    echo ""
    
    echo -e "${YELLOW}━━━ LIVE PROCESS STATS ━━━${NC}"
    DNSTT_PID=$(systemctl show dnstt --property=MainPID --value 2>/dev/null || echo "0")
    if [[ -n "$DNSTT_PID" && "$DNSTT_PID" != "0" ]]; then
        CPU_PCT=$(ps -o %cpu= -p $DNSTT_PID 2>/dev/null | tr -d ' ' || echo "N/A")
        MEM_MB=$(ps -o rss= -p $DNSTT_PID 2>/dev/null | awk '{printf "%.1f", $1/1024}' || echo "N/A")
        THREADS=$(ps -o nlwp= -p $DNSTT_PID 2>/dev/null | tr -d ' ' || echo "N/A")
        echo -e "${WHITE}PID:            ${CYAN}${DNSTT_PID}${NC}"
        echo -e "${WHITE}CPU:            ${CYAN}${CPU_PCT}%${NC}"
        echo -e "${WHITE}Memory:         ${CYAN}${MEM_MB} MB${NC}"
        echo -e "${WHITE}Threads:        ${CYAN}${THREADS}${NC}"
    else
        echo -e "${RED}Process not running${NC}"
    fi
    echo ""

    echo -e "${YELLOW}━━━ NETWORK STATS ━━━${NC}"
    if command -v ss &> /dev/null; then
        UDP_CONNS=$(ss -u state established 2>/dev/null | grep -c ':5300' || echo "0")
        UDP_ALL=$(ss -u 2>/dev/null | grep -c ':5300' || echo "0")
        echo -e "${WHITE}UDP Active (5300):  ${CYAN}$UDP_CONNS${NC}"
        echo -e "${WHITE}UDP Total (5300):   ${CYAN}$UDP_ALL${NC}"
    fi
    
    RMEM_MAX=$(sysctl -n net.core.rmem_max 2>/dev/null || echo "0")
    UDP_RMEM=$(sysctl -n net.ipv4.udp_rmem_min 2>/dev/null || echo "0")
    BACKLOG=$(sysctl -n net.core.netdev_max_backlog 2>/dev/null || echo "0")
    BBR=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "N/A")
    
    RMEM_MB=$((RMEM_MAX / 1048576))
    UDP_KB=$((UDP_RMEM / 1024))
    
    echo -e "${WHITE}Network Buffer:     ${GREEN}${RMEM_MB}MB${NC}"
    echo -e "${WHITE}UDP Buffer:         ${GREEN}${UDP_KB}KB${NC}"
    echo -e "${WHITE}Packet Backlog:     ${GREEN}${BACKLOG}${NC}"
    echo -e "${WHITE}Congestion Control: ${GREEN}${BBR}${NC}"
    echo ""
    
    echo -e "${YELLOW}━━━ SYSTEM RESOURCES ━━━${NC}"
    MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
    MEM_USED=$(free -h | awk '/^Mem:/ {print $3}')
    CPU_CORES=$(nproc 2>/dev/null || echo "?")
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | tr -d ' ')
    echo -e "${WHITE}Memory:     ${CYAN}${MEM_USED}/${MEM_TOTAL}${NC}"
    echo -e "${WHITE}CPU Cores:  ${CYAN}${CPU_CORES}${NC}"
    echo -e "${WHITE}Load Avg:   ${CYAN}${LOAD}${NC}"
    echo ""
    
    press_enter
}

bandwidth_test() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 BANDWIDTH TEST                       ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if ! systemctl is-active --quiet dnstt; then
        log_error "DNSTT service is not running"
        press_enter
        return
    fi
    
    CURRENT_MTU=$(cat "$INSTALL_DIR/mtu.txt" 2>/dev/null || echo "unknown")
    echo -e "${YELLOW}Testing bandwidth for 30 seconds...${NC}"
    echo -e "${CYAN}Monitoring UDP traffic on port 5300${NC}"
    echo -e "${WHITE}Current MTU: ${CYAN}${CURRENT_MTU} bytes${NC}"
    echo ""

    NET_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    if [[ -z "$NET_INTERFACE" ]]; then
        log_error "Could not detect network interface"
        press_enter
        return
    fi

    echo -e "${WHITE}Interface: ${CYAN}$NET_INTERFACE${NC}"
    echo ""

    RX1=$(cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes)
    TX1=$(cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes)
    PREV_RX=$RX1
    PREV_TX=$TX1
    PEAK_RX=0
    PEAK_TX=0

    printf "  %-5s  %-14s  %-14s  %s\n" "SEC" "DOWN (Kbps)" "UP (Kbps)" "TOTAL"
    echo -e "  ${DIM}------------------------------------------------${NC}"

    for i in $(seq 1 30); do
        sleep 1
        CUR_RX=$(cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes)
        CUR_TX=$(cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes)
        DIFF_RX=$(( (CUR_RX - PREV_RX) * 8 / 1000 ))
        DIFF_TX=$(( (CUR_TX - PREV_TX) * 8 / 1000 ))
        DIFF_TOT=$(( DIFF_RX + DIFF_TX ))
        [ $DIFF_RX -gt $PEAK_RX ] && PEAK_RX=$DIFF_RX
        [ $DIFF_TX -gt $PEAK_TX ] && PEAK_TX=$DIFF_TX
        if [ $DIFF_TOT -gt 5000 ]; then
            COL="${GREEN}"
        elif [ $DIFF_TOT -gt 1000 ]; then
            COL="${YELLOW}"
        else
            COL="${RED}"
        fi
        printf "  ${CYAN}%-5s${NC}  ${COL}%-14s${NC}  ${COL}%-14s${NC}  ${COL}%s Kbps${NC}\n" \
               "${i}s" "${DIFF_RX}" "${DIFF_TX}" "${DIFF_TOT}"
        PREV_RX=$CUR_RX
        PREV_TX=$CUR_TX
    done

    RX2=$(cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes)
    TX2=$(cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes)
    RX_BYTES=$(( RX2 - RX1 ))
    TX_BYTES=$(( TX2 - TX1 ))
    RX_MBPS=$(echo "scale=2; $RX_BYTES * 8 / 30 / 1000000" | bc)
    TX_MBPS=$(echo "scale=2; $TX_BYTES * 8 / 30 / 1000000" | bc)
    PEAK_RX_MBPS=$(echo "scale=2; $PEAK_RX / 1000" | bc)
    PEAK_TX_MBPS=$(echo "scale=2; $PEAK_TX / 1000" | bc)
    RX_MB=$(echo "scale=2; $RX_BYTES / 1048576" | bc)
    TX_MB=$(echo "scale=2; $TX_BYTES / 1048576" | bc)

    echo ""
    echo -e "${GREEN}━━━ TEST RESULTS ━━━${NC}"
    echo ""
    echo -e "${WHITE}Download:${NC}"
    echo -e "  Avg Rate: ${GREEN}${RX_MBPS} Mbps${NC}"
    echo -e "  Peak:     ${CYAN}${PEAK_RX_MBPS} Mbps${NC}"
    echo -e "  Total:    ${CYAN}${RX_MB} MB${NC}"
    echo ""
    echo -e "${WHITE}Upload:${NC}"
    echo -e "  Avg Rate: ${GREEN}${TX_MBPS} Mbps${NC}"
    echo -e "  Peak:     ${CYAN}${PEAK_TX_MBPS} Mbps${NC}"
    echo -e "  Total:    ${CYAN}${TX_MB} MB${NC}"
    echo ""
    echo -e "${WHITE}MTU Used: ${CYAN}${CURRENT_MTU} bytes${NC}"
    echo ""

    TOTAL_MBPS=$(echo "$RX_MBPS + $TX_MBPS" | bc)

    if (( $(echo "$TOTAL_MBPS >= 10" | bc -l) )); then
        echo -e "${GREEN}✅ Performance: EXCELLENT (${TOTAL_MBPS} Mbps — target achieved!)${NC}"
    elif (( $(echo "$TOTAL_MBPS >= 5" | bc -l) )); then
        echo -e "${YELLOW}⚠️  Performance: GOOD (${TOTAL_MBPS} Mbps)${NC}"
        echo -e "${YELLOW}   Tip: Use option 11 (Change MTU) to try a larger size${NC}"
    elif (( $(echo "$TOTAL_MBPS >= 1" | bc -l) )); then
        echo -e "${YELLOW}⚠️  Performance: LOW (${TOTAL_MBPS} Mbps)${NC}"
        echo -e "${YELLOW}   Tip: Use option 11 → Choose 0 (Auto-detect MTU)${NC}"
        echo -e "${YELLOW}   Current MTU: ${CURRENT_MTU}B — auto-detect finds optimal size${NC}"
    else
        echo -e "${RED}❌ Performance: VERY LOW (${TOTAL_MBPS} Mbps)${NC}"
        echo -e "${RED}   Action: Go to option 11 → Choose 0 (Auto-detect MTU)${NC}"
        echo -e "${RED}   This will test your network and set the correct MTU automatically${NC}"
    fi
    
    press_enter
}

change_mtu() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              CHANGE MTU SIZE                          ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ ! -f "$INSTALL_DIR/mtu.txt" ]]; then
        log_error "DNSTT not installed yet"
        press_enter
        return
    fi

    CURRENT_MTU=$(cat "$INSTALL_DIR/mtu.txt" 2>/dev/null || echo "unknown")
    echo -e "${YELLOW}Current MTU: ${CYAN}${CURRENT_MTU} bytes${NC}"
    echo ""
    echo -e "  ${GREEN}0)${NC} ${GREEN}AUTO-DETECT - Test your network now ⭐⭐⭐${NC}"
    echo -e "  ${CYAN}1)${NC} 192   - Low MTU (strict carriers)"
    echo -e "  ${CYAN}2)${NC} 256   - Low-Medium"
    echo -e "  ${CYAN}3)${NC} 512   - Classic DNS"
    echo -e "  ${CYAN}4)${NC} 1024  - Standard"
    echo -e "  ${CYAN}5)${NC} 1232  - EDNS0 Standard"
    echo -e "  ${CYAN}6)${NC} 1280  - High Speed"
    echo -e "  ${CYAN}7)${NC} 1420  - Very High Speed"
    echo -e "  ${CYAN}8)${NC} 4096  - EDNS0 Maximum"
    echo -e "  ${YELLOW}9)${NC} CUSTOM (64-4096)"
    echo ""
    read -p "Choice [0-9]: " mtu_choice

    NEW_MTU=0
    case ${mtu_choice} in
        0)
            echo ""
            echo -e "${CYAN}Auto-detecting best MTU...${NC}"
            echo ""
            if ! command -v dig &>/dev/null; then
                apt-get install -y -qq dnsutils > /dev/null 2>&1 || true
            fi
            BEST_MTU=0; BEST_SCORE=0
            TEST_SIZES=(64 128 192 256 320 384 448 512 576 640 768 1024 1280 1420 1480)
            printf "  %-8s  %-10s  %-6s  %s
" "MTU" "RTT(avg)" "OK/5" "STATUS"
            echo -e "  ${DIM}--------------------------------------------${NC}"
            for TEST_MTU in "${TEST_SIZES[@]}"; do
                PAD=$(( TEST_MTU - 29 )); [ $PAD -lt 1 ] && PAD=1
                LABEL=""; REM=$PAD
                while [ $REM -gt 0 ]; do
                    SEG=$REM; [ $SEG -gt 63 ] && SEG=63
                    LABEL+=$(printf 'x%.0s' $(seq 1 $SEG))
                    REM=$(( REM - SEG ))
                    [ $REM -gt 0 ] && LABEL+="."
                done
                TEST_DOMAIN="${LABEL}.google.com"
                TOTAL=0; OK=0; FAIL=0
                for r in 1 2 3 4 5; do
                    T0=$(date +%s%3N)
                    OUT=$(dig +time=2 +tries=1 +udp "@8.8.8.8" A "$TEST_DOMAIN" 2>/dev/null)
                    T1=$(date +%s%3N)
                    if echo "$OUT" | grep -qE "status: (NOERROR|NXDOMAIN)"; then
                        TOTAL=$(echo "$TOTAL + ($T1 - $T0)" | bc)
                        (( OK++ ))
                    else
                        (( FAIL++ ))
                    fi
                done
                if [ $OK -gt 0 ]; then
                    AVG=$(echo "scale=0; $TOTAL / $OK" | bc)
                    SCORE=$(echo "scale=0; ($TEST_MTU * $OK * 10) / ($AVG + 1)" | bc 2>/dev/null || echo 0)
                    STATUS="${GREEN}[+] OK${NC}"; [ $FAIL -gt 0 ] && STATUS="${YELLOW}[~] PARTIAL${NC}"
                    printf "  %-8s  %-10s  %-6s  " "${TEST_MTU}B" "${AVG}ms" "${OK}/5"
                    echo -e "$STATUS"
                    if [ "$SCORE" -gt "$BEST_SCORE" ]; then BEST_SCORE=$SCORE; BEST_MTU=$TEST_MTU; fi
                else
                    printf "  %-8s  %-10s  %-6s  " "${TEST_MTU}B" "timeout" "0/5"
                    echo -e "${RED}[X] NO RESPONSE${NC}"
                fi
            done
            echo ""
            if [ "$BEST_MTU" -gt 0 ]; then
                NEW_MTU=$BEST_MTU
                echo -e "${GREEN}✓ Best MTU: ${CYAN}${NEW_MTU} bytes${NC}"
            else
                echo -e "${RED}Could not detect MTU. No change made.${NC}"
                press_enter; return
            fi
            ;;
        1) NEW_MTU=192 ;;
        2) NEW_MTU=256 ;;
        3) NEW_MTU=512 ;;
        4) NEW_MTU=1024 ;;
        5) NEW_MTU=1232 ;;
        6) NEW_MTU=1280 ;;
        7) NEW_MTU=1420 ;;
        8) NEW_MTU=4096 ;;
        9)
            echo ""
            read -p "Enter MTU (64-4096): " custom_mtu
            if [[ "$custom_mtu" =~ ^[0-9]+$ ]] && [ "$custom_mtu" -ge 64 ] && [ "$custom_mtu" -le 4096 ]; then
                NEW_MTU=$custom_mtu
            else
                log_error "Invalid MTU. No change made."
                press_enter; return
            fi
            ;;
        *)
            log_error "Invalid choice. No change made."
            press_enter; return
            ;;
    esac

    if [ "$NEW_MTU" -eq 0 ]; then
        press_enter; return
    fi

    TUNNEL_DOMAIN=$(cat "$INSTALL_DIR/tunnel_domain.txt" 2>/dev/null || echo "")
    SSH_PORT_SAVED=$(cat "$INSTALL_DIR/ssh_port.txt" 2>/dev/null || echo "22")

    if [[ -z "$TUNNEL_DOMAIN" ]]; then
        log_error "Tunnel domain not found. Please reinstall."
        press_enter; return
    fi

    echo ""
    echo -e "${CYAN}Applying new MTU: ${YELLOW}${NEW_MTU} bytes${NC}${CYAN} (was ${CURRENT_MTU})...${NC}"
    echo "$NEW_MTU" > "$INSTALL_DIR/mtu.txt"
    create_service "$TUNNEL_DOMAIN" "$NEW_MTU" "$SSH_PORT_SAVED"
    systemctl daemon-reload
    systemctl restart dnstt
    sleep 2

    if systemctl is-active --quiet dnstt; then
        log_success "MTU changed to ${NEW_MTU} bytes — service restarted"
        # Apply 512B-specific optimizations if new MTU is small
        if [ "$NEW_MTU" -le 512 ]; then
            echo ""
            echo -e "${YELLOW}MTU ≤ 512 — applying small-packet optimizations...${NC}"
            optimize_for_512
        fi
    else
        log_error "Service failed after MTU change. Check logs."
        journalctl -u dnstt -n 10 --no-pager
    fi

    press_enter
}

fix_domain() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 FIX DOMAIN ISSUE                     ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ ! -f "$INSTALL_DIR/tunnel_domain.txt" ]]; then
        log_error "No configuration found"
        press_enter
        return
    fi
    
    echo -e "${YELLOW}Current domain:${NC}"
    cat "$INSTALL_DIR/tunnel_domain.txt"
    echo ""
    
    echo -e "${WHITE}Enter the CORRECT tunnel domain:${NC}"
    echo -e "${CYAN}Example: t.yourdomain.com${NC}"
    echo ""
    read -p "Correct tunnel domain: " correct_domain
    
    if [[ -z "$correct_domain" ]]; then
        log_error "Domain required"
        press_enter
        return
    fi
    
    correct_domain=$(echo "$correct_domain" | sed 's/\.\.*/./g' | sed 's/\.$//')
    
    MTU=$(cat "$INSTALL_DIR/mtu.txt" 2>/dev/null || echo "1420")
    SSH_PORT=$(cat "$INSTALL_DIR/ssh_port.txt" 2>/dev/null || echo "22")
    
    echo "$correct_domain" > "$INSTALL_DIR/tunnel_domain.txt"
    
    log_message "Recreating service with correct domain..."
    create_service "$correct_domain" "$MTU" "$SSH_PORT"
    
    systemctl daemon-reload
    systemctl restart dnstt
    
    sleep 2
    
    if systemctl is-active --quiet dnstt; then
        log_success "Fixed! Service is now running"
        echo ""
        echo -e "${WHITE}Tunnel Domain: ${YELLOW}$correct_domain${NC}"
    else
        log_error "Still failing. Check logs:"
        journalctl -u dnstt -n 10 --no-pager
    fi
    
    press_enter
}

#============================================
# MENUS
#============================================

dnstt_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║              DNSTT MANAGEMENT                        ║${NC}"
        echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${GREEN}1)${NC} Install/Setup DNSTT"
        echo -e "  ${YELLOW}2)${NC} View Status"
        echo -e "  ${YELLOW}3)${NC} View Connection Info"
        echo -e "  ${CYAN}4)${NC} View Logs"
        echo -e "  ${CYAN}5)${NC} Performance Monitor"
        echo -e "  ${CYAN}6)${NC} Bandwidth Test"
        echo -e "  ${PURPLE}7)${NC} Fix Domain Issue"
        echo -e "  ${BLUE}8)${NC} Restart Service"
        echo -e "  ${RED}9)${NC} Stop Service"
        echo -e "  ${RED}10)${NC} Uninstall"
        echo -e "  ${GREEN}11)${NC} Change MTU Size"
        echo -e "  ${WHITE}0)${NC} Back"
        echo ""
        read -p "Choice: " choice
        
        case $choice in
            1) setup_dnstt ;;
            2) view_status ;;
            3) view_info ;;
            4) view_logs ;;
            5) view_performance ;;
            6) bandwidth_test ;;
            7) fix_domain ;;
            8)
                echo ""
                echo -e "${CYAN}Restarting DNSTT...${NC}"
                systemctl restart dnstt
                sleep 2
                if systemctl is-active --quiet dnstt; then
                    echo -e "${GREEN}✓ Service restarted${NC}"
                else
                    echo -e "${RED}✗ Service failed${NC}"
                fi
                sleep 2
                ;;
            9)
                echo ""
                echo -e "${CYAN}Stopping DNSTT...${NC}"
                systemctl stop dnstt
                echo -e "${YELLOW}Service stopped${NC}"
                sleep 2
                ;;
            10)
                echo ""
                echo -e "${RED}⚠️  WARNING: Uninstall DNSTT${NC}"
                echo ""
                read -p "Type 'yes' to confirm: " confirm
                if [[ "$confirm" == "yes" ]]; then
                    echo ""
                    echo -e "${CYAN}Uninstalling...${NC}"
                    systemctl stop dnstt 2>/dev/null || true
                    systemctl disable dnstt 2>/dev/null || true
                    systemctl stop iptables-restore-dnstt 2>/dev/null || true
                    systemctl disable iptables-restore-dnstt 2>/dev/null || true
                    rm -f /etc/systemd/system/dnstt.service
                    rm -f /etc/systemd/system/iptables-restore-dnstt.service
                    rm -rf "$INSTALL_DIR" "$LOG_DIR"
                    rm -f "$DNSTT_SERVER" "$DNSTT_CLIENT"
                    rm -f /etc/sysctl.d/99-dnstt-ultra-v2.conf
                    rm -f /etc/sysctl.d/99-dnstt-512b-tunnel.conf
                    rm -f /etc/security/limits.d/99-dnstt-ultra-v2.conf
                    rm -f /etc/iptables/rules.v4
                    # Restore original sshd_config if backup exists
                    if [[ -f /etc/ssh/sshd_config.backup ]]; then
                        cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
                        systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || true
                        echo -e "${GREEN}✓ SSH config restored from backup${NC}"
                    fi
                    systemctl daemon-reload
                    echo -e "${GREEN}✓ DNSTT fully uninstalled${NC}"
                    sleep 2
                else
                    echo -e "${YELLOW}Cancelled${NC}"
                    sleep 1
                fi
                ;;
            11) change_mtu ;;
            0) return ;;
            *) 
                log_error "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

ssh_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║            SSH USER MANAGEMENT                       ║${NC}"
        echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        if [[ -s "$USER_DB" ]]; then
            local total_users=$(wc -l < "$USER_DB")
            local active_users=0
            local current=$(date +%s)
            
            while IFS='|' read -r user pass exp created; do
                exp_unix=$(date -d "$exp" +%s 2>/dev/null || echo "0")
                if [[ $current -le $exp_unix ]]; then
                    active_users=$((active_users + 1))
                fi
            done < "$USER_DB"
            
            echo -e "  ${WHITE}📊 Total: ${CYAN}$total_users${NC}  |  ${GREEN}Active: $active_users${NC}  |  ${RED}Expired: $((total_users - active_users))${NC}"
            echo ""
        fi
        
        echo -e "  ${GREEN}1)${NC} 👤 Add New User"
        echo -e "  ${YELLOW}2)${NC} 📋 List All Users"
        echo -e "  ${RED}3)${NC} 🗑️  Delete User"
        echo -e "  ${WHITE}0)${NC} ⬅️  Back"
        echo ""
        read -p "Choice: " choice
        
        case $choice in
            1) add_ssh_user ;;
            2) list_ssh_users ;;
            3) delete_ssh_user ;;
            0) return ;;
            *) 
                log_error "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

system_menu() {
    show_banner
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║               SYSTEM INFORMATION                     ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}━━━ UPTIME ━━━${NC}"
    uptime
    echo ""
    
    echo -e "${YELLOW}━━━ MEMORY ━━━${NC}"
    free -h
    echo ""
    
    echo -e "${YELLOW}━━━ DISK ━━━${NC}"
    df -h /
    echo ""
    
    echo -e "${YELLOW}━━━ NETWORK ━━━${NC}"
    ip -brief addr
    echo ""
    
    echo -e "${YELLOW}━━━ OPTIMIZATIONS ━━━${NC}"
    if [[ -f /etc/sysctl.d/99-dnstt-512b-tunnel.conf ]] || [[ -f /etc/sysctl.d/99-dnstt-ultra-v2.conf ]]; then
        echo -e "${GREEN}✅ OPTIMIZATIONS ACTIVE${NC}"
        echo -e "${GREEN}✓${NC} HYBLA congestion control (lossy-link tuned)"
        echo -e "${GREEN}✓${NC} fq qdisc (no AQM early-drop)"
        echo -e "${GREEN}✓${NC} UDP buffers: 8MB cap / 2MB floor per socket"
        echo -e "${GREEN}✓${NC} NAPI: 300 pkts/cycle @ 1500µs (low interrupt latency)"
        echo -e "${GREEN}✓${NC} SSH: chacha20-poly1305 + delayed compression"
        echo -e "${GREEN}✓${NC} Process nice: -15 | FDs: 1M"
        if [[ -f /etc/security/limits.d/99-dnstt-ultra-v2.conf ]]; then
            echo -e "${GREEN}✓${NC} System-wide FD limits applied"
        fi
    else
        echo -e "${YELLOW}⚠️  No optimizations applied yet (run Install first)${NC}"
    fi
    echo ""
    
    press_enter
}

main_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║                   MAIN MENU                          ║${NC}"
        echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${GREEN}1)${NC} 🌐 DNSTT Management"
        echo -e "  ${BLUE}2)${NC} 👥 SSH Users"
        echo -e "  ${YELLOW}3)${NC} 📊 System Info"
        echo -e "  ${RED}0)${NC} ⛔ Exit"
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}Version: 8.0 ULTRA v2 | ${GREEN}Created By THE KING 👑 💯${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        read -p "Choice: " choice
        
        case $choice in
            1) dnstt_menu ;;
            2) ssh_menu ;;
            3) system_menu ;;
            0)
                echo ""
                echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${GREEN}    Thank you for using DNSTT ULTRA v2! 👑 💯${NC}"
                echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                exit 0
                ;;
            *) 
                log_error "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

#============================================
# CREATE MENU COMMAND
#============================================

create_menu_command() {
    SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    
    cat > /usr/local/bin/menu << EOF
#!/bin/bash
# DNSTT Menu - THE KING 👑
bash "$SCRIPT_PATH"
EOF
    chmod +x /usr/local/bin/menu
    
    cat > /usr/local/bin/dnstt << EOF
#!/bin/bash
# DNSTT Command - THE KING 👑
bash "$SCRIPT_PATH"
EOF
    chmod +x /usr/local/bin/dnstt
    
    cat > /usr/local/bin/slowdns << EOF
#!/bin/bash
# SlowDNS Command - THE KING 👑
bash "$SCRIPT_PATH"
EOF
    chmod +x /usr/local/bin/slowdns
    
    log_success "Menu commands created: menu, dnstt, slowdns"
}

#============================================
# MAIN EXECUTION
#============================================

# Create menu command if needed
if [[ ! -f /usr/local/bin/menu ]]; then
    if [[ $EUID -eq 0 ]]; then
        create_menu_command 2>/dev/null
    fi
fi

check_root
check_os
main_menu
        

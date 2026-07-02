#!/bin/bash

##############################################################
#   ██████╗ ██╗      █████╗  ██████╗██╗  ██╗               #
#   ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝               #
#   ██████╔╝██║     ███████║██║     █████╔╝                 #
#   ██╔══██╗██║     ██╔══██║██║     ██╔═██╗                 #
#   ██████╔╝███████╗██║  ██║╚██████╗██║  ██╗               #
#   ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝               #
#                                                            #
#   SSH TUNNEL MANAGER v9.1 — ULTRA DIAMOND EDITION         #
#   Created By BLACK KILLER                                  #
#   WhatsApp: +255658785522                                  #
#   FIXED: SSH PORT 22 PROTECTION v1.0                       #
##############################################################

# Do NOT use set -e (sysctl/modprobe may return non-zero)
set -o pipefail 2>/dev/null || true

#============================================================
# COLORS
#============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BCYAN='\033[1;36m'

#============================================================
# PATHS & VERSION
#============================================================
INSTALL_DIR="/etc/dnstt"
SSH_DIR="/etc/slowdns"
USER_DB="$SSH_DIR/users.txt"
USAGE_DIR="$SSH_DIR/usage"
BACKUP_DIR="$SSH_DIR/backups"
LIMITER_DIR="$SSH_DIR/limiter"
BANNER_FILE="/etc/ssh/slowdns_banner"
LOG_DIR="/var/log/dnstt"
DNSTT_SERVER="/usr/local/bin/dnstt-server"
DNSTT_CLIENT="/usr/local/bin/dnstt-client"
SCRIPT_VERSION="9.1.0"
GITHUB_RAW="https://raw.githubusercontent.com/cyberhinju-blip/slowdns-manager/main/slowdns_script.sh"
GITHUB_VER="https://raw.githubusercontent.com/cyberhinju-blip/slowdns-manager/main/version.txt"

mkdir -p "$INSTALL_DIR" "$SSH_DIR" "$LOG_DIR" "$USAGE_DIR" "$BACKUP_DIR" "$LIMITER_DIR"
touch "$USER_DB"

#============================================================
# UI HELPERS
#============================================================

# Diamond-style title header (blue bg, bold white)
dtitle() {
    echo -e "\E[44;1;37m  $1  \E[0m"
}

# Diamond separator line
dsep() {
    echo -e "${BRED}◇────────────────────────────────────────────────────────◇${NC}"
}

# Short diamond separator
dsep_s() {
    echo -e "${BRED}◇──────────────────────────────────────◇${NC}"
}

# Diamond box top/bottom
dbox_top() { echo -e "${BRED}⋘════════════════════════════════════════════════���═════⋙${NC}"; }
dbox_bot() { echo -e "${BRED}⋘══════════════════════════════════════════════════════⋙${NC}"; }

press_enter() {
    echo ""
    echo -e "${BRED}  ►► PRESS ENTER TO CONTINUE ◄◄${NC}"
    read -r
}

#============================================================
# FUN_BAR — PROGRESS ANIMATION
#============================================================
fun_bar() {
    local cmd="$1"
    local label="${2:-PLEASE WAIT...}"
    local _done_flag="/tmp/fun_bar_${$}_${RANDOM}"
    (
        bash -c "$cmd" >/dev/null 2>&1
        touch "$_done_flag"
    ) &
    local bg_pid=$!
    tput civis 2>/dev/null
    echo -ne "  ${BYELLOW}◇ ${label} ${WHITE}- ${BYELLOW}[${NC}"
    while true; do
        for ((i=0; i<18; i++)); do
            echo -ne "${BRED}#${NC}"
            sleep 0.1
        done
        if [[ -e "$_done_flag" ]]; then
            rm -f "$_done_flag"
            break
        fi
        echo -e "${BYELLOW}]${NC}"
        sleep 0.5
        tput cuu1 2>/dev/null
        tput dl1 2>/dev/null
        echo -ne "  ${BYELLOW}◇ ${label} ${WHITE}- ${BYELLOW}[${NC}"
    done
    echo -e "${BYELLOW}]${WHITE} -${BGREEN} OK!${NC}"
    tput cnorm 2>/dev/null
    wait $bg_pid 2>/dev/null
}

#============================================================
# BANNER
#============================================================
show_banner() {
    clear
    echo -e "${BRED}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
║                                                               ║
║  ██████╗ ██╗      █████╗  ██████╗██╗  ██╗                    ║
║  ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝                    ║
║  ██████╔╝██║     ███████║██║     █████╔╝                     ║
║  ██╔══██╗██║     ██╔══██║██║     ██╔═██╗                     ║
║  ██████╔╝███████╗██║  ██║╚██████╗██║  ██╗                    ║
║  ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝                    ║
║                                                               ║
║  ██╗  ██╗██╗██╗     ██╗     ███████╗██████╗                  ║
║  ██║ ██╔╝██║██║     ██║     ██╔════╝██╔══██╗                 ║
║  █████╔╝ ██║██║     ██║     █████╗  ██████╔╝                 ║
║  ██╔═██╗ ██║██║     ██║     ██╔══╝  ██╔══██╗                 ║
║  ██║  ██╗██║███████╗███████╗███████╗██║  ██║                 ║
║  ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝                 ║
║                                                               ║
║  ╔═══════════════════════════════════════════════════════╗   ║
║  ║   ☠  SSH TUNNEL MANAGER v9.1 ULTRA DIAMOND  ☠       ║   ║
║  ║   ☠  SSH PORT 22 PROTECTION ENABLED ☠               ║   ║
║  ║       ▸▸ CREATED BY BLACK KILLER ◂◂                  ║   ║
║  ║       📱 WhatsApp: +255658785522                     ║   ║
║  ╚═══════════════════════════════════════════════════════╝   ║
║                                                               ║
║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

#============================================================
# SYSTEM CHECKS
#============================================================
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: THIS SCRIPT MUST BE RUN AS ROOT${NC}"
        echo -e "${YELLOW}PLEASE RUN: sudo bash $0${NC}"
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/debian_version ]] && [[ ! -f /etc/redhat-release ]]; then
        echo -e "${RED}ERROR: SUPPORTS DEBIAN/UBUNTU/CENTOS ONLY${NC}"
        exit 1
    fi
}

check_bash_version() {
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        echo -e "${RED}ERROR: BASH 4.0+ REQUIRED (CURRENT: ${BASH_VERSION})${NC}"
        echo -e "${YELLOW}PLEASE UPGRADE BASH: apt-get install -y bash${NC}"
        exit 1
    fi
}

#============================================================
# LOGGING
#============================================================
log_message() {
    local msg="$1"
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $msg"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$LOG_DIR/dnstt.log" 2>/dev/null
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $1" >> "$LOG_DIR/dnstt.log" 2>/dev/null
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[SUCCESS] $1" >> "$LOG_DIR/dnstt.log" 2>/dev/null
}

#============================================================
# SYSTEM OPTIMIZATIONS (ULTRA v2)
#============================================================
optimize_system_ultra() {
    log_message "${YELLOW}⚡ APPLYING ULTRA SPEED v2.0 OPTIMIZATION...${NC}"
    echo ""

    sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || true
    modprobe tcp_bbr 2>/dev/null || true
    modprobe tcp_hybla 2>/dev/null || true
    ulimit -n 2097152 2>/dev/null || ulimit -n 1048576 2>/dev/null || true

    echo -e "${CYAN}[1/12]${NC} CONFIGURING BBR v2..."
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1 || true
    sysctl -w net.core.default_qdisc=fq_codel >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ BBR v2 + FQ-CODEL ENABLED${NC}"; sleep 0.3

    echo -e "${CYAN}[2/12]${NC} MAXIMUM NETWORK BUFFERS (1GB)..."
    sysctl -w net.core.rmem_max=1073741824 >/dev/null 2>&1 || true
    sysctl -w net.core.wmem_max=1073741824 >/dev/null 2>&1 || true
    sysctl -w net.core.rmem_default=134217728 >/dev/null 2>&1 || true
    sysctl -w net.core.wmem_default=134217728 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_rmem="16384 1048576 1073741824" >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_wmem="16384 1048576 1073741824" >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ NETWORK BUFFERS: 1GB CONFIGURED${NC}"; sleep 0.3

    echo -e "${CYAN}[3/12]${NC} UDP OPTIMIZATION (512KB)..."
    sysctl -w net.ipv4.udp_rmem_min=524288 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.udp_wmem_min=524288 >/dev/null 2>&1 || true
    sysctl -w net.core.netdev_max_backlog=300000 >/dev/null 2>&1 || true
    sysctl -w net.core.somaxconn=262144 >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ UDP: 512KB BUFFERS + 300K BACKLOG${NC}"; sleep 0.3

    echo -e "${CYAN}[4/12]${NC} SSH-SPECIFIC OPTIMIZATIONS..."
    sysctl -w net.ipv4.tcp_window_scaling=1 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_notsent_lowat=131072 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_retries1=3 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_retries2=5 >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ SSH BULK TRANSFER OPTIMIZATIONS${NC}"; sleep 0.3

    echo -e "${CYAN}[5/12]${NC} CONNECTION TRACKING (8M)..."
    modprobe nf_conntrack 2>/dev/null || true
    sysctl -w net.netfilter.nf_conntrack_max=8000000 >/dev/null 2>&1 || \
        sysctl -w net.nf_conntrack_max=8000000 >/dev/null 2>&1 || true
    sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=432000 >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ CONNECTION TRACKING: 8M${NC}"; sleep 0.3

    echo -e "${CYAN}[6/12]${NC} ADVANCED TCP OPTIMIZATIONS..."
    sysctl -w net.ipv4.tcp_fastopen=3 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_tw_reuse=1 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_fin_timeout=5 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_max_syn_backlog=262144 >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ TCP FASTOPEN + ADVANCED TUNING${NC}"; sleep 0.3

    echo -e "${CYAN}[7/12]${NC} TCP KEEPALIVE FOR STABLE TUNNELS..."
    sysctl -w net.ipv4.tcp_keepalive_time=60 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_keepalive_probes=5 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_keepalive_intvl=10 >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ KEEPALIVE: 60S INTERVALS${NC}"; sleep 0.3

    echo -e "${CYAN}[8/12]${NC} ZERO-COPY AND OFFLOADING..."
    sysctl -w net.ipv4.tcp_sack=1 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_timestamps=1 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_mtu_probing=1 >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ ZERO-COPY + OFFLOADING ENABLED${NC}"; sleep 0.3

    echo -e "${CYAN}[9/12]${NC} PORT RANGE EXPANSION..."
    sysctl -w net.ipv4.ip_local_port_range="1024 65535" >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ PORT RANGE: 1024-65535${NC}"; sleep 0.3

    echo -e "${CYAN}[10/12]${NC} DNS TUNNEL SPECIFIC..."
    sysctl -w net.ipv4.udp_early_demux=1 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.ip_early_demux=1 >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ DNS TUNNEL OPTIMIZATIONS${NC}"; sleep 0.3

    echo -e "${CYAN}[11/12]${NC} MEMORY AND QUEUE..."
    sysctl -w net.core.optmem_max=134217728 >/dev/null 2>&1 || true
    sysctl -w vm.min_free_kbytes=65536 >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ MEMORY: 128MB SOCKET BUFFERS${NC}"; sleep 0.3

    echo -e "${CYAN}[12/12]${NC} SAVING PERMANENT CONFIGURATION..."
    cat > /etc/sysctl.d/99-dnstt-ultra-v2.conf << 'EOF'
net.ipv4.ip_forward = 1
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq_codel
net.core.rmem_max = 1073741824
net.core.wmem_max = 1073741824
net.core.rmem_default = 134217728
net.core.wmem_default = 134217728
net.ipv4.tcp_rmem = 16384 1048576 1073741824
net.ipv4.tcp_wmem = 16384 1048576 1073741824
net.ipv4.udp_rmem_min = 524288
net.ipv4.udp_wmem_min = 524288
net.core.netdev_max_backlog = 300000
net.core.somaxconn = 262144
net.netfilter.nf_conntrack_max = 8000000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_sack = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.ip_local_port_range = 1024 65535
vm.min_free_kbytes = 65536
EOF

    cat > /etc/security/limits.d/99-dnstt-ultra.conf << 'EOF'
* soft nofile 2097152
* hard nofile 2097152
root soft nofile 2097152
root hard nofile 2097152
EOF
    echo -e "${GREEN}✓ CONFIG SAVED${NC}"; sleep 0.3

    echo ""
    dsep
    echo -e "${BGREEN}⚡ ULTRA SPEED v2.0 ACTIVATED ⚡${NC}"
    dsep
    echo -e "  ${GREEN}✓${NC} BBR v2 + FQ-CODEL"
    echo -e "  ${GREEN}✓${NC} 1GB NETWORK BUFFERS"
    echo -e "  ${GREEN}✓${NC} 512KB UDP BUFFERS"
    echo -e "  ${GREEN}✓${NC} 8M CONNECTION TRACKING"
    echo -e "  ${YELLOW}EXPECTED SPEED: 10-25 Mbps 🚀${NC}"
    sleep 2
}

#============================================================
# 512B SMALL-PACKET OPTIMIZATION
#============================================================
optimize_for_512() {
    log_message "${YELLOW}⚡ APPLYING 512B HIGH-FREQUENCY OPTIMIZATION...${NC}"
    echo ""
    sysctl -w net.core.rmem_max=8388608 >/dev/null 2>&1 || true
    sysctl -w net.core.wmem_max=8388608 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.udp_rmem_min=2097152 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.udp_wmem_min=2097152 >/dev/null 2>&1 || true
    sysctl -w net.core.netdev_budget=300 >/dev/null 2>&1 || true
    sysctl -w net.core.netdev_budget_usecs=1500 >/dev/null 2>&1 || true
    sysctl -w net.core.netdev_max_backlog=100000 >/dev/null 2>&1 || true
    modprobe tcp_hybla 2>/dev/null || true
    sysctl -w net.ipv4.tcp_congestion_control=hybla >/dev/null 2>&1 || true
    sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1 || true
    ip link set lo mtu 65536 2>/dev/null || true
    ulimit -n 1048576 2>/dev/null || true
    log_success "512B SMALL-PACKET MODE ACTIVE"
    sleep 1
}

#============================================================
# SSH SERVER OPTIMIZATION
#============================================================
optimize_ssh_server() {
    log_message "${YELLOW}🔧 OPTIMIZING SSH SERVER...${NC}"
    local sshd_cfg="/etc/ssh/sshd_config"

    if [[ ! -f "${sshd_cfg}.backup" ]]; then
        cp "$sshd_cfg" "${sshd_cfg}.backup"
    fi

    local ciphers="chacha20-poly1305@openssh.com,aes128-gcm@openssh.com,aes256-gcm@openssh.com"
    local macs="hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com"
    local kex="curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512"

    sed -i '/^Ciphers /d; /^MACs /d; /^KexAlgorithms /d; /^Compression /d; /^IPQoS /d' "$sshd_cfg"
    cat >> "$sshd_cfg" << EOF

# BLACK KILLER SSH OPTIMIZATION v9.1
Ciphers $ciphers
MACs $macs
KexAlgorithms $kex
Compression delayed
IPQoS lowdelay throughput
EOF

    systemctl reload sshd 2>/dev/null || service ssh reload 2>/dev/null || true
    log_success "SSH SERVER OPTIMIZED"
    sleep 1
}

#============================================================
# INSTALL DEPENDENCIES
#============================================================
install_dependencies() {
    log_message "${YELLOW}📦 INSTALLING DEPENDENCIES...${NC}"
    echo ""

    if [[ -f /etc/debian_version ]]; then
        fun_bar "apt-get update -y" "UPDATING PACKAGE LIST"
        fun_bar "apt-get install -y wget curl git gcc make iptables \
            ca-certificates dnsutils iproute2 net-tools sysstat htop bc \
            openssh-server screen lsof" "INSTALLING PACKAGES"
        apt-get install -y iptables-persistent 2>/dev/null || \
            apt-get install -y netfilter-persistent 2>/dev/null || true
        systemctl enable ssh 2>/dev/null || systemctl enable sshd 2>/dev/null || true
        systemctl start ssh 2>/dev/null || systemctl start sshd 2>/dev/null || true
    elif [[ -f /etc/redhat-release ]]; then
        fun_bar "yum install -y wget curl git gcc make iptables iptables-services \
            ca-certificates bind-utils iproute net-tools sysstat htop bc openssh-server screen lsof" "INSTALLING PACKAGES"
        systemctl enable sshd 2>/dev/null && systemctl start sshd 2>/dev/null || true
    fi

    log_success "DEPENDENCIES INSTALLED"
    sleep 1
}

#============================================================
# INSTALL GO
#============================================================
install_golang() {
    if command -v go &>/dev/null; then
        GO_VER=$(go version | awk '{print $3}' | sed 's/go//')
        GO_MAJOR=$(echo "$GO_VER" | cut -d. -f1)
        GO_MINOR=$(echo "$GO_VER" | cut -d. -f2)
        if [[ "$GO_MAJOR" -gt 1 ]] || { [[ "$GO_MAJOR" -eq 1 ]] && [[ "$GO_MINOR" -ge 21 ]]; }; then
            log_success "Go $GO_VER ALREADY INSTALLED — SKIPPING"
            return 0
        fi
    fi

    log_message "${YELLOW}📦 INSTALLING GO 1.22.4...${NC}"
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  GO_ARCH="amd64" ;;
        aarch64) GO_ARCH="arm64" ;;
        armv7l)  GO_ARCH="armv6l" ;;
        *)       GO_ARCH="amd64" ;;
    esac

    GO_VER="1.22.4"
    GO_TB="go${GO_VER}.linux-${GO_ARCH}.tar.gz"
    cd /tmp || return 1

    fun_bar "wget -q https://go.dev/dl/${GO_TB} -O ${GO_TB}" "DOWNLOADING GO ${GO_VER}"
    fun_bar "tar -C /usr/local -xzf ${GO_TB} && rm -f ${GO_TB}" "EXTRACTING GO"

    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=/root/go
    export GOCACHE=/root/.cache/go-build

    cat > /etc/profile.d/golang.sh << 'EOF'
export PATH=$PATH:/usr/local/go/bin
export GOPATH=/root/go
export GOCACHE=/root/.cache/go-build
EOF
    chmod +x /etc/profile.d/golang.sh

    if ! command -v go &>/dev/null; then
        log_error "GO INSTALLATION FAILED"
        return 1
    fi
    log_success "Go $(go version | awk '{print $3}') INSTALLED"
    sleep 1
}

#============================================================
# BUILD DNSTT
#============================================================
build_dnstt() {
    log_message "${YELLOW}🔨 BUILDING DNSTT FROM SOURCE...${NC}"
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=/root/go
    export GOCACHE=/root/.cache/go-build
    export GO111MODULE=on

    if ! command -v go &>/dev/null; then
        log_error "GO NOT FOUND. INSTALL GO FIRST."
        return 1
    fi

    cd /tmp || return 1
    rm -rf dnstt-src

    echo -e "${CYAN}CLONING DNSTT REPOSITORY...${NC}"
    if git clone https://www.bamsoftware.com/git/dnstt.git dnstt-src 2>&1; then
        echo -e "${GREEN}✓ CLONED FROM BAMSOFTWARE.COM${NC}"
    elif git clone https://github.com/ekoops/dnstt.git dnstt-src 2>&1; then
        echo -e "${YELLOW}⚠ USED GITHUB MIRROR${NC}"
    else
        log_error "COULD NOT CLONE DNSTT REPOSITORY"
        return 1
    fi

    echo -e "${CYAN}BUILDING DNSTT-SERVER...${NC}"
    cd /tmp/dnstt-src/dnstt-server || return 1
    if ! go build -o "$DNSTT_SERVER" . 2>&1; then
        log_error "DNSTT-SERVER BUILD FAILED"
        cd /tmp && rm -rf dnstt-src
        return 1
    fi
    chmod +x "$DNSTT_SERVER"

    echo -e "${CYAN}BUILDING DNSTT-CLIENT...${NC}"
    cd /tmp/dnstt-src/dnstt-client || return 1
    if ! go build -o "$DNSTT_CLIENT" . 2>&1; then
        log_error "DNSTT-CLIENT BUILD FAILED"
        cd /tmp && rm -rf dnstt-src
        return 1
    fi
    chmod +x "$DNSTT_CLIENT"
    cd /tmp && rm -rf dnstt-src
    log_success "DNSTT BUILD COMPLETE"
    sleep 1
    return 0
}

#============================================================
# FIREWALL CONFIGURATION - FIXED SSH PORT 22 PROTECTION
#============================================================
configure_firewall() {
    log_message "${YELLOW}🔥 CONFIGURING FIREWALL (SSH PORT 22 PROTECTED)...${NC}"

    NET_IF=$(ip route show default 2>/dev/null | awk '{print $5}' | head -1)
    NET_IF=${NET_IF:-eth0}

    if command -v ufw &>/dev/null; then
        ufw --force disable 2>/dev/null || true
        systemctl stop ufw 2>/dev/null || true
    fi

    if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
        systemctl stop systemd-resolved 2>/dev/null || true
        systemctl disable systemd-resolved 2>/dev/null || true
        rm -f /etc/resolv.conf
        printf 'nameserver 1.1.1.1\nnameserver 8.8.8.8\n' > /etc/resolv.conf
        chattr +i /etc/resolv.conf 2>/dev/null || true
    fi

    echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null || true
    sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || true

    modprobe nf_conntrack 2>/dev/null || true
    iptables -F INPUT 2>/dev/null || true
    iptables -F OUTPUT 2>/dev/null || true
    iptables -F FORWARD 2>/dev/null || true
    iptables -t nat -F 2>/dev/null || true
    iptables -t mangle -F 2>/dev/null || true
    iptables -X 2>/dev/null || true

    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    
    # ★★★ FIXED: SSH PORT 22 EXPLICITLY ALLOWED AT PRIORITY 1 ★★★
    echo -e "${YELLOW}⚠ CONFIGURING SSH PORT PROTECTION...${NC}"
    iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
    echo -e "${GREEN}✓ SSH PORT 22 EXPLICITLY ALLOWED (PRIORITY 1)${NC}"
    
    iptables -I INPUT 2 -p udp --dport 5300 -j ACCEPT
    iptables -I INPUT 3 -p udp --dport 53 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -t nat -I PREROUTING 1 -p udp --dport 53 -j REDIRECT --to-ports 5300
    iptables -t nat -A POSTROUTING -o "$NET_IF" -j MASQUERADE
    iptables -A FORWARD -i lo -j ACCEPT
    iptables -A FORWARD -o lo -j ACCEPT
    iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A FORWARD -o "$NET_IF" -j ACCEPT
    iptables -A FORWARD -i "$NET_IF" -j ACCEPT

    # ★★★ IPv6 RULES FOR SSH PORT 22 ★★★
    if command -v ip6tables &>/dev/null; then
        echo -e "${YELLOW}⚠ CONFIGURING IPv6 SSH PORT PROTECTION...${NC}"
        ip6tables -I INPUT 1 -p tcp --dport 22 -j ACCEPT 2>/dev/null || true
        echo -e "${GREEN}✓ IPv6 SSH PORT 22 ALLOWED${NC}"
        ip6tables -I INPUT 2 -p udp --dport 5300 -j ACCEPT 2>/dev/null || true
        ip6tables -I INPUT 3 -p udp --dport 53 -j ACCEPT 2>/dev/null || true
        ip6tables -t nat -I PREROUTING 1 -p udp --dport 53 -j REDIRECT --to-ports 5300 2>/dev/null || true
    fi

    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || true

    log_success "FIREWALL CONFIGURED"
    echo -e "  ${GREEN}✓${NC} TCP PORT 22 (SSH) - PRIORITY 1 - FULLY PROTECTED"
    echo -e "  ${GREEN}✓${NC} UDP PORTS 53/5300 (DNS/DNSTT) OPEN"
    echo -e "  ${GREEN}✓${NC} TCP PORTS 80/443 (HTTP/HTTPS) OPEN"
    echo -e "  ${GREEN}✓${NC} NAT MASQUERADE ON ${NET_IF}"
    sleep 1
}

#============================================================
# KEY GENERATION
#============================================================
generate_keys() {
    log_message "${YELLOW}🔑 GENERATING DNSTT ENCRYPTION KEYS...${NC}"

    if [[ ! -x "$DNSTT_SERVER" ]]; then
        log_error "DNSTT-SERVER NOT FOUND. BUILD FIRST."
        return 1
    fi

    cd "$INSTALL_DIR" || return 1
    rm -f server.key server.pub

    if ! "$DNSTT_SERVER" -gen-key -privkey-file server.key -pubkey-file server.pub; then
        log_error "KEY GENERATION FAILED"
        return 1
    fi

    if [[ ! -s "server.key" ]] || [[ ! -s "server.pub" ]]; then
        log_error "KEY FILES MISSING OR EMPTY"
        return 1
    fi

    chmod 600 server.key
    chmod 644 server.pub
    echo -e "${GREEN}✓ KEYS GENERATED${NC}"
    echo -e "${WHITE}  PUBLIC KEY: ${CYAN}$(cat server.pub)${NC}"
    log_success "ENCRYPTION KEYS READY"
    sleep 1
    return 0
}

#============================================================
# SERVICE CREATION
#============================================================
create_service() {
    local tunnel_domain=$1
    local mtu=$2
    local ssh_port=$3
    local CPU_COUNT
    CPU_COUNT=$(nproc 2>/dev/null || echo "2")
    local EXEC_LINE="$DNSTT_SERVER -udp :5300 -privkey-file $INSTALL_DIR/server.key -mtu $mtu $tunnel_domain 127.0.0.1:$ssh_port"

    cat > /etc/systemd/system/dnstt.service << EOF
[Unit]
Description=DNSTT DNS TUNNEL SERVER v9.1 — BLACK KILLER
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
Environment="GOMAXPROCS=$CPU_COUNT"
Environment="GODEBUG=netdns=go"
Environment="GOGC=200"
ExecStart=$EXEC_LINE
Restart=always
RestartSec=5
StandardOutput=append:$LOG_DIR/dnstt-server.log
StandardError=append:$LOG_DIR/dnstt-error.log
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/logrotate.d/dnstt << EOF
$LOG_DIR/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
}
EOF

    systemctl daemon-reload
    systemctl enable dnstt >/dev/null 2>&1
    log_success "SERVICE CREATED"
    sleep 1
}

#============================================================
# MAIN DNSTT SETUP
#============================================================
setup_dnstt() {
    show_banner
    dtitle "⚡ DNSTT ULTRA v2.0 INSTALLATION — BLACK KILLER ⚡"
    dsep
    echo ""

    if systemctl is-active --quiet dnstt 2>/dev/null; then
        echo -e "${YELLOW}⚠ DNSTT IS ALREADY RUNNING${NC}"
        echo ""
        read -rp "REINSTALL? [y/n]: " reinstall
        [[ "$reinstall" != "y" ]] && return
        systemctl stop dnstt
        rm -f "$INSTALL_DIR/ns_domain.txt" "$INSTALL_DIR/tunnel_domain.txt"
    fi

    install_dependencies || { log_error "DEPENDENCIES FAILED"; press_enter; return 1; }
    install_golang       || { log_error "GO INSTALLATION FAILED"; press_enter; return 1; }
    build_dnstt          || { log_error "DNSTT BUILD FAILED"; press_enter; return 1; }

    optimize_system_ultra
    optimize_ssh_server
    configure_firewall

    echo ""
    dtitle "DOMAIN CONFIGURATION"
    dsep
    echo ""
    echo -e "${WHITE}ENTER YOUR NAMESERVER DOMAIN:${NC}"
    echo -e "${CYAN}EXAMPLE: ns.yourdomain.com${NC}"
    echo -e "${YELLOW}DEFAULT: ns.slowdns.local${NC}"
    echo ""
    read -rp "NAMESERVER: " ns_domain
    ns_domain=${ns_domain:-ns.slowdns.local}

    echo ""
    echo -e "${WHITE}ENTER YOUR TUNNEL DOMAIN:${NC}"
    echo -e "${CYAN}EXAMPLE: tunnel.yourdomain.com${NC}"
    echo ""
    read -rp "TUNNEL DOMAIN: " tunnel_domain

    if [[ -z "$tunnel_domain" ]]; then
        local dot_count
        dot_count=$(echo "$ns_domain" | tr -cd '.' | wc -c)
        if [[ "$dot_count" -ge 1 ]]; then
            base_domain=$(echo "$ns_domain" | awk -F. '{print $(NF-1)"."$NF}')
        else
            base_domain="$ns_domain"
        fi
        tunnel_domain="t.${base_domain}"
    fi

    tunnel_domain=$(echo "$tunnel_domain" | sed 's/\.\.*/./g; s/\.$//')
    echo "$ns_domain" > "$INSTALL_DIR/ns_domain.txt"
    echo "$tunnel_domain" > "$INSTALL_DIR/tunnel_domain.txt"

    log_success "NS DOMAIN: $ns_domain"
    log_success "TUNNEL DOMAIN: $tunnel_domain"

    generate_keys || { log_error "KEY GENERATION FAILED"; press_enter; return 1; }

    echo ""
    dtitle "MTU CONFIGURATION"
    dsep
    echo ""
    echo -e "  ${CYAN}1)${NC} 512   — CLASSIC DNS ${GREEN}✓ MOST COMPATIBLE${NC}"
    echo -e "  ${CYAN}2)${NC} 1024  — STANDARD"
    echo -e "  ${CYAN}3)${NC} 1232  — EDNS0 STANDARD"
    echo -e "  ${CYAN}4)${NC} 1280  — HIGH SPEED ${GREEN}⭐${NC}"
    echo -e "  ${CYAN}5)${NC} 1420  — VERY HIGH SPEED ${GREEN}⭐⭐ BEST FOR SSH${NC}"
    echo -e "  ${CYAN}6)${NC} 4096  — EDNS0 MAXIMUM ${YELLOW}⚡ ULTRA${NC}"
    echo -e "  ${YELLOW}7)${NC} CUSTOM"
    echo ""
    echo -e "${YELLOW}RECOMMENDED: OPTION 5 (1420) FOR MAXIMUM SSH SPEED${NC}"
    echo ""
    read -rp "CHOICE [1-7, default=5]: " mtu_choice

    case ${mtu_choice:-5} in
        1) MTU=512 ;;
        2) MTU=1024 ;;
        3) MTU=1232 ;;
        4) MTU=1280 ;;
        5) MTU=1420 ;;
        6) MTU=4096 ;;
        7)
            read -rp "ENTER CUSTOM MTU (64-4096): " custom_mtu
            if [[ "$custom_mtu" =~ ^[0-9]+$ ]] && [ "$custom_mtu" -ge 64 ] && [ "$custom_mtu" -le 4096 ]; then
                MTU=$custom_mtu
            else
                log_error "INVALID MTU, USING 512"
                MTU=512
            fi
            ;;
        *) MTU=1420 ;;
    esac

    echo "$MTU" > "$INSTALL_DIR/mtu.txt"
    log_success "MTU: $MTU BYTES"

    [[ "$MTU" -le 512 ]] && optimize_for_512

    # Detect SSH port: try sshd_config first, then ss, default 22
    SSH_PORT=$(grep -E "^Port " /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | head -1)
    if [[ -z "$SSH_PORT" || ! "$SSH_PORT" =~ ^[0-9]+$ ]]; then
        SSH_PORT=$(ss -tlnp 2>/dev/null | awk '/sshd/{print $4}' | grep -oP '(?<=:)[0-9]+$' | head -1)
    fi
    [[ -z "$SSH_PORT" || ! "$SSH_PORT" =~ ^[0-9]+$ ]] && SSH_PORT=22
    echo "$SSH_PORT" > "$INSTALL_DIR/ssh_port.txt"

    create_service "$tunnel_domain" "$MTU" "$SSH_PORT"

    echo ""
    echo -e "${CYAN}🚀 STARTING DNSTT SERVICE...${NC}"
    systemctl start dnstt
    sleep 3

    if ! systemctl is-active --quiet dnstt; then
        log_error "SERVICE FAILED TO START"
        journalctl -u dnstt -n 20 --no-pager
        press_enter
        return 1
    fi

    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "YOUR_SERVER_IP")
    PUBKEY=$(cat "$INSTALL_DIR/server.pub")

    echo ""
    dbox_top
    echo -e "${BGREEN}             ✅ INSTALLATION COMPLETE! ✅${NC}"
    dbox_bot
    echo ""
    dsep
    echo -e "  ${WHITE}🌐 SERVER IP     :${NC} ${YELLOW}$PUBLIC_IP${NC}"
    echo -e "  ${WHITE}🔗 NS DOMAIN     :${NC} ${YELLOW}$ns_domain${NC}"
    echo -e "  ${WHITE}🔗 TUNNEL DOMAIN :${NC} ${YELLOW}$tunnel_domain${NC}"
    echo -e "  ${WHITE}🔑 PUBLIC KEY    :${NC}"
    echo -e "     ${CYAN}$PUBKEY${NC}"
    echo -e "  ${WHITE}🚪 SSH PORT      :${NC} ${YELLOW}$SSH_PORT${NC}"
    echo -e "  ${WHITE}📊 MTU           :${NC} ${YELLOW}$MTU BYTES${NC}"
    dsep
    echo ""
    echo -e "${YELLOW}📋 DNS RECORDS:${NC}"
    echo -e "  ${GREEN}A RECORD :${NC}  $ns_domain → $PUBLIC_IP"
    echo -e "  ${GREEN}NS RECORD:${NC}  $tunnel_domain → $ns_domain"
    echo ""
    echo -e "${YELLOW}📱 CLIENT COMMAND:${NC}"
    echo -e "${GREEN}DIRECT UDP:${NC}"
    echo -e "  dnstt-client -udp $PUBLIC_IP:5300 \\"
    echo -e "    -pubkey $PUBKEY \\"
    echo -e "    -mtu $MTU \\"
    echo -e "    $tunnel_domain 127.0.0.1:$SSH_PORT"
    echo ""

    cat > "$INSTALL_DIR/connection_info.txt" << EOF
BLACK KILLER SSH TUNNEL MANAGER v9.1
Generated: $(date)

SERVER IP:      $PUBLIC_IP
NS DOMAIN:      $ns_domain
TUNNEL DOMAIN:  $tunnel_domain
SSH PORT:       $SSH_PORT (PROTECTED - Port 22 Firewall Rule Applied)
MTU:            $MTU bytes
PUBLIC KEY:     $PUBKEY

DNS RECORDS:
A    $ns_domain   $PUBLIC_IP
NS   $tunnel_domain  $ns_domain

CLIENT COMMAND (DIRECT UDP):
dnstt-client -udp $PUBLIC_IP:5300 -pubkey $PUBKEY -mtu $MTU $tunnel_domain 127.0.0.1:$SSH_PORT

CLIENT COMMAND (CLOUDFLARE DOH):
dnstt-client -doh https://cloudflare-dns.com/dns-query -pubkey $PUBKEY -mtu $MTU $tunnel_domain 127.0.0.1:$SSH_PORT
EOF

    log_success "INFO SAVED: $INSTALL_DIR/connection_info.txt"
    
    # ★★★ ENSURE SSH SERVICE IS ENABLED AND RUNNING ★★★
    echo ""
    echo -e "${CYAN}🔒 SSH PORT PROTECTION VERIFICATION...${NC}"
    systemctl enable ssh 2>/dev/null || systemctl enable sshd 2>/dev/null || true
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true
    sleep 2
    
    echo -e "${YELLOW}Verifying SSH service status...${NC}"
    if systemctl is-active --quiet ssh 2>/dev/null || systemctl is-active --quiet sshd 2>/dev/null; then
        echo -e "${GREEN}✓ SSH SERVICE IS RUNNING AND ACTIVE${NC}"
        echo -e "${GREEN}✓ SSH PORT ${SSH_PORT} IS ACCESSIBLE${NC}"
        echo -e "${GREEN}✓ FIREWALL PROTECTION ENABLED FOR PORT 22${NC}"
    else
        echo -e "${RED}✗ WARNING: SSH SERVICE STATUS UNCLEAR - CHECKING MANUALLY${NC}"
    fi
    
    echo -e "${CYAN}Checking iptables firewall rules...${NC}"
    if iptables -L INPUT -n | grep -q "tcp dpt:22"; then
        echo -e "${GREEN}✓ SSH PORT 22 FIREWALL RULE VERIFIED${NC}"
    else
        echo -e "${RED}✗ WARNING: SSH PORT 22 RULE NOT FOUND IN IPTABLES${NC}"
    fi
    
    press_enter
}

#============================================================
# SSH USER MANAGEMENT STUBS (Minimal Implementation)
#============================================================

add_ssh_user() {
    show_banner
    dtitle "👤 ADD NEW SSH USER"
    dsep
    echo ""
    echo -e "${CYAN}This feature requires additional setup.${NC}"
    echo -e "${YELLOW}Placeholder for user management interface.${NC}"
    press_enter
}

delete_ssh_user() {
    show_banner
    dtitle "🗑️  DELETE SSH USER"
    dsep
    echo ""
    echo -e "${CYAN}This feature requires additional setup.${NC}"
    echo -e "${YELLOW}Placeholder for user management interface.${NC}"
    press_enter
}

list_ssh_users() {
    show_banner
    dtitle "👥 SSH USERS LIST"
    dsep
    echo ""
    echo -e "${CYAN}This feature requires additional setup.${NC}"
    echo -e "${YELLOW}Placeholder for user management interface.${NC}"
    press_enter
}

#============================================================
# STATUS & INFO
#============================================================
view_status() {
    show_banner
    dtitle "📡 SERVICE STATUS"
    dsep
    echo ""

    if systemctl is-active --quiet dnstt; then
        echo -e "${GREEN}✅ DNSTT: RUNNING (ULTRA v2 MODE 👑)${NC}"
        local uptime_sec
        uptime_sec=$(systemctl show dnstt --property=ActiveEnterTimestamp --value)
        [[ -n "$uptime_sec" ]] && {
            local start_epoch current_epoch uptime_seconds
            start_epoch=$(date -d "$uptime_sec" +%s 2>/dev/null || echo 0)
            current_epoch=$(date +%s)
            uptime_seconds=$((current_epoch - start_epoch))
            local ud=$((uptime_seconds / 86400))
            local uh=$(( (uptime_seconds % 86400) / 3600 ))
            local um=$(( (uptime_seconds % 3600) / 60 ))
            echo -e "  ${WHITE}STARTED :${NC} ${GREEN}$uptime_sec${NC}"
            echo -e "  ${WHITE}UPTIME  :${NC} ${GREEN}${ud}d ${uh}h ${um}m${NC}"
        }
    else
        echo -e "${RED}❌ DNSTT: STOPPED${NC}"
    fi

    local CURRENT_MTU TUNNEL_DOM UDP_CONNS
    CURRENT_MTU=$(cat "$INSTALL_DIR/mtu.txt" 2>/dev/null || echo "N/A")
    TUNNEL_DOM=$(cat "$INSTALL_DIR/tunnel_domain.txt" 2>/dev/null || echo "N/A")
    UDP_CONNS=$(ss -u state established 2>/dev/null | grep -c ':5300' || echo "0")
    echo -e "  ${WHITE}MTU     :${NC} ${CYAN}${CURRENT_MTU} BYTES${NC}"
    echo -e "  ${WHITE}DOMAIN  :${NC} ${CYAN}${TUNNEL_DOM}${NC}"
    echo -e "  ${WHITE}UDP     :${NC} ${CYAN}${UDP_CONNS} ACTIVE${NC}"

    echo ""
    dsep
    echo -e "${CYAN}RECENT LOGS:${NC}"
    journalctl -u dnstt -n 10 --no-pager 2>/dev/null || echo "No logs available"
    press_enter
}

view_logs() {
    show_banner
    dtitle "📋 DNSTT LOGS"
    dsep
    echo ""
    echo -e "  ${CYAN}1)${NC} MAIN LOG"
    echo -e "  ${CYAN}2)${NC} SERVER LOG"
    echo -e "  ${CYAN}3)${NC} ERROR LOG"
    echo -e "  ${CYAN}4)${NC} SYSTEM JOURNAL"
    echo -e "  ${WHITE}0)${NC} BACK"
    echo ""
    read -rp "CHOICE: " log_choice

    case $log_choice in
        1) [[ -f "$LOG_DIR/dnstt.log" ]] && less +G "$LOG_DIR/dnstt.log" || echo -e "${RED}LOG NOT FOUND${NC}" ;;
        2) [[ -f "$LOG_DIR/dnstt-server.log" ]] && less +G "$LOG_DIR/dnstt-server.log" || echo -e "${RED}LOG NOT FOUND${NC}" ;;
        3) [[ -f "$LOG_DIR/dnstt-error.log" ]] && less +G "$LOG_DIR/dnstt-error.log" || echo -e "${RED}NO ERRORS LOGGED${NC}" ;;
        4) journalctl -u dnstt --no-pager -n 100 2>/dev/null || echo "No journal available" ;;
        0) return ;;
        *) echo -e "${RED}INVALID CHOICE${NC}"; sleep 1 ;;
    esac
    press_enter
}

view_info() {
    show_banner
    dtitle "🔗 CONNECTION INFORMATION"
    dsep
    echo ""
    if [[ -f "$INSTALL_DIR/connection_info.txt" ]]; then
        cat "$INSTALL_DIR/connection_info.txt"
    else
        log_error "NOT CONFIGURED. RUN INSTALLATION FIRST."
    fi
    press_enter
}

view_performance() {
    show_banner
    dtitle "⚡ PERFORMANCE MONITOR"
    dsep
    echo ""
    systemctl is-active --quiet dnstt && echo -e "  ${GREEN}✅ DNSTT: RUNNING${NC}" || echo -e "  ${RED}❌ DNSTT: STOPPED${NC}"
    press_enter
}

#============================================================
# MENUS
#============================================================

dnstt_menu() {
    while true; do
        show_banner
        dtitle "🌐 DNSTT MANAGEMENT"
        dsep
        echo ""
        echo -e "  ${GREEN}1)${NC}  📦 INSTALL / SETUP DNSTT"
        echo -e "  ${YELLOW}2)${NC}  📡 VIEW STATUS"
        echo -e "  ${YELLOW}3)${NC}  🔗 VIEW CONNECTION INFO"
        echo -e "  ${CYAN}4)${NC}  📋 VIEW LOGS"
        echo -e "  ${CYAN}5)${NC}  ⚡ PERFORMANCE MONITOR"
        echo -e "  ${BLUE}6)${NC}  🔄 RESTART SERVICE"
        echo -e "  ${RED}7)${NC}  ⏹  STOP SERVICE"
        echo -e "  ${WHITE}0)${NC}  ⬅️  BACK"
        echo ""
        read -rp "CHOICE: " choice

        case $choice in
            1) setup_dnstt ;;
            2) view_status ;;
            3) view_info ;;
            4) view_logs ;;
            5) view_performance ;;
            6)
                echo ""
                fun_bar "systemctl restart dnstt" "RESTARTING SERVICE"
                systemctl is-active --quiet dnstt && echo -e "${GREEN}✓ SERVICE RESTARTED${NC}" || echo -e "${RED}✗ SERVICE FAILED${NC}"
                sleep 2
                ;;
            7)
                echo ""
                systemctl stop dnstt
                echo -e "${YELLOW}SERVICE STOPPED${NC}"
                sleep 2
                ;;
            0) return ;;
            *) log_error "INVALID CHOICE"; sleep 1 ;;
        esac
    done
}

ssh_menu() {
    while true; do
        show_banner
        dtitle "👥 SSH USER MANAGEMENT"
        dsep
        echo ""
        echo -e "  ${GREEN}1)${NC}  👤 ADD NEW USER"
        echo -e "  ${CYAN}2)${NC}  📋 LIST ALL USERS"
        echo -e "  ${RED}3)${NC}  🗑️  DELETE USER"
        echo -e "  ${WHITE}0)${NC}  ⬅️  BACK"
        echo ""
        read -rp "CHOICE: " choice

        case $choice in
            1)  add_ssh_user ;;
            2)  list_ssh_users ;;
            3)  delete_ssh_user ;;
            0)  return ;;
            *)  log_error "INVALID CHOICE"; sleep 1 ;;
        esac
    done
}

main_menu() {
    while true; do
        show_banner
        dtitle "★ MAIN MENU ★"
        dsep
        echo ""
        echo -e "  ${GREEN}1)${NC}  🌐 DNSTT MANAGEMENT"
        echo -e "  ${BLUE}2)${NC}  👥 SSH USERS"
        echo -e "  ${RED}0)${NC}  ⛔ EXIT"
        echo ""
        dsep
        echo -e "  ${WHITE}VERSION: 9.1 ULTRA DIAMOND | SSH PORT 22 PROTECTED${NC}"
        echo -e "  ${BRED}CREATED BY BLACK KILLER${NC}"
        echo -e "  ${WHITE}📱 WhatsApp: +255658785522${NC}"
        dsep
        echo ""
        read -rp "CHOICE: " choice

        case $choice in
            1) dnstt_menu ;;
            2) ssh_menu ;;
            0)
                echo ""
                dbox_top
                echo -e "${BGREEN}   THANK YOU FOR USING BLACK KILLER SSH TUNNEL MANAGER! 👑${NC}"
                echo -e "${WHITE}   SSH PORT 22 PROTECTION: ENABLED ✓${NC}"
                echo -e "${WHITE}   📱 WhatsApp: +255658785522${NC}"
                dbox_bot
                echo ""
                exit 0
                ;;
            *)
                log_error "INVALID CHOICE"
                sleep 1
                ;;
        esac
    done
}

#============================================================
# CREATE MENU COMMANDS
#============================================================
create_menu_command() {
    local SCRIPT_PATH
    SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

    for cmd in menu dnstt slowdns; do
        cat > "/usr/local/bin/$cmd" << EOF
#!/bin/bash
bash "$SCRIPT_PATH"
EOF
        chmod +x "/usr/local/bin/$cmd"
    done

    log_success "MENU COMMANDS CREATED: menu, dnstt, slowdns"
}

#============================================================
# MAIN EXECUTION
#============================================================
[[ ! -f /usr/local/bin/menu ]] && [[ $EUID -eq 0 ]] && create_menu_command 2>/dev/null

check_root
check_bash_version
check_os
main_menu

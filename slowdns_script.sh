#!/bin/bash

##############################################################
#   ██████╗ ██╗      █████╗  ██████╗██╗  ██╗               #
#   ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝               #
#   ██████╔╝██║     ███████║██║     █████╔╝                 #
#   ██╔══██╗██║     ██╔══██║██║     ██╔═██╗                 #
#   ██████╔╝███████╗██║  ██║╚██████╗██║  ██╗               #
#   ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝               #
#                                                            #
#   SSH TUNNEL MANAGER v9.0 — ULTRA DIAMOND EDITION         #
#   Created By BLACK KILLER                                  #
#   WhatsApp: +255658785522                                  #
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
BANNER_FILE="/etc/ssh/slowdns_banner"
LOG_DIR="/var/log/dnstt"
DNSTT_SERVER="/usr/local/bin/dnstt-server"
DNSTT_CLIENT="/usr/local/bin/dnstt-client"
SCRIPT_VERSION="9.2.0"
GITHUB_RAW="https://raw.githubusercontent.com/cyberhinju-blip/slowdns-manager/main/slowdns_script.sh"
GITHUB_VER="https://raw.githubusercontent.com/cyberhinju-blip/slowdns-manager/main/version.txt"

mkdir -p "$INSTALL_DIR" "$SSH_DIR" "$LOG_DIR" "$USAGE_DIR" "$BACKUP_DIR"
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
dbox_top() { echo -e "${BRED}⋘═══════════════════════════════════════════════════════════⋙${NC}"; }
dbox_bot() { echo -e "${BRED}⋘═══════════════════════════════════════════════════════════⋙${NC}"; }

press_enter() {
    echo ""
    echo -e "${BRED}  ►► PRESS ENTER TO CONTINUE ◄◄${NC}"
    read -r
}

#============================================================
# FUN_BAR — PROGRESS ANIMATION
#============================================================
fun_bar() {
    # Accepts a STATIC shell command string (no user data interpolated here).
    # Callers must never interpolate user/DB content directly into this string.
    local cmd="$1"
    local label="${2:-PLEASE WAIT...}"
    # Use unique tmpfile: PID + RANDOM avoids collisions on rapid back-to-back calls
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
║  ║   ☠  SSH TUNNEL MANAGER v9.0 ULTRA DIAMOND  ☠       ║   ║
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
# SSH SAFETY HELPER — call after ANY sshd_config change
#============================================================
ensure_ssh_alive() {
    # Validate config BEFORE reloading — never reload a broken config
    if ! sshd -t 2>/dev/null; then
        log_error "SSHD CONFIG TEST FAILED — ROLLING BACK TO BACKUP"
        if [[ -f /etc/ssh/sshd_config.backup ]]; then
            cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
            log_success "BACKUP RESTORED"
        fi
    fi

    # Enable + restart SSH so it survives reboots and any prior failures
    systemctl enable ssh  2>/dev/null || systemctl enable sshd  2>/dev/null || true
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || \
        service ssh restart 2>/dev/null || true
    sleep 2   # Give sshd time to bind the port

    # Use 'sshd -T' to get the *effective* port (respects Include directives)
    # then confirm the listener is owned by sshd — not just any process
    local _ssh_port
    _ssh_port=$(sshd -T 2>/dev/null | grep -i "^port " | awk '{print $2}' | head -1)
    _ssh_port=${_ssh_port:-22}

    if ss -tlnp 2>/dev/null | grep -E ":${_ssh_port}\b" | grep -qi "sshd"; then
        log_success "SSH SERVICE ALIVE — SSHD LISTENING ON PORT ${_ssh_port}"
    elif ss -tlnp 2>/dev/null | grep -qE ":${_ssh_port}\b"; then
        log_error "WARNING: PORT ${_ssh_port} OPEN BUT NOT OWNED BY SSHD — INVESTIGATE"
    else
        log_error "WARNING: SSH NOT DETECTED ON PORT ${_ssh_port} — CHECK: systemctl status sshd"
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
    # Try both sysctl paths — kernel 5.x+ uses net.netfilter, older use net.nf_conntrack
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

    # Always back up before touching sshd_config
    if [[ ! -f "${sshd_cfg}.backup" ]]; then
        cp "$sshd_cfg" "${sshd_cfg}.backup"
    fi

    # NEVER touch the Port line — only tune performance settings
    local ciphers="chacha20-poly1305@openssh.com,aes128-gcm@openssh.com,aes256-gcm@openssh.com"
    local macs="hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com"
    local kex="curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512"

    # Remove old optimization lines only (never Port / AuthorizedKeysFile / etc.)
    sed -i '/^Ciphers /d; /^MACs /d; /^KexAlgorithms /d; /^Compression /d; /^IPQoS /d; /^# BLACK KILLER/d' "$sshd_cfg"
    cat >> "$sshd_cfg" << EOF

# BLACK KILLER SSH OPTIMIZATION v9.0
Ciphers $ciphers
MACs $macs
KexAlgorithms $kex
Compression delayed
IPQoS lowdelay throughput
EOF

    # Test config before applying — roll back and abort if broken
    if ! sshd -t 2>/dev/null; then
        log_error "OPTIMIZED CONFIG FAILED SYNTAX TEST — ROLLING BACK"
        cp "${sshd_cfg}.backup" "$sshd_cfg"
        log_success "ORIGINAL CONFIG RESTORED — SSH UNCHANGED"
        return 1
    fi

    # Safe reload (config passed test); then verify SSH is still alive
    systemctl reload sshd 2>/dev/null || service ssh reload 2>/dev/null || true
    ensure_ssh_alive
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
        # Install core packages; iptables-persistent may not exist on all versions — use || true
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
        # Compare versions numerically (major.minor.patch)
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
# FIREWALL CONFIGURATION
#============================================================
configure_firewall() {
    log_message "${YELLOW}🔥 CONFIGURING FIREWALL...${NC}"

    NET_IF=$(ip route show default 2>/dev/null | awk '{print $5}' | head -1)
    NET_IF=${NET_IF:-eth0}

    # Detect the actual SSH port BEFORE touching any firewall rules
    local CURR_SSH_PORT
    CURR_SSH_PORT=$(grep -E "^Port " /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | head -1)
    [[ -z "$CURR_SSH_PORT" || ! "$CURR_SSH_PORT" =~ ^[0-9]+$ ]] && CURR_SSH_PORT=22

    # ── CRITICAL: Pin SSH ACCEPT as the very first iptables rule BEFORE any flush ──
    # This survives UFW disable and the subsequent iptables -F because we re-add it
    # immediately after. The gap between -F and re-add is microseconds with ACCEPT policy.
    iptables -P INPUT ACCEPT   2>/dev/null || true
    iptables -P OUTPUT ACCEPT  2>/dev/null || true
    iptables -P FORWARD ACCEPT 2>/dev/null || true

    # Disable UFW AFTER setting ACCEPT policy — UFW disable no longer creates a lockout window
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

    # Flush all chains — safe because default policy is now ACCEPT
    iptables -F INPUT   2>/dev/null || true
    iptables -F OUTPUT  2>/dev/null || true
    iptables -F FORWARD 2>/dev/null || true
    iptables -t nat    -F 2>/dev/null || true
    iptables -t mangle -F 2>/dev/null || true
    iptables -X        2>/dev/null || true

    # ── SSH ACCEPT goes in FIRST — guaranteed slot 1 before anything else ──
    iptables -I INPUT 1 -p tcp --dport "$CURR_SSH_PORT" -j ACCEPT
    iptables -I INPUT 2 -p udp --dport 5300 -j ACCEPT
    iptables -I INPUT 3 -p udp --dport 53  -j ACCEPT

    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p tcp --dport 80  -j ACCEPT
    iptables -t nat -I PREROUTING 1 -p udp --dport 53 -j REDIRECT --to-ports 5300
    iptables -t nat -A POSTROUTING -o "$NET_IF" -j MASQUERADE
    iptables -A FORWARD -i lo -j ACCEPT
    iptables -A FORWARD -o lo -j ACCEPT
    iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A FORWARD -o "$NET_IF" -j ACCEPT
    iptables -A FORWARD -i "$NET_IF" -j ACCEPT

    # Apply ip6tables rules only if available (not all VPS providers support IPv6)
    if command -v ip6tables &>/dev/null; then
        ip6tables -P INPUT  ACCEPT 2>/dev/null || true
        ip6tables -P OUTPUT ACCEPT 2>/dev/null || true
        ip6tables -I INPUT 1 -p tcp --dport "$CURR_SSH_PORT" -j ACCEPT 2>/dev/null || true
        ip6tables -I INPUT 2 -p udp --dport 5300 -j ACCEPT 2>/dev/null || true
        ip6tables -I INPUT 3 -p udp --dport 53   -j ACCEPT 2>/dev/null || true
        ip6tables -t nat -I PREROUTING 1 -p udp --dport 53 -j REDIRECT --to-ports 5300 2>/dev/null || true
    fi

    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || true

    # ── Guarantee SSH service is alive after all firewall changes ──
    ensure_ssh_alive

    log_success "FIREWALL CONFIGURED"
    echo -e "  ${GREEN}✓${NC} SSH PORT ${CURR_SSH_PORT} OPEN | UDP 53/5300 OPEN | TCP 80/443 OPEN | NAT ON ${NET_IF}"
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
Description=DNSTT DNS TUNNEL SERVER v9.0 — BLACK KILLER
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
    PUBKEY=$(cat "$INSTALL_DIR/server.pub" 2>/dev/null || echo "KEY_NOT_FOUND — RUN: cat /etc/dnstt/server.pub")

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
BLACK KILLER SSH TUNNEL MANAGER v9.0
Generated: $(date)

SERVER IP:      $PUBLIC_IP
NS DOMAIN:      $ns_domain
TUNNEL DOMAIN:  $tunnel_domain
SSH PORT:       $SSH_PORT
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

    # ── Guarantee SSH stays alive after full setup ──
    echo ""
    echo -e "${CYAN}◇──────────────────────────────────────────────◇${NC}"
    echo -e "  ${YELLOW}🔒 ENSURING SSH SERVICE IS ALIVE...${NC}"
    ensure_ssh_alive
    echo -e "${CYAN}◇──────────────────────────────────────────────◇${NC}"
    echo ""

    press_enter
}

#============================================================
# SSH USER MANAGEMENT
#============================================================

# Field layout in USER_DB:
# 1:user | 2:pass | 3:expiry | 4:created | 5:gb_limit | 6:status | 7:ar_days | 8:ar_trigger | 9:conn_limit

add_ssh_user() {
    show_banner
    dtitle "👤 ADD NEW SSH USER"
    dsep
    echo ""

    read -rp "USERNAME: " username
    [[ -z "$username" ]] && { log_error "USERNAME REQUIRED"; press_enter; return; }
    # Only allow safe alphanumeric + underscore/hyphen usernames (no spaces, no special chars)
    if [[ ! "$username" =~ ^[a-zA-Z0-9_-]{2,32}$ ]]; then
        log_error "INVALID USERNAME — USE 2-32 CHARS: LETTERS, NUMBERS, _ OR - ONLY"
        press_enter; return
    fi

    if id "$username" &>/dev/null; then
        log_error "USER ALREADY EXISTS"
        press_enter
        return
    fi

    read -rsp "PASSWORD: " password; echo ""
    [[ -z "$password" ]] && { log_error "PASSWORD REQUIRED"; press_enter; return; }

    echo ""
    echo -e "${YELLOW}SELECT EXPIRATION PERIOD:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC} 1 DAY"
    echo -e "  ${CYAN}2)${NC} 7 DAYS"
    echo -e "  ${CYAN}3)${NC} 30 DAYS ${GREEN}⭐${NC}"
    echo -e "  ${CYAN}4)${NC} 90 DAYS"
    echo -e "  ${CYAN}5)${NC} 365 DAYS"
    echo ""
    read -rp "CHOICE [1-5, default=3]: " exp_choice

    case ${exp_choice:-3} in
        1) days=1 ;;   2) days=7 ;;
        3) days=30 ;;  4) days=90 ;;
        5) days=365 ;; *) days=30 ;;
    esac

    echo ""
    echo -e "${YELLOW}DATA LIMIT IN GB (0 = UNLIMITED):${NC}"
    read -rp "GB LIMIT [default=0]: " gb_input
    gb_limit=${gb_input:-0}
    [[ ! "$gb_limit" =~ ^[0-9]+$ ]] && gb_limit=0

    conn_limit=0  # Multi-login limiter removed — always unlimited

    echo ""
    echo -e "${YELLOW}AUTO-RENEW SETTINGS:${NC}"
    echo -e "  ${CYAN}1)${NC} DISABLED (MANUAL RENEW)"
    echo -e "  ${CYAN}2)${NC} RENEW 1 DAY BEFORE EXPIRY"
    echo -e "  ${CYAN}3)${NC} RENEW 3 DAYS BEFORE EXPIRY"
    echo -e "  ${CYAN}4)${NC} RENEW 7 DAYS BEFORE EXPIRY"
    echo ""
    read -rp "CHOICE [1-4, default=1]: " ar_choice
    case ${ar_choice:-1} in
        2) auto_renew_days=$days; ar_trigger=1 ;;
        3) auto_renew_days=$days; ar_trigger=3 ;;
        4) auto_renew_days=$days; ar_trigger=7 ;;
        *) auto_renew_days=0; ar_trigger=0 ;;
    esac

    echo ""
    echo -e "${CYAN}CREATING USER...${NC}"

    if ! useradd -m -s /bin/bash "$username" 2>/dev/null; then
        log_error "FAILED TO CREATE SYSTEM USER '$username' — USERADD ERROR"
        press_enter; return 1
    fi
    if ! echo "$username:$password" | chpasswd 2>/dev/null; then
        log_error "FAILED TO SET PASSWORD — ROLLING BACK"
        userdel -r "$username" 2>/dev/null || true
        press_enter; return 1
    fi

    exp_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$exp_date" "$username" 2>/dev/null

    # Only write to DB after system user is confirmed created
    echo "$username|$password|$exp_date|$(date +"%Y-%m-%d")|$gb_limit|active|$auto_renew_days|$ar_trigger|$conn_limit" >> "$USER_DB"

    setup_user_quota "$username" "$gb_limit"
    update_motd_script

    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "YOUR_SERVER_IP")
    PUBKEY=$(cat "$INSTALL_DIR/server.pub" 2>/dev/null || echo "N/A")

    echo ""
    dbox_top
    echo -e "${BGREEN}           USER CREATED SUCCESSFULLY${NC}"
    dbox_bot
    echo ""
    echo -e "  ${WHITE}SERVER IP      :${NC} ${YELLOW}$PUBLIC_IP${NC}"
    echo -e "  ${WHITE}USER           :${NC} ${GREEN}$username${NC}"
    echo -e "  ${WHITE}PASSWORD       :${NC} ${GREEN}$password${NC}"
    echo -e "  ${WHITE}DURATION       :${NC} ${CYAN}$days DAYS${NC}"
    echo -e "  ${WHITE}DATA LIMIT     :${NC} ${CYAN}$([ "$gb_limit" -eq 0 ] && echo UNLIMITED || echo "${gb_limit} GB")${NC}"
    echo -e "  ${WHITE}EXPIRY DATE    :${NC} ${YELLOW}$exp_date${NC}"
    echo -e "  ${WHITE}PUBLIC KEY     :${NC} ${CYAN}$PUBKEY${NC}"
    dbox_bot
    press_enter
}

delete_ssh_user() {
    show_banner
    dtitle "🗑️  DELETE SSH USER"
    dsep
    echo ""

    read -rp "USERNAME TO DELETE: " username
    if ! id "$username" &>/dev/null; then
        log_error "USER NOT FOUND"
        press_enter
        return
    fi

    echo ""
    echo -e "${RED}⚠ WARNING: YOU ARE ABOUT TO DELETE USER: $username${NC}"
    echo ""
    read -rp "TYPE 'yes' TO CONFIRM: " confirm
    [[ "$confirm" != "yes" ]] && { echo -e "${YELLOW}DELETION CANCELLED${NC}"; press_enter; return; }

    pkill -u "$username" 2>/dev/null || true
    # Only remove from DB if userdel succeeds (or user was already gone)
    if userdel -r "$username" 2>/dev/null || ! id "$username" &>/dev/null; then
        sed -i "/^$username|/d" "$USER_DB"
        iptables -D OUTPUT -m owner --uid-owner "$username" -j "slowdns_$username" 2>/dev/null || true
        iptables -F "slowdns_$username" 2>/dev/null || true
        iptables -X "slowdns_$username" 2>/dev/null || true
        rm -f "$USAGE_DIR/$username"
        update_motd_script
        echo -e "${GREEN}✓ USER $username DELETED${NC}"
    else
        log_error "USERDEL FAILED — USER MAY HAVE ACTIVE PROCESSES. TRY AGAIN."
        press_enter; return 1
    fi
    log_success "USER $username REMOVED"
    press_enter
}

list_ssh_users() {
    show_banner
    dtitle "👥 SSH USERS LIST"
    dsep
    echo ""

    if [[ ! -s "$USER_DB" ]]; then
        echo -e "${YELLOW}NO USERS FOUND${NC}"
        press_enter
        return
    fi

    printf "${CYAN}╔${NC}${WHITE}%-12s${NC}${CYAN}┬${NC}${WHITE}%-12s${NC}${CYAN}┬${NC}${WHITE}%-10s${NC}${CYAN}┬${NC}${WHITE}%-7s${NC}${CYAN}┬${NC}${WHITE}%-14s${NC}${CYAN}┬${NC}${WHITE}%-8s${NC}${CYAN}┬${NC}${WHITE}%-8s${NC}${CYAN}╗${NC}\n" \
        " USERNAME" " PASSWORD" " EXPIRES" " DAYS" " DATA USED/LIMIT" " STATUS" " CONN"
    echo -e "${CYAN}╠════════════╪════════════╪══════════╪═══════╪══════════════╪════════╪════════╣${NC}"

    local user_count=0 active_count=0

    while IFS='|' read -r user pass exp created gb_limit acc_status ar_days ar_trigger conn_limit; do
        [[ -z "$user" ]] && continue
        user_count=$((user_count + 1))
        gb_limit=${gb_limit:-0}
        acc_status=${acc_status:-active}
        conn_limit=${conn_limit:-0}

        local current exp_unix days_left
        current=$(date +%s)
        exp_unix=$(date -d "$exp" +%s 2>/dev/null || echo 0)
        days_left=$(( (exp_unix - current) / 86400 ))

        if [[ "$acc_status" == "locked" ]]; then
            exp_status="${RED}LOCKED${NC}"; days_display="${RED}-${NC}"
        elif [[ $current -gt $exp_unix ]]; then
            exp_status="${RED}EXPIRED${NC}"; days_display="${RED}0${NC}"
        elif [[ $days_left -le 3 ]]; then
            exp_status="${RED}EXPIRING${NC}"; days_display="${RED}$days_left${NC}"
        elif [[ $days_left -le 7 ]]; then
            exp_status="${YELLOW}WARN${NC}"; days_display="${YELLOW}$days_left${NC}"
        else
            exp_status="${GREEN}ACTIVE${NC}"; days_display="${GREEN}$days_left${NC}"
            active_count=$((active_count + 1))
        fi

        local usage_gb
        usage_gb=$(get_user_usage_gb "$user")
        if [[ "$gb_limit" -gt 0 ]]; then
            data_display="${CYAN}${usage_gb}/${gb_limit}GB${NC}"
        else
            data_display="${GREEN}${usage_gb}/∞${NC}"
        fi

        local conn_display
        conn_display="$([ "$conn_limit" -eq 0 ] && echo "${GREEN}∞${NC}" || echo "${CYAN}${conn_limit}${NC}")"

        printf "${CYAN}║${NC} %-10s ${CYAN}│${NC} %-10s ${CYAN}│${NC} %-8s ${CYAN}│${NC} " "$user" "$pass" "$exp"
        echo -ne "$days_display"
        printf " ${CYAN}│${NC} "
        echo -ne "$data_display"
        printf " ${CYAN}│${NC} "
        echo -ne "$exp_status"
        printf " ${CYAN}│${NC} "
        echo -e "$conn_display ${CYAN}║${NC}"
    done < "$USER_DB"

    echo -e "${CYAN}╚════════════╧════════════╧══════════╧═══════╧══════════════╧════════╧════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}TOTAL: ${WHITE}$user_count${NC}  |  ${GREEN}ACTIVE: $active_count${NC}  |  ${RED}EXPIRED/LOCKED: $((user_count - active_count))${NC}"
    press_enter
}

#============================================================
# QUOTA HELPERS
#============================================================
setup_user_quota() {
    local username="$1"
    local gb_limit="$2"
    local uid
    uid=$(id -u "$username" 2>/dev/null) || return
    iptables -N "slowdns_$username" 2>/dev/null || iptables -F "slowdns_$username" 2>/dev/null
    iptables -C OUTPUT -m owner --uid-owner "$uid" -j "slowdns_$username" 2>/dev/null || \
        iptables -I OUTPUT -m owner --uid-owner "$uid" -j "slowdns_$username" 2>/dev/null
    iptables -A "slowdns_$username" -j RETURN 2>/dev/null
    echo "0" > "$USAGE_DIR/$username"
}

get_user_usage_gb() {
    local username="$1"
    local bytes=0 raw saved total
    raw=$(iptables -L "slowdns_$username" -xvn 2>/dev/null | awk 'NR==3{print $2}')
    [[ "$raw" =~ ^[0-9]+$ ]] && bytes=$raw
    saved=0
    [[ -f "$USAGE_DIR/$username" ]] && saved=$(cat "$USAGE_DIR/$username" 2>/dev/null)
    [[ "$saved" =~ ^[0-9]+$ ]] || saved=0
    total=$(( bytes + saved ))
    awk "BEGIN{printf \"%.2f\", $total/1073741824}"
}

check_quota_all_users() {
    while IFS='|' read -r user pass exp created gb_limit acc_status ar_days ar_trigger conn_limit; do
        [[ -z "$user" || "$acc_status" == "locked" ]] && continue
        gb_limit=${gb_limit:-0}
        [[ "$gb_limit" -eq 0 ]] && continue
        local usage_gb
        usage_gb=$(get_user_usage_gb "$user")
        local exceeded
        exceeded=$(awk "BEGIN{print ($usage_gb >= $gb_limit) ? 1 : 0}")
        if [[ "$exceeded" == "1" ]]; then
            passwd -l "$user" 2>/dev/null
            sed -i "s/^$user|$pass|$exp|$created|$gb_limit|active/$user|$pass|$exp|$created|$gb_limit|locked/" "$USER_DB"
            log_error "USER $user EXCEEDED ${gb_limit}GB QUOTA — LOCKED"
        fi
    done < "$USER_DB"
}

update_motd_script() {
    local motd_script="/etc/profile.d/slowdns_info.sh"
    cat > "$motd_script" << 'MOTD_EOF'
#!/bin/bash
USER_DB="/etc/slowdns/users.txt"
USAGE_DIR="/etc/slowdns/usage"
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; WHITE='\033[1;37m'; BRED='\033[1;31m'; NC='\033[0m'
[[ ! -f "$USER_DB" ]] && exit 0
me=$(whoami)
user_line=$(grep "^${me}|" "$USER_DB" 2>/dev/null)
[[ -z "$user_line" ]] && exit 0
IFS='|' read -r u pass exp created gb_limit acc_status ar_days ar_trigger conn_limit <<< "$user_line"
gb_limit=${gb_limit:-0}; acc_status=${acc_status:-active}; conn_limit=${conn_limit:-0}
current=$(date +%s)
exp_unix=$(date -d "$exp" +%s 2>/dev/null || echo 0)
days_left=$(( (exp_unix - current) / 86400 ))
bytes=0
raw=$(iptables -L "slowdns_${me}" -xvn 2>/dev/null | awk 'NR==3{print $2}')
[[ "$raw" =~ ^[0-9]+$ ]] && bytes=$raw
saved=0
[[ -f "$USAGE_DIR/$me" ]] && saved=$(cat "$USAGE_DIR/$me" 2>/dev/null)
[[ "$saved" =~ ^[0-9]+$ ]] || saved=0
total=$(( bytes + saved ))
usage_gb=$(awk "BEGIN{printf \"%.2f\", $total/1073741824}")
echo ""
echo -e "${BRED}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BRED}║  ☠  BLACK KILLER — SSH TUNNEL MANAGER v9.0 ULTRA  ☠  ║${NC}"
echo -e "${BRED}║            📱 WhatsApp: +255658785522               ║${NC}"
echo -e "${BRED}╠═══════════════════════════════════════════════════════╣${NC}"
printf "${CYAN}║${NC}  ${WHITE}%-20s${NC} ${GREEN}%-32s${NC}${CYAN}║${NC}\n" "👤 USERNAME:" "$me"
printf "${CYAN}║${NC}  ${WHITE}%-20s${NC} ${YELLOW}%-32s${NC}${CYAN}║${NC}\n" "📅 EXPIRES:" "$exp"
if [[ "$acc_status" == "locked" ]]; then
    printf "${CYAN}║${NC}  ${WHITE}%-20s${NC} ${RED}%-32s${NC}${CYAN}║${NC}\n" "🔒 STATUS:" "LOCKED"
elif [[ $current -gt $exp_unix ]]; then
    printf "${CYAN}║${NC}  ${WHITE}%-20s${NC} ${RED}%-32s${NC}${CYAN}║${NC}\n" "⏳ DAYS LEFT:" "EXPIRED"
elif [[ $days_left -le 3 ]]; then
    printf "${CYAN}║${NC}  ${WHITE}%-20s${NC} ${RED}%-32s${NC}${CYAN}║${NC}\n" "⏳ DAYS LEFT:" "${days_left} DAYS (EXPIRING SOON!)"
else
    printf "${CYAN}║${NC}  ${WHITE}%-20s${NC} ${GREEN}%-32s${NC}${CYAN}║${NC}\n" "⏳ DAYS LEFT:" "${days_left} DAYS"
fi
if [[ "$gb_limit" -gt 0 ]]; then
    pct=$(awk "BEGIN{printf \"%.0f\", ($usage_gb/$gb_limit)*100}")
    printf "${CYAN}║${NC}  ${WHITE}%-20s${NC} ${CYAN}%-32s${NC}${CYAN}║${NC}\n" "📶 DATA USED:" "${usage_gb} GB / ${gb_limit} GB (${pct}%)"
else
    printf "${CYAN}║${NC}  ${WHITE}%-20s${NC} ${GREEN}%-32s${NC}${CYAN}║${NC}\n" "📶 DATA USED:" "${usage_gb} GB / UNLIMITED"
fi
cl_text="$([ "$conn_limit" -eq 0 ] && echo UNLIMITED || echo "$conn_limit")"
printf "${CYAN}║${NC}  ${WHITE}%-20s${NC} ${CYAN}%-32s${NC}${CYAN}║${NC}\n" "🔗 CONN LIMIT:" "$cl_text"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
MOTD_EOF
    chmod +x "$motd_script" 2>/dev/null
}

#============================================================
# RENEW USER
#============================================================
renew_ssh_user() {
    show_banner
    dtitle "🔄 RENEW SSH USER"
    dsep
    echo ""

    [[ ! -s "$USER_DB" ]] && { log_error "NO USERS FOUND"; press_enter; return; }

    echo -e "${YELLOW}ACTIVE USERS:${NC}"
    while IFS='|' read -r user pass exp _ _ _rest; do
        [[ -z "$user" ]] && continue
        echo -e "  ${GREEN}→${NC} $user  ${WHITE}(EXPIRES: $exp)${NC}"
    done < "$USER_DB"
    echo ""

    read -rp "USERNAME TO RENEW: " username
    [[ -z "$username" ]] && { log_error "USERNAME REQUIRED"; press_enter; return; }

    local user_line
    user_line=$(grep "^$username|" "$USER_DB")
    [[ -z "$user_line" ]] && { log_error "USER NOT FOUND"; press_enter; return; }

    echo ""
    echo -e "${YELLOW}SELECT NEW EXPIRATION:${NC}"
    echo -e "  ${CYAN}1)${NC} 1 DAY   ${CYAN}2)${NC} 7 DAYS   ${CYAN}3)${NC} 30 DAYS ⭐   ${CYAN}4)${NC} 90 DAYS   ${CYAN}5)${NC} 365 DAYS"
    echo ""
    read -rp "CHOICE [1-5, default=3]: " exp_choice

    case ${exp_choice:-3} in
        1) days=1 ;;   2) days=7 ;;
        3) days=30 ;;  4) days=90 ;;
        5) days=365 ;; *) days=30 ;;
    esac

    IFS='|' read -r u pass exp created gb_limit acc_status ar_days ar_trigger conn_limit <<< "$user_line"
    local new_exp
    new_exp=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$new_exp" "$username" 2>/dev/null

    sed -i "/^$username|/c\\$username|$pass|$new_exp|$created|${gb_limit:-0}|active|${ar_days:-0}|${ar_trigger:-0}|${conn_limit:-0}" "$USER_DB"

    update_motd_script
    log_success "USER $username RENEWED — NEW EXPIRY: $new_exp ($days DAYS)"
    press_enter
}

#============================================================
# LOCK / UNLOCK
#============================================================
lock_ssh_user() {
    show_banner
    dtitle "🔒 LOCK SSH ACCOUNT"
    dsep
    echo ""
    [[ ! -s "$USER_DB" ]] && { log_error "NO USERS FOUND"; press_enter; return; }

    while IFS='|' read -r user _ _ _ _ acc_status _rest; do
        [[ -z "$user" ]] && continue
        [[ "${acc_status:-active}" == "locked" ]] && echo -e "  ${RED}🔒 $user (ALREADY LOCKED)${NC}" || echo -e "  ${GREEN}🔓 $user (ACTIVE)${NC}"
    done < "$USER_DB"
    echo ""
    read -rp "USERNAME TO LOCK: " username
    [[ -z "$username" ]] && { log_error "USERNAME REQUIRED"; press_enter; return; }

    local user_line
    user_line=$(grep "^$username|" "$USER_DB")
    [[ -z "$user_line" ]] && { log_error "USER NOT FOUND"; press_enter; return; }

    IFS='|' read -r u pass exp created gb_limit acc_status ar_days ar_trigger conn_limit <<< "$user_line"
    [[ "${acc_status:-active}" == "locked" ]] && { log_error "USER ALREADY LOCKED"; press_enter; return; }

    passwd -l "$username" 2>/dev/null
    pkill -u "$username" 2>/dev/null || true
    sed -i "/^$username|/c\\$username|$pass|$exp|$created|${gb_limit:-0}|locked|${ar_days:-0}|${ar_trigger:-0}|${conn_limit:-0}" "$USER_DB"
    update_motd_script

    log_success "USER $username LOCKED — ALL SESSIONS TERMINATED"
    press_enter
}

unlock_ssh_user() {
    show_banner
    dtitle "🔓 UNLOCK SSH ACCOUNT"
    dsep
    echo ""
    [[ ! -s "$USER_DB" ]] && { log_error "NO USERS FOUND"; press_enter; return; }

    while IFS='|' read -r user _ _ _ _ acc_status _rest; do
        [[ -z "$user" ]] && continue
        [[ "${acc_status:-active}" == "locked" ]] && echo -e "  ${RED}🔒 $user (LOCKED)${NC}" || echo -e "  ${GREEN}🔓 $user (ACTIVE)${NC}"
    done < "$USER_DB"
    echo ""
    read -rp "USERNAME TO UNLOCK: " username
    [[ -z "$username" ]] && { log_error "USERNAME REQUIRED"; press_enter; return; }

    local user_line
    user_line=$(grep "^$username|" "$USER_DB")
    [[ -z "$user_line" ]] && { log_error "USER NOT FOUND"; press_enter; return; }

    IFS='|' read -r u pass exp created gb_limit acc_status ar_days ar_trigger conn_limit <<< "$user_line"
    [[ "${acc_status:-active}" != "locked" ]] && { log_error "USER IS NOT LOCKED"; press_enter; return; }

    passwd -u "$username" 2>/dev/null
    sed -i "/^$username|/c\\$username|$pass|$exp|$created|${gb_limit:-0}|active|${ar_days:-0}|${ar_trigger:-0}|${conn_limit:-0}" "$USER_DB"
    update_motd_script

    log_success "USER $username UNLOCKED"
    press_enter
}

#============================================================
# SSH BANNER MANAGEMENT
#============================================================
manage_ssh_banner() {
    while true; do
        show_banner
        dtitle "🖥️  SSH BANNER / SERVER MESSAGE"
        dsep
        echo ""
        if [[ -f "$BANNER_FILE" ]]; then
            echo -e "${GREEN}✅ BANNER IS SET${NC}"
            echo -e "${YELLOW}━━━━ CURRENT BANNER ━━━━${NC}"
            cat "$BANNER_FILE"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        else
            echo -e "${RED}⚠ NO BANNER SET${NC}"
        fi
        echo ""
        echo -e "  ${GREEN}1)${NC} ✏️  SET / EDIT BANNER TEXT"
        echo -e "  ${YELLOW}2)${NC} 🎨 SET DEFAULT BANNER"
        echo -e "  ${RED}3)${NC} 🗑️  REMOVE BANNER"
        echo -e "  ${WHITE}0)${NC} ⬅️  BACK"
        echo ""
        read -rp "CHOICE: " choice
        case $choice in
            1)
                show_banner
                dtitle "EDIT SSH BANNER"
                dsep
                echo ""
                echo -e "${YELLOW}ENTER BANNER TEXT (TYPE 'END' ON A NEW LINE TO FINISH):${NC}"
                echo ""
                local banner_text=""
                while IFS= read -r line; do
                    [[ "$line" == "END" ]] && break
                    banner_text+="$line"$'\n'
                done
                [[ -z "$banner_text" ]] && { log_error "BANNER CANNOT BE EMPTY"; press_enter; continue; }
                echo "$banner_text" > "$BANNER_FILE"
                _apply_banner_config
                log_success "SSH BANNER UPDATED"
                press_enter
                ;;
            2)
                cat > "$BANNER_FILE" << 'BANNER_EOF'

╔═══════════════════════════════════════════════════════╗
║   ██████╗ ██╗      █████╗  ██████╗██╗  ██╗           ║
║   ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝           ║
║   ██████╔╝██║     ███████║██║     █████╔╝            ║
║   ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝           ║
╠═══════════════════════════════════════════════════════╣
║     SSH TUNNEL MANAGER v9.0 — BLACK KILLER           ║
║     📱 WhatsApp: +255658785522                       ║
╠═══════════════════════════════════════════════════════╣
║  ⚠  AUTHORIZED ACCESS ONLY                           ║
║  🔐 ALL SESSIONS ARE MONITORED AND LOGGED            ║
╚═══════════════════════════════════════════════════════╝

BANNER_EOF
                _apply_banner_config
                log_success "DEFAULT BANNER APPLIED"
                press_enter
                ;;
            3)
                read -rp "REMOVE SSH BANNER? [yes/no]: " confirm
                if [[ "$confirm" == "yes" ]]; then
                    rm -f "$BANNER_FILE"
                    sed -i '/^Banner /d; /^#Banner /d' /etc/ssh/sshd_config 2>/dev/null
                    ensure_ssh_alive
                    log_success "BANNER REMOVED"
                fi
                press_enter
                ;;
            0) return ;;
            *) log_error "INVALID CHOICE"; sleep 1 ;;
        esac
    done
}

_apply_banner_config() {
    local sshd_cfg="/etc/ssh/sshd_config"

    # Step 1: Remove ALL existing Banner directives (active and commented) to start clean
    sed -i '/^Banner /d; /^#Banner /d' "$sshd_cfg" 2>/dev/null || true

    # Step 2: Append exactly ONE Banner directive — no duplicates possible
    echo "Banner $BANNER_FILE" >> "$sshd_cfg"

    # Step 3: Ensure PrintMotd yes (for post-login MOTD display)
    if grep -q "^PrintMotd" "$sshd_cfg" 2>/dev/null; then
        sed -i 's|^PrintMotd.*|PrintMotd yes|' "$sshd_cfg"
    else
        echo "PrintMotd yes" >> "$sshd_cfg"
    fi

    # Step 4: Validate config before touching the running service
    if ! sshd -t 2>/dev/null; then
        log_error "BANNER CONFIG FAILED SSHD SYNTAX CHECK — REVERTING BANNER"
        sed -i '/^Banner /d' "$sshd_cfg" 2>/dev/null
        return 1
    fi

    # Step 5: Restart (not reload) so sshd re-reads banner path for new connections
    systemctl restart sshd 2>/dev/null || \
        systemctl restart ssh  2>/dev/null || \
        service ssh restart    2>/dev/null || true

    log_success "SSH BANNER ACTIVE — WILL SHOW ON NEXT CONNECTION"
}

#============================================================
# AUTO-RENEW
#============================================================
run_auto_renew() {
    [[ ! -s "$USER_DB" ]] && return
    local current tmp_db renewed=0
    current=$(date +%s)
    tmp_db=$(mktemp)

    while IFS='|' read -r user pass exp created gb_limit acc_status ar_days ar_trigger conn_limit; do
        [[ -z "$user" ]] && continue
        ar_days=${ar_days:-0}; ar_trigger=${ar_trigger:-0}; acc_status=${acc_status:-active}; conn_limit=${conn_limit:-0}

        if [[ "$ar_days" -gt 0 && "$acc_status" != "locked" ]]; then
            local exp_unix days_left
            exp_unix=$(date -d "$exp" +%s 2>/dev/null || echo 0)
            days_left=$(( (exp_unix - current) / 86400 ))
            if [[ $days_left -le $ar_trigger ]]; then
                local new_exp
                new_exp=$(date -d "+$ar_days days" +"%Y-%m-%d")
                chage -E "$new_exp" "$user" 2>/dev/null
                echo "$user|$pass|$new_exp|$created|${gb_limit:-0}|active|$ar_days|$ar_trigger|$conn_limit" >> "$tmp_db"
                log_success "AUTO-RENEW: $user → $new_exp (+${ar_days}d)"
                renewed=$((renewed + 1))
                continue
            fi
        fi
        echo "$user|$pass|$exp|$created|${gb_limit:-0}|$acc_status|$ar_days|$ar_trigger|$conn_limit" >> "$tmp_db"
    done < "$USER_DB"

    mv "$tmp_db" "$USER_DB"
    [[ $renewed -gt 0 ]] && update_motd_script
}

toggle_auto_renew() {
    show_banner
    dtitle "♻️  AUTO-RENEW SETTINGS"
    dsep
    echo ""
    [[ ! -s "$USER_DB" ]] && { log_error "NO USERS FOUND"; press_enter; return; }

    echo -e "${YELLOW}USERS AND AUTO-RENEW STATUS:${NC}"
    echo ""
    while IFS='|' read -r user _ _ _ _ _ ar_days ar_trigger _; do
        [[ -z "$user" ]] && continue
        ar_days=${ar_days:-0}
        [[ "$ar_days" -gt 0 ]] && echo -e "  ${GREEN}🔄 $user${NC} → RENEW ${ar_days}d (TRIGGER: ${ar_trigger}d BEFORE EXPIRY)" || echo -e "  ${RED}⏹  $user${NC} → AUTO-RENEW DISABLED"
    done < "$USER_DB"
    echo ""

    read -rp "USERNAME: " username
    [[ -z "$username" ]] && { log_error "USERNAME REQUIRED"; press_enter; return; }

    local user_line
    user_line=$(grep "^$username|" "$USER_DB")
    [[ -z "$user_line" ]] && { log_error "USER NOT FOUND"; press_enter; return; }
    IFS='|' read -r u pass exp created gb_limit acc_status ar_days ar_trigger conn_limit <<< "$user_line"

    echo ""
    echo -e "  ${RED}1)${NC} DISABLE AUTO-RENEW"
    echo -e "  ${CYAN}2)${NC} RENEW 7 DAYS (TRIGGER: 1 DAY BEFORE)"
    echo -e "  ${CYAN}3)${NC} RENEW 30 DAYS (TRIGGER: 3 DAYS BEFORE)"
    echo -e "  ${CYAN}4)${NC} RENEW 30 DAYS (TRIGGER: 7 DAYS BEFORE)"
    echo -e "  ${CYAN}5)${NC} RENEW 90 DAYS (TRIGGER: 7 DAYS BEFORE)"
    echo -e "  ${CYAN}6)${NC} CUSTOM"
    echo ""
    read -rp "CHOICE [1-6]: " ar_choice

    case ${ar_choice:-1} in
        1) new_ar=0; new_tr=0 ;;
        2) new_ar=7;  new_tr=1 ;;
        3) new_ar=30; new_tr=3 ;;
        4) new_ar=30; new_tr=7 ;;
        5) new_ar=90; new_tr=7 ;;
        6) read -rp "RENEW FOR HOW MANY DAYS: " new_ar; read -rp "TRIGGER HOW MANY DAYS BEFORE EXPIRY: " new_tr
           [[ ! "$new_ar" =~ ^[0-9]+$ ]] && new_ar=30
           [[ ! "$new_tr" =~ ^[0-9]+$ ]] && new_tr=3 ;;
        *) new_ar=0; new_tr=0 ;;
    esac

    sed -i "/^$username|/c\\$username|$pass|$exp|$created|${gb_limit:-0}|${acc_status:-active}|$new_ar|$new_tr|${conn_limit:-0}" "$USER_DB"
    [[ "$new_ar" -gt 0 ]] && log_success "AUTO-RENEW ENABLED: $username → ${new_ar}d (TRIGGER: ${new_tr}d BEFORE)" || log_success "AUTO-RENEW DISABLED FOR $username"
    press_enter
}

view_auto_renew_status() {
    show_banner
    dtitle "📊 AUTO-RENEW STATUS"
    dsep
    echo ""
    [[ ! -s "$USER_DB" ]] && { echo -e "${YELLOW}NO USERS.${NC}"; press_enter; return; }

    local current
    current=$(date +%s)

    printf "${CYAN}╔${NC}${WHITE}%-14s${NC}${CYAN}┬${NC}${WHITE}%-12s${NC}${CYAN}┬${NC}${WHITE}%-10s${NC}${CYAN}┬${NC}${WHITE}%-16s${NC}${CYAN}┬${NC}${WHITE}%-12s${NC}${CYAN}╗${NC}\n" \
        " USERNAME" " EXPIRES" " DAYS" " AUTO-RENEW" " TRIGGER"
    echo -e "${CYAN}╠══════════════╪════════════╪══════════╪════════════════╪════════════╣${NC}"

    while IFS='|' read -r user _ exp _ _ _ ar_days ar_trigger _; do
        [[ -z "$user" ]] && continue
        ar_days=${ar_days:-0}; ar_trigger=${ar_trigger:-0}
        local exp_unix days_left
        exp_unix=$(date -d "$exp" +%s 2>/dev/null || echo 0)
        days_left=$(( (exp_unix - current) / 86400 ))
        [[ $days_left -lt 0 ]] && days_left=0

        local ar_display tr_display days_col
        [[ "$ar_days" -gt 0 ]] && ar_display="${GREEN}${ar_days}d${NC}" || ar_display="${RED}OFF${NC}"
        [[ "$ar_days" -gt 0 ]] && tr_display="${YELLOW}${ar_trigger}d BEFORE${NC}" || tr_display="${RED}---${NC}"
        [[ $days_left -le 3 ]] && days_col="${RED}" || days_col="${GREEN}"

        printf "${CYAN}║${NC} %-12s ${CYAN}│${NC} %-10s ${CYAN}│${NC} " "$user" "$exp"
        echo -ne "${days_col}${days_left}d${NC}"
        printf "       ${CYAN}│${NC} "
        echo -ne "$ar_display"
        printf "          ${CYAN}│${NC} "
        echo -e "$tr_display ${CYAN}║${NC}"
    done < "$USER_DB"

    echo -e "${CYAN}╚══════════════╧════════════╧══════════╧════════════════╧════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}PRESS 'R' TO RUN AUTO-RENEW NOW, OR ENTER TO GO BACK:${NC}"
    read -rp "" run_now
    [[ "${run_now,,}" == "r" ]] && { run_auto_renew; log_success "AUTO-RENEW EXECUTED"; }
    press_enter
}

#============================================================
# BACKUP & RESTORE
#============================================================
backup_users() {
    show_banner
    dtitle "💾 BACKUP USERS"
    dsep
    echo ""

    local ts backup_file tmp_bk
    ts=$(date +"%Y%m%d_%H%M%S")
    backup_file="$BACKUP_DIR/bk_users_${ts}.tar.gz"

    fun_bar "sleep 1" "PREPARING BACKUP"

    tmp_bk=$(mktemp -d)
    cp "$USER_DB" "$tmp_bk/users.txt" 2>/dev/null
    cp -r "$USAGE_DIR" "$tmp_bk/usage" 2>/dev/null
    [[ -f "$INSTALL_DIR/connection_info.txt" ]] && cp "$INSTALL_DIR/connection_info.txt" "$tmp_bk/" 2>/dev/null
    [[ -f "$BANNER_FILE" ]] && cp "$BANNER_FILE" "$tmp_bk/ssh_banner" 2>/dev/null
    echo "BLACK KILLER SSH Manager Backup" > "$tmp_bk/info.txt"
    echo "Date: $(date)" >> "$tmp_bk/info.txt"
    echo "Users: $(grep -c . "$USER_DB" 2>/dev/null || echo 0)" >> "$tmp_bk/info.txt"

    tar -czf "$backup_file" -C "$tmp_bk" . 2>/dev/null
    rm -rf "$tmp_bk"

    if [[ -f "$backup_file" ]]; then
        local size
        size=$(du -sh "$backup_file" | cut -f1)
        dbox_top
        log_success "BACKUP SUCCESSFUL!"
        echo ""
        echo -e "  ${WHITE}📦 FILE   :${NC} ${GREEN}$backup_file${NC}"
        echo -e "  ${WHITE}📏 SIZE   :${NC} ${CYAN}$size${NC}"
        echo -e "  ${WHITE}📅 DATE   :${NC} ${YELLOW}$(date)${NC}"
        dbox_bot
    else
        log_error "BACKUP FAILED"
    fi

    echo ""
    press_enter
}

restore_users() {
    show_banner
    dtitle "📥 RESTORE USERS"
    dsep
    echo ""

    local backups=()
    while IFS= read -r f; do backups+=("$f"); done < <(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null)

    if [[ ${#backups[@]} -eq 0 ]]; then
        log_error "NO BACKUPS FOUND IN $BACKUP_DIR"
        press_enter; return
    fi

    echo -e "${YELLOW}AVAILABLE BACKUPS:${NC}"
    echo ""
    local i=1
    for f in "${backups[@]}"; do
        local sz dt
        sz=$(du -sh "$f" 2>/dev/null | cut -f1)
        dt=$(basename "$f" | sed 's/bk_users_//;s/.tar.gz//' | sed 's/_/ /')
        echo -e "  ${CYAN}$i)${NC} $(basename "$f")  ${WHITE}[$sz]${NC}  ${YELLOW}$dt${NC}"
        i=$((i+1))
    done
    echo ""
    read -rp "SELECT BACKUP NUMBER [1-${#backups[@]}]: " bk_choice

    if ! [[ "$bk_choice" =~ ^[0-9]+$ ]] || [[ $bk_choice -lt 1 || $bk_choice -gt ${#backups[@]} ]]; then
        log_error "INVALID SELECTION"
        press_enter; return
    fi

    local selected="${backups[$((bk_choice-1))]}"
    echo ""
    echo -e "  ${CYAN}1)${NC} MERGE — ADD USERS FROM BACKUP (KEEP EXISTING)"
    echo -e "  ${RED}2)${NC} REPLACE — DELETE ALL AND RESTORE BACKUP"
    echo ""
    read -rp "CHOICE [1-2]: " restore_type

    echo ""
    echo -e "${RED}⚠ RESTORE FROM: $(basename "$selected")${NC}"
    read -rp "TYPE 'yes' TO CONFIRM: " confirm
    [[ "$confirm" != "yes" ]] && { echo -e "${YELLOW}CANCELLED${NC}"; press_enter; return; }

    local tmp_restore restored=0 skipped=0
    tmp_restore=$(mktemp -d)
    tar -xzf "$selected" -C "$tmp_restore" 2>/dev/null

    if [[ ! -f "$tmp_restore/users.txt" ]]; then
        log_error "INVALID BACKUP — users.txt NOT FOUND"
        rm -rf "$tmp_restore"
        press_enter; return
    fi

    while IFS='|' read -r user pass exp created gb_limit acc_status ar_days ar_trigger conn_limit; do
        [[ -z "$user" ]] && continue
        [[ "$restore_type" == "2" ]] && grep -q "^$user|" "$USER_DB" 2>/dev/null && {
            sed -i "/^$user|/d" "$USER_DB"; pkill -u "$user" 2>/dev/null || true; userdel -r "$user" 2>/dev/null || true
        }
        grep -q "^$user|" "$USER_DB" 2>/dev/null && { skipped=$((skipped+1)); continue; }
        useradd -m -s /bin/bash "$user" 2>/dev/null
        echo "$user:$pass" | chpasswd 2>/dev/null
        chage -E "$exp" "$user" 2>/dev/null
        echo "$user|$pass|$exp|$created|${gb_limit:-0}|${acc_status:-active}|${ar_days:-0}|${ar_trigger:-0}|${conn_limit:-0}" >> "$USER_DB"
        setup_user_quota "$user" "${gb_limit:-0}"
        restored=$((restored+1))
    done < "$tmp_restore/users.txt"

    [[ -d "$tmp_restore/usage" ]] && cp -n "$tmp_restore/usage/"* "$USAGE_DIR/" 2>/dev/null
    [[ -f "$tmp_restore/ssh_banner" && ! -f "$BANNER_FILE" ]] && cp "$tmp_restore/ssh_banner" "$BANNER_FILE" 2>/dev/null
    rm -rf "$tmp_restore"
    update_motd_script

    log_success "RESTORE COMPLETE! RESTORED: $restored | SKIPPED: $skipped"
    press_enter
}

manage_backup_restore() {
    while true; do
        show_banner
        dtitle "💾 BACKUP & RESTORE"
        dsep
        echo ""
        local count
        count=$(ls "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
        echo -e "  ${WHITE}📦 AVAILABLE BACKUPS: ${CYAN}$count${NC}"
        echo ""
        echo -e "  ${GREEN}1)${NC} 💾 CREATE BACKUP NOW"
        echo -e "  ${YELLOW}2)${NC} 📥 RESTORE FROM BACKUP"
        echo -e "  ${RED}3)${NC} 🗑️  MANAGE / DELETE BACKUPS"
        echo -e "  ${WHITE}0)${NC} ⬅️  BACK"
        echo ""
        read -rp "CHOICE: " choice
        case $choice in
            1) backup_users ;;
            2) restore_users ;;
            3)
                show_banner
                dtitle "🗑️  MANAGE BACKUPS"
                dsep
                echo ""
                ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | awk '{print NR") "$NF"  ("$5")"}' || echo "  NO BACKUPS"
                echo ""
                echo -e "  ${RED}1)${NC} DELETE SPECIFIC BACKUP"
                echo -e "  ${RED}2)${NC} DELETE ALL EXCEPT LATEST"
                echo -e "  ${WHITE}0)${NC} BACK"
                echo ""
                read -rp "CHOICE: " del_choice
                case $del_choice in
                    1)
                        read -rp "BACKUP NUMBER TO DELETE: " del_num
                        local files=("$BACKUP_DIR"/*.tar.gz)
                        local idx=$(( del_num - 1 ))
                        if [[ -f "${files[$idx]}" ]]; then
                            rm -f "${files[$idx]}"
                            log_success "BACKUP DELETED"
                        else
                            log_error "INVALID NUMBER"
                        fi
                        ;;
                    2)
                        local newest deleted=0
                        newest=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -1)
                        for f in "$BACKUP_DIR"/*.tar.gz; do
                            [[ "$f" == "$newest" ]] && continue
                            rm -f "$f"; deleted=$((deleted+1))
                        done
                        log_success "$deleted BACKUPS DELETED. LATEST PRESERVED."
                        ;;
                esac
                press_enter
                ;;
            0) return ;;
            *) log_error "INVALID CHOICE"; sleep 1 ;;
        esac
    done
}

#============================================================
# ★ SSH CONNECTION MONITOR (REAL-TIME)
#============================================================
ssh_monitor() {
    if ! command -v who &>/dev/null; then
        log_error "who COMMAND NOT AVAILABLE"
        press_enter; return
    fi

    while true; do
        clear
        dtitle "👁️  ACTIVE SSH CONNECTIONS — REAL-TIME MONITOR"
        dsep
        echo ""

        local total_sessions=0
        declare -A user_ips user_sessions

        while IFS= read -r line; do
            local wuser wip
            wuser=$(echo "$line" | awk '{print $1}')
            wip=$(echo "$line" | awk '{print $5}' | tr -d '()')
            [[ -z "$wuser" || "$wuser" == "NAME" ]] && continue
            user_sessions["$wuser"]=$(( ${user_sessions["$wuser"]:-0} + 1 ))
            user_ips["$wuser"]="$wip"
            total_sessions=$((total_sessions + 1))
        done < <(who 2>/dev/null)

        printf "${CYAN}╔${NC}${WHITE}%-20s${NC}${CYAN}┬${NC}${WHITE}%-20s${NC}${CYAN}┬${NC}${WHITE}%-12s${NC}${CYAN}┬${NC}${WHITE}%-10s${NC}${CYAN}╗${NC}\n" \
            " USER" " IP ADDRESS" " SESSIONS" " STATUS"
        echo -e "${CYAN}╠════════════════════╪════════════════════╪════════════╪══════════╣${NC}"

        if [[ ${#user_sessions[@]} -eq 0 ]]; then
            printf "${CYAN}║${NC}  ${YELLOW}%-64s${NC}${CYAN}║${NC}\n" "NO ACTIVE CONNECTIONS"
        else
            for wuser in "${!user_sessions[@]}"; do
                local sessions="${user_sessions[$wuser]}"
                local ip="${user_ips[$wuser]:-UNKNOWN}"

                local status_col
                if [[ "$sessions" -gt 0 ]]; then
                    status_col="${GREEN}ONLINE${NC}"
                else
                    status_col="${YELLOW}IDLE${NC}"
                fi

                printf "${CYAN}║${NC} %-18s ${CYAN}│${NC} %-18s ${CYAN}│${NC} " "$wuser" "$ip"
                echo -ne "   ${GREEN}$sessions${NC}"
                printf "         ${CYAN}│${NC} "
                echo -e "$status_col ${CYAN}║${NC}"
            done
        fi

        echo -e "${CYAN}╚════════════════════╧════════════════════╧════════════╧══════════╝${NC}"
        echo ""
        echo -e "  ${WHITE}TOTAL ONLINE SESSIONS: ${GREEN}$total_sessions${NC}"
        echo ""
        dsep
        echo -e "${YELLOW}  AUTO-REFRESH EVERY 5 SECONDS — PRESS 'q' + ENTER TO EXIT${NC}"
        dsep

        unset user_sessions user_ips
        declare -A user_sessions user_ips

        read -rt 5 -n 1 key && [[ "$key" == "q" ]] && return
    done
}


#============================================================
# ★ SERVER OPTIMIZER
#============================================================
server_optimizer() {
    while true; do
        show_banner
        dtitle "⚙️  SERVER OPTIMIZER"
        dsep
        echo ""

        local mem_total mem_used mem_free
        mem_total=$(free -h | awk '/^Mem:/{print $2}')
        mem_used=$(free -h | awk '/^Mem:/{print $3}')
        mem_free=$(free -h | awk '/^Mem:/{print $4}')
        local mem_pct
        mem_pct=$(free | awk '/^Mem:/{printf "%.0f", $3/$2*100}')

        echo -e "  ${WHITE}RAM:${NC} ${CYAN}${mem_used}/${mem_total}${NC} (${YELLOW}${mem_pct}% USED${NC})  ${WHITE}FREE: ${GREEN}${mem_free}${NC}"
        echo ""
        dsep
        echo ""
        echo -e "  ${GREEN}1)${NC} 📦 UPDATE PACKAGES (apt update/upgrade)"
        echo -e "  ${CYAN}2)${NC} 🧹 CLEAN RAM CACHE (FREE MEMORY)"
        echo -e "  ${YELLOW}3)${NC} 🗑️  REMOVE UNUSED PACKAGES (autoremove/autoclean)"
        echo -e "  ${PURPLE}4)${NC} ⚡ FULL OPTIMIZE (ALL AT ONCE)"
        echo -e "  ${WHITE}0)${NC} ⬅️  BACK"
        echo ""
        read -rp "CHOICE: " opt_choice

        case $opt_choice in
            1)
                echo ""
                fun_bar "apt-get update -y" "UPDATING PACKAGE LIST"
                fun_bar "apt-get upgrade -y" "UPGRADING PACKAGES"
                fun_bar "apt-get -f install -y" "FIXING DEPENDENCIES"
                echo ""
                log_success "PACKAGES UPDATED SUCCESSFULLY"
                press_enter
                ;;
            2)
                echo ""
                local mem_before
                mem_before=$(free | awk '/^Mem:/{printf "%.0f", $3/$2*100}')

                fun_bar "sync && echo 3 > /proc/sys/vm/drop_caches && sync && swapoff -a && swapon -a" "CLEANING RAM CACHE"

                local mem_after
                mem_after=$(free | awk '/^Mem:/{printf "%.0f", $3/$2*100}')
                local saved=$(( mem_before - mem_after ))

                echo ""
                dsep
                echo -e "  ${WHITE}RAM BEFORE CLEANUP:${NC} ${YELLOW}${mem_before}%${NC}"
                echo -e "  ${WHITE}RAM AFTER CLEANUP :${NC} ${GREEN}${mem_after}%${NC}"
                echo -e "  ${WHITE}MEMORY FREED      :${NC} ${GREEN}${saved}%${NC}"
                dsep
                press_enter
                ;;
            3)
                echo ""
                fun_bar "apt-get autoremove -y" "REMOVING UNUSED PACKAGES"
                fun_bar "apt-get autoclean -y" "CLEANING PACKAGE CACHE"
                fun_bar "apt-get clean -y" "CLEANING APT CACHE"
                echo ""
                log_success "UNUSED PACKAGES REMOVED"
                press_enter
                ;;
            4)
                echo ""
                fun_bar "apt-get update -y" "UPDATING PACKAGE LIST"
                fun_bar "apt-get upgrade -y" "UPGRADING PACKAGES"
                fun_bar "apt-get -f install -y" "FIXING DEPENDENCIES"
                fun_bar "apt-get autoremove -y" "REMOVING UNUSED PACKAGES"
                fun_bar "apt-get autoclean -y && apt-get clean -y" "CLEANING CACHE"
                fun_bar "sync && echo 3 > /proc/sys/vm/drop_caches && sync && swapoff -a && swapon -a" "CLEANING RAM"
                echo ""
                dbox_top
                log_success "FULL OPTIMIZATION COMPLETE!"
                local mem_final
                mem_final=$(free | awk '/^Mem:/{printf "%.0f", $3/$2*100}')
                echo -e "  ${WHITE}RAM USAGE NOW: ${GREEN}${mem_final}%${NC}"
                dbox_bot
                press_enter
                ;;
            0) return ;;
            *) log_error "INVALID CHOICE"; sleep 1 ;;
        esac
    done
}

#============================================================
# ★ VPS INFO PANEL (ENHANCED)
#============================================================
vps_info_panel() {
    show_banner
    dtitle "📊 VPS INFORMATION PANEL"
    dsep
    echo ""

    # CPU Info
    local cpu_model cpu_cores cpu_usage
    cpu_model=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs)
    cpu_cores=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "?")
    cpu_usage=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print 100-$8}' | cut -d. -f1)
    [[ -z "$cpu_usage" ]] && cpu_usage=$(vmstat 1 1 2>/dev/null | tail -1 | awk '{print 100-$15}')

    # RAM Info
    local ram_total ram_used ram_free ram_pct
    ram_total=$(free -h | awk '/^Mem:/{print $2}')
    ram_used=$(free -h | awk '/^Mem:/{print $3}')
    ram_free=$(free -h | awk '/^Mem:/{print $4}')
    ram_pct=$(free | awk '/^Mem:/{printf "%.1f", $3/$2*100}')

    # SWAP
    local swap_total swap_used
    swap_total=$(free -h | awk '/^Swap:/{print $2}')
    swap_used=$(free -h | awk '/^Swap:/{print $3}')

    # Disk
    local disk_total disk_used disk_free disk_pct
    disk_total=$(df -h / | awk 'NR==2{print $2}')
    disk_used=$(df -h / | awk 'NR==2{print $3}')
    disk_free=$(df -h / | awk 'NR==2{print $4}')
    disk_pct=$(df / | awk 'NR==2{print $5}')

    # Uptime
    local uptime_str
    uptime_str=$(uptime -p 2>/dev/null || uptime | awk -F'up' '{print $2}' | cut -d',' -f1,2 | xargs)

    # OS
    local os_name
    os_name=$(lsb_release -ds 2>/dev/null || cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Linux")

    # Kernel
    local kernel
    kernel=$(uname -r)

    # IP
    local public_ip local_ip
    public_ip=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "N/A")
    local_ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)

    # Load average
    local load_avg
    load_avg=$(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}')

    # Active ports
    local open_ports
    open_ports=$(ss -tlnp 2>/dev/null | awk 'NR>1{print $4}' | grep -oE ':[0-9]+' | tr -d ':' | sort -n | tr '\n' '  ' | head -c 80)

    # Users online
    local users_online
    users_online=$(who 2>/dev/null | wc -l)

    # DNSTT status
    local dnstt_status
    systemctl is-active --quiet dnstt 2>/dev/null && dnstt_status="${GREEN}RUNNING ✓${NC}" || dnstt_status="${RED}STOPPED ✗${NC}"

    dbox_top
    echo -e "${BYELLOW}                  🖥️  VPS INFORMATION PANEL${NC}"
    dbox_bot
    echo ""

    echo -e "\E[44;1;37m  CPU INFORMATION  \E[0m"
    echo -e "  ${WHITE}MODEL   :${NC} ${CYAN}${cpu_model:-N/A}${NC}"
    echo -e "  ${WHITE}CORES   :${NC} ${CYAN}${cpu_cores}${NC}"
    echo -e "  ${WHITE}USAGE   :${NC} ${YELLOW}${cpu_usage:-N/A}%${NC}"
    echo -e "  ${WHITE}LOAD    :${NC} ${CYAN}${load_avg}${NC}"
    echo ""

    echo -e "\E[44;1;37m  MEMORY INFORMATION  \E[0m"
    echo -e "  ${WHITE}RAM TOTAL :${NC} ${CYAN}${ram_total}${NC}"
    echo -e "  ${WHITE}RAM USED  :${NC} ${YELLOW}${ram_used} (${ram_pct}%)${NC}"
    echo -e "  ${WHITE}RAM FREE  :${NC} ${GREEN}${ram_free}${NC}"
    echo -e "  ${WHITE}SWAP      :${NC} ${CYAN}${swap_used} / ${swap_total}${NC}"
    echo ""

    echo -e "\E[44;1;37m  DISK INFORMATION  \E[0m"
    echo -e "  ${WHITE}TOTAL     :${NC} ${CYAN}${disk_total}${NC}"
    echo -e "  ${WHITE}USED      :${NC} ${YELLOW}${disk_used} (${disk_pct})${NC}"
    echo -e "  ${WHITE}FREE      :${NC} ${GREEN}${disk_free}${NC}"
    echo ""

    echo -e "\E[44;1;37m  SYSTEM INFORMATION  \E[0m"
    echo -e "  ${WHITE}OS        :${NC} ${CYAN}${os_name}${NC}"
    echo -e "  ${WHITE}KERNEL    :${NC} ${CYAN}${kernel}${NC}"
    echo -e "  ${WHITE}UPTIME    :${NC} ${GREEN}${uptime_str}${NC}"
    echo -e "  ${WHITE}PUBLIC IP :${NC} ${YELLOW}${public_ip}${NC}"
    echo -e "  ${WHITE}LOCAL IP  :${NC} ${CYAN}${local_ip:-N/A}${NC}"
    echo ""

    echo -e "\E[44;1;37m  TUNNEL STATUS  \E[0m"
    echo -ne "  ${WHITE}DNSTT     :${NC} "; echo -e "$dnstt_status"
    echo -e "  ${WHITE}USERS     :${NC} ${GREEN}${users_online} ONLINE${NC}"
    local cur_mtu cur_dom
    cur_mtu=$(cat "$INSTALL_DIR/mtu.txt" 2>/dev/null || echo "N/A")
    cur_dom=$(cat "$INSTALL_DIR/tunnel_domain.txt" 2>/dev/null || echo "N/A")
    echo -e "  ${WHITE}MTU       :${NC} ${CYAN}${cur_mtu}${NC}"
    echo -e "  ${WHITE}DOMAIN    :${NC} ${CYAN}${cur_dom}${NC}"
    echo ""

    echo -e "\E[44;1;37m  OPEN PORTS  \E[0m"
    echo -e "  ${CYAN}${open_ports:-N/A}${NC}"
    echo ""

    dsep
    press_enter
}

#============================================================
# ★ EXPIRED USERS AUTO-CLEANER
#============================================================
expired_users_cleaner() {
    show_banner
    dtitle "🧹 EXPIRED USERS AUTO-CLEANER"
    dsep
    echo ""

    [[ ! -s "$USER_DB" ]] && { echo -e "${YELLOW}NO USERS FOUND${NC}"; press_enter; return; }

    local current expired_list=()
    current=$(date +%s)

    while IFS='|' read -r user _ exp _ _ acc_status _rest; do
        [[ -z "$user" ]] && continue
        local exp_unix
        exp_unix=$(date -d "$exp" +%s 2>/dev/null || echo 0)
        if [[ $current -gt $exp_unix ]]; then
            expired_list+=("$user")
        fi
    done < "$USER_DB"

    if [[ ${#expired_list[@]} -eq 0 ]]; then
        echo -e "${GREEN}✅ NO EXPIRED USERS FOUND — ALL USERS ARE ACTIVE${NC}"
        press_enter; return
    fi

    echo -e "${YELLOW}THE FOLLOWING USERS HAVE EXPIRED:${NC}"
    echo ""
    for u in "${expired_list[@]}"; do
        echo -e "  ${RED}✗ $u${NC}"
    done
    echo ""
    echo -e "${WHITE}TOTAL EXPIRED: ${RED}${#expired_list[@]}${NC}"
    echo ""
    dsep
    echo ""
    echo -e "  ${RED}1)${NC} DELETE ALL EXPIRED USERS NOW"
    echo -e "  ${YELLOW}2)${NC} LOCK ALL EXPIRED USERS (KEEP ACCOUNTS)"
    echo -e "  ${WHITE}0)${NC} CANCEL — GO BACK"
    echo ""
    read -rp "CHOICE: " clean_choice

    case $clean_choice in
        1)
            echo ""
            read -rp "TYPE 'yes' TO CONFIRM DELETION OF ${#expired_list[@]} USERS: " confirm
            [[ "$confirm" != "yes" ]] && { echo -e "${YELLOW}CANCELLED${NC}"; press_enter; return; }
            echo ""
            local deleted=0
            for u in "${expired_list[@]}"; do
                # Do NOT pass $u through fun_bar/eval — execute directly with quoted args
                echo -ne "  ${BYELLOW}◇ DELETING USER $u ${WHITE}- ${BYELLOW}[${BRED}##################${BYELLOW}]${BGREEN} OK!${NC}\n"
                pkill -u "$u" 2>/dev/null || true
                userdel -r "$u" 2>/dev/null || true
                sed -i "/^$(printf '%s' "$u" | sed 's/[[\.*^$()+?{}|]/\\&/g')|/d" "$USER_DB"
                rm -f "$USAGE_DIR/$u"
                log_success "USER $u DELETED"
                deleted=$((deleted+1))
            done
            update_motd_script
            echo ""
            log_success "CLEANUP COMPLETE: $deleted EXPIRED USERS DELETED"
            ;;
        2)
            echo ""
            local locked=0
            for u in "${expired_list[@]}"; do
                passwd -l "$u" 2>/dev/null
                pkill -u "$u" 2>/dev/null || true
                sed -i "/^$u|/s/|active|/|locked|/" "$USER_DB"
                log_success "USER $u LOCKED"
                locked=$((locked+1))
            done
            update_motd_script
            echo ""
            log_success "CLEANUP COMPLETE: $locked EXPIRED USERS LOCKED"
            ;;
        0) return ;;
        *) log_error "INVALID CHOICE"; sleep 1 ;;
    esac
    press_enter
}

#============================================================
# ★ SCRIPT AUTO-UPDATER
#============================================================
check_for_updates() {
    show_banner
    dtitle "🔄 SCRIPT AUTO-UPDATER"
    dsep
    echo ""

    echo -e "${CYAN}CHECKING FOR UPDATES...${NC}"
    echo ""

    local latest_ver
    latest_ver=$(curl -s --max-time 10 "$GITHUB_VER" 2>/dev/null | tr -d '[:space:]')

    if [[ -z "$latest_ver" ]]; then
        # Fallback: extract version from script header (robust grep)
        latest_ver=$(curl -s --max-time 15 "$GITHUB_RAW" 2>/dev/null | grep -oP '^SCRIPT_VERSION="\K[^"]+' | head -1)
    fi
    # Validate version format (must be digits and dots only)
    if [[ -n "$latest_ver" && ! "$latest_ver" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        log_error "INVALID VERSION STRING RECEIVED: '$latest_ver' — ABORTING UPDATE"
        press_enter; return
    fi

    if [[ -z "$latest_ver" ]]; then
        log_error "COULD NOT REACH GITHUB. CHECK INTERNET CONNECTION."
        press_enter; return
    fi

    dbox_top
    echo -e "  ${WHITE}CURRENT VERSION :${NC} ${YELLOW}v${SCRIPT_VERSION}${NC}"
    echo -e "  ${WHITE}LATEST VERSION  :${NC} ${GREEN}v${latest_ver}${NC}"
    dbox_bot
    echo ""

    if [[ "$latest_ver" == "$SCRIPT_VERSION" ]]; then
        echo -e "${GREEN}✅ YOUR SCRIPT IS UP TO DATE!${NC}"
        press_enter; return
    fi

    echo -e "${YELLOW}⚡ NEW VERSION AVAILABLE: v${SCRIPT_VERSION} → v${latest_ver}${NC}"
    echo ""
    read -rp "UPDATE NOW? [y/n]: " update_choice
    [[ "${update_choice,,}" != "y" ]] && { echo -e "${YELLOW}UPDATE CANCELLED${NC}"; press_enter; return; }

    echo ""
    local script_path
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    # mktemp creates a unique file owned by root (600 perms) — no symlink race possible
    local tmp_update
    tmp_update=$(mktemp /tmp/slowdns_update_XXXXXX.sh)
    chmod 600 "$tmp_update"

    fun_bar "curl -fsSL '$GITHUB_RAW' -o '$tmp_update'" "DOWNLOADING v${latest_ver}"

    if [[ ! -s "$tmp_update" ]]; then
        log_error "DOWNLOAD FAILED. TRY AGAIN LATER."
        rm -f "$tmp_update"
        press_enter; return
    fi

    # INTEGRITY CHECKS — verify the download is a legitimate script
    if ! head -1 "$tmp_update" | grep -q "^#!/bin/bash"; then
        log_error "INTEGRITY CHECK FAILED: NOT A VALID BASH SCRIPT"
        rm -f "$tmp_update"; press_enter; return
    fi
    if ! grep -q "BLACK KILLER" "$tmp_update" 2>/dev/null; then
        log_error "INTEGRITY CHECK FAILED: SIGNATURE NOT FOUND IN DOWNLOAD"
        rm -f "$tmp_update"; press_enter; return
    fi
    if ! bash -n "$tmp_update" 2>/dev/null; then
        log_error "INTEGRITY CHECK FAILED: SCRIPT HAS SYNTAX ERRORS"
        rm -f "$tmp_update"; press_enter; return
    fi
    # Minimum size guard (real script must be > 50KB)
    local file_size
    file_size=$(wc -c < "$tmp_update")
    if [[ "$file_size" -lt 50000 ]]; then
        log_error "INTEGRITY CHECK FAILED: DOWNLOAD TOO SMALL (${file_size} bytes — possible truncation or redirect)"
        rm -f "$tmp_update"; press_enter; return
    fi

    cp "$script_path" "${script_path}.backup.$(date +%Y%m%d)" 2>/dev/null || true
    mv "$tmp_update" "$script_path"
    chmod +x "$script_path"

    dbox_top
    log_success "UPDATE COMPLETE! v${SCRIPT_VERSION} → v${latest_ver}"
    echo -e "  ${WHITE}BACKUP SAVED AS:${NC} ${script_path}.backup.$(date +%Y%m%d)"
    echo -e "  ${YELLOW}PLEASE RESTART THE SCRIPT TO USE THE NEW VERSION${NC}"
    dbox_bot
    echo ""
    press_enter
    exec bash "$script_path"
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
        local DNSTT_PID
        DNSTT_PID=$(systemctl show dnstt --property=MainPID --value)
        [[ -n "$DNSTT_PID" && "$DNSTT_PID" != "0" ]] && {
            local CPU_PCT MEM_PCT
            CPU_PCT=$(ps -o %cpu= -p $DNSTT_PID 2>/dev/null | tr -d ' ' || echo "N/A")
            MEM_PCT=$(ps -o %mem= -p $DNSTT_PID 2>/dev/null | tr -d ' ' || echo "N/A")
            echo -e "  ${WHITE}CPU     :${NC} ${CYAN}${CPU_PCT}%${NC}"
            echo -e "  ${WHITE}MEMORY  :${NC} ${CYAN}${MEM_PCT}%${NC}"
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
    journalctl -u dnstt -n 10 --no-pager
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
    echo -e "  ${CYAN}5)${NC} LIVE TAIL (REAL-TIME)"
    echo -e "  ${WHITE}0)${NC} BACK"
    echo ""
    read -rp "CHOICE: " log_choice

    case $log_choice in
        1) [[ -f "$LOG_DIR/dnstt.log" ]] && less +G "$LOG_DIR/dnstt.log" || echo -e "${RED}LOG NOT FOUND${NC}" ;;
        2) [[ -f "$LOG_DIR/dnstt-server.log" ]] && less +G "$LOG_DIR/dnstt-server.log" || echo -e "${RED}LOG NOT FOUND${NC}" ;;
        3) [[ -f "$LOG_DIR/dnstt-error.log" ]] && less +G "$LOG_DIR/dnstt-error.log" || echo -e "${RED}NO ERRORS LOGGED${NC}" ;;
        4) journalctl -u dnstt --no-pager -n 100 ;;
        5) echo -e "${YELLOW}FOLLOWING LOGS (Ctrl+C TO STOP)...${NC}"; tail -f "$LOG_DIR/dnstt-server.log" "$LOG_DIR/dnstt-error.log" ;;
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

    echo -e "\E[44;1;37m  SERVICE STATUS  \E[0m"
    systemctl is-active --quiet dnstt && echo -e "  ${GREEN}✅ DNSTT: RUNNING${NC}" || echo -e "  ${RED}❌ DNSTT: STOPPED${NC}"
    echo ""

    echo -e "\E[44;1;37m  OPTIMIZATIONS  \E[0m"
    local bbr cpu_cores load_avg
    bbr=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "N/A")
    local RMEM_MB UDP_KB BACKLOG
    RMEM_MB=$(( $(sysctl -n net.core.rmem_max 2>/dev/null || echo 0) / 1048576 ))
    UDP_KB=$(( $(sysctl -n net.ipv4.udp_rmem_min 2>/dev/null || echo 0) / 1024 ))
    BACKLOG=$(sysctl -n net.core.netdev_max_backlog 2>/dev/null || echo "0")
    echo -e "  ${WHITE}CONGESTION CONTROL :${NC} ${GREEN}${bbr}${NC}"
    echo -e "  ${WHITE}NETWORK BUFFER     :${NC} ${GREEN}${RMEM_MB}MB${NC}"
    echo -e "  ${WHITE}UDP BUFFER         :${NC} ${GREEN}${UDP_KB}KB${NC}"
    echo -e "  ${WHITE}PACKET BACKLOG     :${NC} ${GREEN}${BACKLOG}${NC}"
    echo ""

    echo -e "\E[44;1;37m  CONNECTIONS  \E[0m"
    local UDP_CONNS
    UDP_CONNS=$(ss -u state established 2>/dev/null | grep -c ':5300' || echo "0")
    echo -e "  ${WHITE}UDP ACTIVE (5300) :${NC} ${CYAN}$UDP_CONNS${NC}"
    echo -e "  ${WHITE}SSH SESSIONS     :${NC} ${CYAN}$(who 2>/dev/null | wc -l)${NC}"
    echo ""

    echo -e "\E[44;1;37m  SYSTEM RESOURCES  \E[0m"
    local MEM_TOTAL MEM_USED CPU_CORES LOAD
    MEM_TOTAL=$(free -h | awk '/^Mem:/{print $2}')
    MEM_USED=$(free -h | awk '/^Mem:/{print $3}')
    CPU_CORES=$(nproc 2>/dev/null || echo "?")
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | tr -d ' ')
    echo -e "  ${WHITE}MEMORY     :${NC} ${CYAN}${MEM_USED}/${MEM_TOTAL}${NC}"
    echo -e "  ${WHITE}CPU CORES  :${NC} ${CYAN}${CPU_CORES}${NC}"
    echo -e "  ${WHITE}LOAD AVG   :${NC} ${CYAN}${LOAD}${NC}"
    echo ""

    press_enter
}

bandwidth_test() {
    show_banner
    dtitle "📶 BANDWIDTH TEST"
    dsep
    echo ""

    if ! systemctl is-active --quiet dnstt; then
        log_error "DNSTT SERVICE IS NOT RUNNING"
        press_enter; return
    fi

    local NET_IF
    NET_IF=$(ip route | grep default | awk '{print $5}' | head -1)
    [[ -z "$NET_IF" ]] && { log_error "COULD NOT DETECT NETWORK INTERFACE"; press_enter; return; }

    local CURRENT_MTU
    CURRENT_MTU=$(cat "$INSTALL_DIR/mtu.txt" 2>/dev/null || echo "N/A")

    echo -e "${YELLOW}TESTING BANDWIDTH FOR 30 SECONDS...${NC}"
    echo -e "${WHITE}MTU: ${CYAN}${CURRENT_MTU}  |  INTERFACE: ${CYAN}$NET_IF${NC}"
    echo ""

    local RX1 TX1 PREV_RX PREV_TX PEAK_RX=0 PEAK_TX=0
    RX1=$(cat /sys/class/net/$NET_IF/statistics/rx_bytes)
    TX1=$(cat /sys/class/net/$NET_IF/statistics/tx_bytes)
    PREV_RX=$RX1; PREV_TX=$TX1

    printf "  ${WHITE}%-5s  %-14s  %-14s  %s${NC}\n" "SEC" "DOWN (Kbps)" "UP (Kbps)" "TOTAL"
    dsep_s

    for i in $(seq 1 30); do
        sleep 1
        local CUR_RX CUR_TX DIFF_RX DIFF_TX DIFF_TOT COL
        CUR_RX=$(cat /sys/class/net/$NET_IF/statistics/rx_bytes)
        CUR_TX=$(cat /sys/class/net/$NET_IF/statistics/tx_bytes)
        DIFF_RX=$(( (CUR_RX - PREV_RX) * 8 / 1000 ))
        DIFF_TX=$(( (CUR_TX - PREV_TX) * 8 / 1000 ))
        DIFF_TOT=$(( DIFF_RX + DIFF_TX ))
        [ $DIFF_RX -gt $PEAK_RX ] && PEAK_RX=$DIFF_RX
        [ $DIFF_TX -gt $PEAK_TX ] && PEAK_TX=$DIFF_TX
        [ $DIFF_TOT -gt 5000 ] && COL="${GREEN}" || { [ $DIFF_TOT -gt 1000 ] && COL="${YELLOW}" || COL="${RED}"; }
        printf "  ${CYAN}%-5s${NC}  ${COL}%-14s${NC}  ${COL}%-14s${NC}  ${COL}%s Kbps${NC}\n" "${i}s" "${DIFF_RX}" "${DIFF_TX}" "${DIFF_TOT}"
        PREV_RX=$CUR_RX; PREV_TX=$CUR_TX
    done

    local RX2 TX2 RX_MBPS TX_MBPS PEAK_RX_MBPS PEAK_TX_MBPS
    RX2=$(cat /sys/class/net/$NET_IF/statistics/rx_bytes)
    TX2=$(cat /sys/class/net/$NET_IF/statistics/tx_bytes)
    RX_MBPS=$(echo "scale=2; ($RX2-$RX1)*8/30/1000000" | bc)
    TX_MBPS=$(echo "scale=2; ($TX2-$TX1)*8/30/1000000" | bc)
    PEAK_RX_MBPS=$(echo "scale=2; $PEAK_RX/1000" | bc)
    PEAK_TX_MBPS=$(echo "scale=2; $PEAK_TX/1000" | bc)

    echo ""
    dsep
    echo -e "${WHITE}DOWNLOAD: ${GREEN}${RX_MBPS} Mbps  ${WHITE}PEAK: ${CYAN}${PEAK_RX_MBPS} Mbps${NC}"
    echo -e "${WHITE}UPLOAD  : ${GREEN}${TX_MBPS} Mbps  ${WHITE}PEAK: ${CYAN}${PEAK_TX_MBPS} Mbps${NC}"
    dsep
    press_enter
}

change_mtu() {
    show_banner
    dtitle "📊 CHANGE MTU SIZE"
    dsep
    echo ""

    [[ ! -f "$INSTALL_DIR/mtu.txt" ]] && { log_error "DNSTT NOT INSTALLED YET"; press_enter; return; }
    local CURRENT_MTU
    CURRENT_MTU=$(cat "$INSTALL_DIR/mtu.txt")
    echo -e "${YELLOW}CURRENT MTU: ${CYAN}${CURRENT_MTU} BYTES${NC}"
    echo ""
    echo -e "  ${GREEN}0)${NC} AUTO-DETECT — TEST YOUR NETWORK ⭐⭐⭐"
    echo -e "  ${CYAN}1)${NC} 192   — LOW MTU"
    echo -e "  ${CYAN}2)${NC} 256   — LOW-MEDIUM"
    echo -e "  ${CYAN}3)${NC} 512   — CLASSIC DNS"
    echo -e "  ${CYAN}4)${NC} 1024  — STANDARD"
    echo -e "  ${CYAN}5)${NC} 1232  — EDNS0 STANDARD"
    echo -e "  ${CYAN}6)${NC} 1280  — HIGH SPEED"
    echo -e "  ${CYAN}7)${NC} 1420  — VERY HIGH SPEED"
    echo -e "  ${CYAN}8)${NC} 4096  — EDNS0 MAXIMUM"
    echo -e "  ${YELLOW}9)${NC} CUSTOM (64-4096)"
    echo ""
    read -rp "CHOICE [0-9]: " mtu_choice

    local NEW_MTU=0
    case ${mtu_choice} in
        0)
            echo ""
            echo -e "${CYAN}AUTO-DETECTING BEST MTU...${NC}"
            command -v dig &>/dev/null || apt-get install -y -qq dnsutils >/dev/null 2>&1 || true
            local BEST_MTU=0 BEST_SCORE=0
            local TEST_SIZES=(64 128 192 256 320 384 512 640 768 1024 1280 1420 1480)
            printf "  %-8s  %-10s  %-6s  %s\n" "MTU" "RTT(AVG)" "OK/5" "STATUS"
            dsep_s
            for TEST_MTU in "${TEST_SIZES[@]}"; do
                local PAD=$(( TEST_MTU - 29 )); [ $PAD -lt 1 ] && PAD=1
                local LABEL="" REM=$PAD
                while [ $REM -gt 0 ]; do
                    local SEG=$REM; [ $SEG -gt 63 ] && SEG=63
                    LABEL+=$(printf 'x%.0s' $(seq 1 $SEG))
                    REM=$(( REM - SEG ))
                    [ $REM -gt 0 ] && LABEL+="."
                done
                local TOTAL=0 OK=0 FAIL=0
                for r in 1 2 3 4 5; do
                    local T0 T1 OUT
                    T0=$(date +%s%3N)
                    OUT=$(dig +time=2 +tries=1 +udp "@8.8.8.8" A "${LABEL}.google.com" 2>/dev/null)
                    T1=$(date +%s%3N)
                    echo "$OUT" | grep -qE "status: (NOERROR|NXDOMAIN)" && { TOTAL=$(echo "$TOTAL + ($T1 - $T0)" | bc); ((OK++)); } || ((FAIL++))
                done
                if [ $OK -gt 0 ]; then
                    local AVG SCORE STATUS_STR
                    AVG=$(echo "scale=0; $TOTAL / $OK" | bc)
                    SCORE=$(echo "scale=0; ($TEST_MTU * $OK * 10) / ($AVG + 1)" | bc 2>/dev/null || echo 0)
                    STATUS_STR="${GREEN}[+] OK${NC}"; [ $FAIL -gt 0 ] && STATUS_STR="${YELLOW}[~] PARTIAL${NC}"
                    printf "  %-8s  %-10s  %-6s  " "${TEST_MTU}B" "${AVG}ms" "${OK}/5"
                    echo -e "$STATUS_STR"
                    [ "$SCORE" -gt "$BEST_SCORE" ] && { BEST_SCORE=$SCORE; BEST_MTU=$TEST_MTU; }
                else
                    printf "  %-8s  %-10s  %-6s  " "${TEST_MTU}B" "timeout" "0/5"
                    echo -e "${RED}[X] NO RESPONSE${NC}"
                fi
            done
            echo ""
            [ "$BEST_MTU" -gt 0 ] && { NEW_MTU=$BEST_MTU; echo -e "${GREEN}✓ BEST MTU: ${CYAN}${NEW_MTU} BYTES${NC}"; } || { log_error "COULD NOT DETECT MTU"; press_enter; return; }
            ;;
        1) NEW_MTU=192 ;;  2) NEW_MTU=256 ;;
        3) NEW_MTU=512 ;;  4) NEW_MTU=1024 ;;
        5) NEW_MTU=1232 ;; 6) NEW_MTU=1280 ;;
        7) NEW_MTU=1420 ;; 8) NEW_MTU=4096 ;;
        9)
            read -rp "ENTER MTU (64-4096): " custom_mtu
            [[ "$custom_mtu" =~ ^[0-9]+$ ]] && [ "$custom_mtu" -ge 64 ] && [ "$custom_mtu" -le 4096 ] && NEW_MTU=$custom_mtu || { log_error "INVALID MTU"; press_enter; return; }
            ;;
        *) log_error "INVALID CHOICE"; press_enter; return ;;
    esac

    [ "$NEW_MTU" -eq 0 ] && { press_enter; return; }

    local TUNNEL_DOMAIN SSH_PORT_SAVED
    TUNNEL_DOMAIN=$(cat "$INSTALL_DIR/tunnel_domain.txt" 2>/dev/null || echo "")
    SSH_PORT_SAVED=$(cat "$INSTALL_DIR/ssh_port.txt" 2>/dev/null || echo "22")
    [[ -z "$TUNNEL_DOMAIN" ]] && { log_error "TUNNEL DOMAIN NOT FOUND. PLEASE REINSTALL."; press_enter; return; }

    echo ""
    echo -e "${CYAN}APPLYING NEW MTU: ${YELLOW}${NEW_MTU} BYTES${NC} ${CYAN}(WAS ${CURRENT_MTU})...${NC}"
    echo "$NEW_MTU" > "$INSTALL_DIR/mtu.txt"
    create_service "$TUNNEL_DOMAIN" "$NEW_MTU" "$SSH_PORT_SAVED"
    systemctl daemon-reload
    systemctl restart dnstt
    sleep 2

    if systemctl is-active --quiet dnstt; then
        log_success "MTU CHANGED TO ${NEW_MTU} BYTES — SERVICE RESTARTED"
        [ "$NEW_MTU" -le 512 ] && optimize_for_512
    else
        log_error "SERVICE FAILED AFTER MTU CHANGE"
        journalctl -u dnstt -n 10 --no-pager
    fi
    press_enter
}

fix_domain() {
    show_banner
    dtitle "🔧 FIX DOMAIN ISSUE"
    dsep
    echo ""

    [[ ! -f "$INSTALL_DIR/tunnel_domain.txt" ]] && { log_error "NO CONFIGURATION FOUND"; press_enter; return; }

    echo -e "${YELLOW}CURRENT DOMAIN:${NC}"
    cat "$INSTALL_DIR/tunnel_domain.txt"
    echo ""
    echo -e "${WHITE}ENTER THE CORRECT TUNNEL DOMAIN:${NC}"
    echo -e "${CYAN}EXAMPLE: t.yourdomain.com${NC}"
    echo ""
    read -rp "CORRECT TUNNEL DOMAIN: " correct_domain
    [[ -z "$correct_domain" ]] && { log_error "DOMAIN REQUIRED"; press_enter; return; }

    correct_domain=$(echo "$correct_domain" | sed 's/\.\.*/./g; s/\.$//')
    local MTU SSH_PORT
    MTU=$(cat "$INSTALL_DIR/mtu.txt" 2>/dev/null || echo "1420")
    SSH_PORT=$(cat "$INSTALL_DIR/ssh_port.txt" 2>/dev/null || echo "22")

    echo "$correct_domain" > "$INSTALL_DIR/tunnel_domain.txt"
    create_service "$correct_domain" "$MTU" "$SSH_PORT"
    systemctl daemon-reload
    systemctl restart dnstt
    sleep 2

    if systemctl is-active --quiet dnstt; then
        log_success "FIXED! SERVICE IS RUNNING WITH DOMAIN: $correct_domain"
    else
        log_error "STILL FAILING. CHECK LOGS:"
        journalctl -u dnstt -n 10 --no-pager
    fi
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
        echo -e "  ${CYAN}6)${NC}  📶 BANDWIDTH TEST"
        echo -e "  ${PURPLE}7)${NC}  🔧 FIX DOMAIN ISSUE"
        echo -e "  ${BLUE}8)${NC}  🔄 RESTART SERVICE"
        echo -e "  ${RED}9)${NC}  ⏹  STOP SERVICE"
        echo -e "  ${RED}10)${NC} 🗑️  UNINSTALL DNSTT"
        echo -e "  ${GREEN}11)${NC} 📊 CHANGE MTU SIZE"
        echo -e "  ${WHITE}0)${NC}  ⬅️  BACK"
        echo ""
        read -rp "CHOICE: " choice

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
                echo -e "${CYAN}RESTARTING DNSTT...${NC}"
                fun_bar "systemctl restart dnstt" "RESTARTING SERVICE"
                sleep 1
                systemctl is-active --quiet dnstt && echo -e "${GREEN}✓ SERVICE RESTARTED${NC}" || echo -e "${RED}✗ SERVICE FAILED${NC}"
                sleep 2
                ;;
            9)
                echo ""
                echo -e "${CYAN}STOPPING DNSTT...${NC}"
                systemctl stop dnstt
                echo -e "${YELLOW}SERVICE STOPPED${NC}"
                sleep 2
                ;;
            10)
                echo ""
                echo -e "${RED}⚠ WARNING: UNINSTALL DNSTT${NC}"
                echo ""
                read -rp "TYPE 'yes' TO CONFIRM: " confirm
                if [[ "$confirm" == "yes" ]]; then
                    fun_bar "systemctl stop dnstt 2>/dev/null; systemctl disable dnstt 2>/dev/null; rm -f /etc/systemd/system/dnstt.service; rm -rf $INSTALL_DIR $LOG_DIR; rm -f $DNSTT_SERVER $DNSTT_CLIENT; rm -f /etc/sysctl.d/99-dnstt-*.conf; rm -f /etc/security/limits.d/99-dnstt-*.conf; systemctl daemon-reload" "UNINSTALLING DNSTT"
                    [[ -f /etc/ssh/sshd_config.backup ]] && { cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config; systemctl restart sshd 2>/dev/null || true; }
                    echo -e "${GREEN}✓ DNSTT FULLY UNINSTALLED${NC}"
                    sleep 2
                else
                    echo -e "${YELLOW}CANCELLED${NC}"; sleep 1
                fi
                ;;
            11) change_mtu ;;
            0) return ;;
            *) log_error "INVALID CHOICE"; sleep 1 ;;
        esac
    done
}

ssh_menu() {
    run_auto_renew 2>/dev/null
    while true; do
        show_banner
        dtitle "👥 SSH USER MANAGEMENT"
        dsep
        echo ""

        if [[ -s "$USER_DB" ]]; then
            local total_users active_users locked_users auto_renew_count current
            total_users=$(grep -c . "$USER_DB" 2>/dev/null || echo 0)
            active_users=0; locked_users=0; auto_renew_count=0
            current=$(date +%s)

            while IFS='|' read -r user _ exp _ _ acc_status ar_days ar_trigger conn_limit; do
                # DB: user|pass|exp|created|gb_limit|status|ar_days|ar_trigger|conn_limit
                [[ -z "$user" ]] && continue
                acc_status=${acc_status:-active}
                ar_days=${ar_days:-0}
                [[ "$acc_status" == "locked" ]] && { locked_users=$((locked_users+1)); continue; }
                [[ "$ar_days" -gt 0 ]] && auto_renew_count=$((auto_renew_count+1))
                local exp_unix
                exp_unix=$(date -d "$exp" +%s 2>/dev/null || echo 0)
                [[ $current -le $exp_unix ]] && active_users=$((active_users+1))
            done < "$USER_DB"

            local expired=$(( total_users - active_users - locked_users ))
            echo -e "  ${WHITE}TOTAL: ${CYAN}$total_users${NC}  |  ${GREEN}ACTIVE: $active_users${NC}  |  ${RED}EXPIRED: $expired${NC}  |  ${YELLOW}LOCKED: $locked_users${NC}  |  ${GREEN}🔄 AUTO: $auto_renew_count${NC}"
            echo ""
        fi

        echo -e "  ${GREEN}1)${NC}  👤 ADD NEW USER"
        echo -e "  ${CYAN}2)${NC}  📋 LIST ALL USERS"
        echo -e "  ${YELLOW}3)${NC}  🔄 RENEW USER"
        echo -e "  ${RED}4)${NC}  🔒 LOCK USER"
        echo -e "  ${GREEN}5)${NC}  🔓 UNLOCK USER"
        echo -e "  ${PURPLE}6)${NC}  🖥️  SSH BANNER"
        echo -e "  ${GREEN}7)${NC}  ♻️  AUTO-RENEW SETTINGS"
        echo -e "  ${CYAN}8)${NC}  📊 AUTO-RENEW STATUS"
        echo -e "  ${YELLOW}9)${NC}  💾 BACKUP & RESTORE"
        echo -e "  ${RED}10)${NC} 🗑️  DELETE USER"
        echo -e "  ${WHITE}0)${NC}  ⬅️  BACK"
        echo ""
        dsep
        echo -e "  ${YELLOW}🚨 EMERGENCY RECOVERY (run on server if users are locked out):${NC}"
        echo -e "  ${WHITE}sed -i 's/|locked|/|active|/g' /etc/slowdns/users.txt; screen -r -S limiter_daemon -X quit 2>/dev/null; rm -f /etc/slowdns/limiter_autostart /etc/slowdns/limiter_daemon.sh; echo DONE${NC}"
        dsep
        echo ""
        read -rp "CHOICE: " choice

        case $choice in
            1)  add_ssh_user ;;
            2)  list_ssh_users ;;
            3)  renew_ssh_user ;;
            4)  lock_ssh_user ;;
            5)  unlock_ssh_user ;;
            6)  manage_ssh_banner ;;
            7)  toggle_auto_renew ;;
            8)  view_auto_renew_status ;;
            9)  manage_backup_restore ;;
            10) delete_ssh_user ;;
            0)  return ;;
            *)  log_error "INVALID CHOICE"; sleep 1 ;;
        esac
    done
}

system_menu() {
    while true; do
        show_banner
        dtitle "🖥️  SYSTEM TOOLS"
        dsep
        echo ""
        echo -e "  ${CYAN}1)${NC}  📊 VPS INFO PANEL"
        echo -e "  ${GREEN}2)${NC}  ⚙️  SERVER OPTIMIZER"
        echo -e "  ${YELLOW}3)${NC}  👁️  SSH CONNECTION MONITOR"
        echo -e "  ${RED}4)${NC}  🧹 EXPIRED USERS CLEANER"
        echo -e "  ${BLUE}5)${NC}  🔄 SCRIPT AUTO-UPDATER"
        echo -e "  ${WHITE}0)${NC}  ⬅️  BACK"
        echo ""
        read -rp "CHOICE: " choice

        case $choice in
            1) vps_info_panel ;;
            2) server_optimizer ;;
            3) ssh_monitor ;;
            4) expired_users_cleaner ;;
            5) check_for_updates ;;
            0) return ;;
            *) log_error "INVALID CHOICE"; sleep 1 ;;
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
        echo -e "  ${YELLOW}3)${NC}  🖥️  SYSTEM TOOLS"
        echo -e "  ${RED}0)${NC}  ⛔ EXIT"
        echo ""
        dsep
        echo -e "  ${WHITE}VERSION: 9.2 ULTRA DIAMOND | ${BRED}CREATED BY BLACK KILLER${NC}"
        echo -e "  ${WHITE}📱 WhatsApp: +255658785522${NC}"
        dsep
        echo ""
        read -rp "CHOICE: " choice

        case $choice in
            1) dnstt_menu ;;
            2) ssh_menu ;;
            3) system_menu ;;
            0)
                echo ""
                dbox_top
                echo -e "${BGREEN}   THANK YOU FOR USING BLACK KILLER SSH TUNNEL MANAGER! 👑${NC}"
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
# BLACK KILLER SSH TUNNEL MANAGER
bash "$SCRIPT_PATH"
EOF
        chmod +x "/usr/local/bin/$cmd"
    done

    log_success "MENU COMMANDS CREATED: menu, dnstt, slowdns"
}

#============================================================
# MAIN EXECUTION
#============================================================
# Stop any old limiter daemon left over from a previous install
screen -r -S limiter_daemon -X quit 2>/dev/null || true
rm -f /etc/slowdns/limiter_autostart /etc/slowdns/limiter_daemon.sh 2>/dev/null || true

[[ ! -f /usr/local/bin/menu ]] && [[ $EUID -eq 0 ]] && create_menu_command 2>/dev/null

check_root
check_bash_version
check_os
main_menu

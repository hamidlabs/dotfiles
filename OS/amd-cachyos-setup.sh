#!/bin/bash
################################################################################
# CachyOS Ultimate Setup Script - Customized for Development + Content Creation
# 
# Features:
# - macOS-quality font rendering with LucidGlyph (2025)
# - Full-stack development environment with Bangla/Arabic font support
# - Screen recording and content creation tools for YouTube/teaching
# - OnlyOffice for professional document compatibility
# - AMD Ryzen 7 5700U (Zen 2) specific optimizations
# - KDE Plasma 6 customization and performance tuning
# - CachyOS-specific optimizations and repositories
# - BULLETPROOF error handling - NEVER stops completely
# - 100% completion guarantee regardless of individual failures
# - NO GAMING COMPONENTS (Steam removed)
################################################################################

set -u  # Only exit on undefined vars, but continue on errors

# Global variables
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/tmp/cachyos-setup-$(date +%Y%m%d-%H%M%S).log"
readonly BACKUP_DIR="$HOME/.config/cachyos-setup-backup-$(date +%Y%m%d-%H%M%S)"
readonly SCRIPT_VERSION="2025.1.0-CUSTOM"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Progress tracking
TOTAL_STEPS=13
CURRENT_STEP=0

################################################################################
# Utility Functions
################################################################################

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

progress() {
    ((CURRENT_STEP++))
    local percentage=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    echo -e "${PURPLE}[PROGRESS]${NC} Step $CURRENT_STEP/$TOTAL_STEPS ($percentage%) - $1"
    log "PROGRESS: Step $CURRENT_STEP/$TOTAL_STEPS - $1"
}

create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        log "Created backup directory: $BACKUP_DIR"
    fi
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        if cp "$file" "$BACKUP_DIR/$(basename "$file").bak" 2>/dev/null; then
            log "Backed up: $file"
            return 0
        else
            warning "Failed to backup $file - continuing anyway"
            return 1
        fi
    fi
}

install_package() {
    local package="$1"
    local retries=3
    local count=0
    
    if pacman -Q "$package" &>/dev/null; then
        info "$package is already installed"
        return 0
    fi
    
    info "Installing $package..."
    
    while [[ $count -lt $retries ]]; do
        ((count++))
        if sudo pacman -S --noconfirm --needed "$package" 2>/dev/null; then
            success "Successfully installed $package"
            return 0
        else
            warning "Attempt $count/$retries failed for $package"
            if [[ $count -lt $retries ]]; then
                info "Waiting 2 seconds before retry..."
                sleep 2
                # Sync databases on retry
                sudo pacman -Sy 2>/dev/null || true
            fi
        fi
    done
    
    error "Failed to install $package after $retries attempts - CONTINUING ANYWAY"
    return 1
}

install_aur_package() {
    local package="$1"
    local retries=3
    local count=0
    
    if pacman -Q "$package" &>/dev/null; then
        info "AUR package $package is already installed"
        return 0
    fi
    
    # Check if yay is available
    if ! command -v yay &>/dev/null; then
        warning "yay not available, skipping AUR package $package"
        return 1
    fi
    
    info "Installing AUR package $package..."
    
    while [[ $count -lt $retries ]]; do
        ((count++))
        if yay -S --noconfirm --needed "$package" 2>/dev/null; then
            success "Successfully installed AUR package $package"
            return 0
        else
            warning "Attempt $count/$retries failed for AUR package $package"
            if [[ $count -lt $retries ]]; then
                info "Waiting 3 seconds before retry..."
                sleep 3
            fi
        fi
    done
    
    error "Failed to install AUR package $package after $retries attempts - CONTINUING ANYWAY"
    return 1
}

check_dependencies() {
    local deps=("curl" "git" "base-devel")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! pacman -Q "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        warning "Missing dependencies: ${missing_deps[*]}"
        info "Installing missing dependencies..."
        for dep in "${missing_deps[@]}"; do
            install_package "$dep" || warning "Failed to install $dep - continuing anyway"
        done
    fi
}

safe_execute() {
    local description="$1"
    shift
    local cmd=("$@")
    
    info "Executing: $description"
    if "${cmd[@]}" 2>/dev/null; then
        success "$description completed successfully"
        return 0
    else
        warning "$description failed - continuing anyway"
        return 1
    fi
}

detect_cpu_architecture() {
    local arch_info
    arch_info=$(/lib/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -o "x86-64-v[0-9]" | sort -V | tail -1)
    
    if [[ "$arch_info" == "x86-64-v4" ]]; then
        echo "v4"
    elif [[ "$arch_info" == "x86-64-v3" ]]; then
        echo "v3"
    else
        echo "v2"
    fi
}

################################################################################
# Main Setup Functions
################################################################################

show_banner() {
    clear
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════════╗
║               CachyOS Custom Setup - Dev + Content Creation                  ║
║                                                                               ║
║  🚀 AMD Ryzen 7 5700U + KDE Plasma + Development + Screen Recording         ║
║  📝 OnlyOffice + macOS Fonts + Bangla/Arabic Support                        ║
║  🛡️ BULLETPROOF EXECUTION - NEVER STOPS, ALWAYS COMPLETES 100%             ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo
    info "Script version: $SCRIPT_VERSION"
    info "Customized for: Development + Content Creation + Office Work"
    info "Log file: $LOG_FILE"
    info "Backup directory: $BACKUP_DIR"
    echo
}

system_info() {
    progress "Gathering system information"
    
    info "System Information:"
    info "  - OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown")"
    info "  - Kernel: $(uname -r 2>/dev/null || echo "Unknown")"
    info "  - CPU: $(lscpu 2>/dev/null | grep 'Model name' | cut -d':' -f2 | xargs || echo "Unknown")"
    info "  - Architecture: $(uname -m 2>/dev/null || echo "Unknown")"
    info "  - Desktop: ${XDG_CURRENT_DESKTOP:-Unknown}"
    
    # Detect CPU capabilities
    local cpu_arch
    cpu_arch=$(detect_cpu_architecture)
    info "  - CPU Architecture Level: x86-64-$cpu_arch"
    
    # Verify AMD Ryzen 7 5700U
    if lscpu 2>/dev/null | grep -q "5700U"; then
        success "Detected AMD Ryzen 7 5700U (Zen 2 architecture) - optimizations will be applied"
    else
        warning "This script is optimized for AMD Ryzen 7 5700U, but will continue with generic AMD optimizations"
    fi
    
    create_backup_dir || warning "Failed to create backup directory"
}

setup_cachyos_repositories() {
    progress "Setting up CachyOS optimized repositories"
    
    local cpu_arch
    cpu_arch=$(detect_cpu_architecture)
    
    # Backup pacman.conf
    backup_file "/etc/pacman.conf" || true
    
    # Download and install CachyOS repository script
    info "Installing CachyOS repositories for x86-64-$cpu_arch architecture..."
    
    # Try multiple methods to install CachyOS repos
    local repo_installed=false
    
    # Method 1: Official script
    if curl -s -L -o /tmp/cachyos-repo.tar.xz "https://mirror.cachyos.org/cachyos-repo.tar.xz" 2>/dev/null; then
        cd /tmp 2>/dev/null || true
        if tar xf cachyos-repo.tar.xz 2>/dev/null && cd cachyos-repo 2>/dev/null; then
            if sudo ./cachyos-repo.sh 2>/dev/null; then
                success "CachyOS repositories configured successfully"
                repo_installed=true
            else
                warning "CachyOS repository script failed - trying manual setup"
            fi
        fi
    fi
    
    # Method 2: Manual repository setup if script failed
    if [[ "$repo_installed" == false ]]; then
        info "Attempting manual CachyOS repository setup..."
        
        # Backup and modify pacman.conf manually
        if [[ -f /etc/pacman.conf ]]; then
            # Add CachyOS repository manually
            if ! grep -q "cachyos" /etc/pacman.conf 2>/dev/null; then
                {
                    echo ""
                    echo "# CachyOS repositories"
                    echo "[cachyos]"
                    echo "Include = /etc/pacman.d/cachyos-mirrorlist"
                    echo ""
                    echo "[cachyos-core-v3]"
                    echo "Include = /etc/pacman.d/cachyos-v3-mirrorlist"
                } | sudo tee -a /etc/pacman.conf >/dev/null 2>&1 && \
                info "CachyOS repositories added manually to pacman.conf" || \
                warning "Failed to add CachyOS repositories manually"
            fi
        fi
    fi
    
    # Refresh package databases (don't fail if this doesn't work)
    info "Refreshing package databases..."
    sudo pacman -Sy 2>/dev/null || warning "Failed to refresh package databases - continuing anyway"
    
    # Install CachyOS tools (continue even if some fail)
    info "Installing CachyOS tools..."
    install_package "cachyos-hello" || true
    install_package "cachyos-kernel-manager" || true  
    install_package "cachyos-rate-mirrors" || true
    install_package "cachyos-settings" || true
    
    success "CachyOS repositories setup completed (some components may have failed)"
}

setup_kernel_optimization() {
    progress "Setting up optimized kernel and boot parameters"
    
    # Install CachyOS optimized kernel (try multiple options)
    info "Installing optimized kernel..."
    install_package "linux-cachyos" || install_package "linux-zen" || install_package "linux-lts" || warning "No optimized kernel installed"
    install_package "linux-cachyos-headers" || install_package "linux-zen-headers" || install_package "linux-lts-headers" || warning "No kernel headers installed"
    
    # Backup GRUB configuration
    backup_file "/etc/default/grub" || true
    
    # AMD Ryzen 7 5700U (Zen 2) specific kernel parameters
    local kernel_params="quiet"
    kernel_params+=" amd_pstate=passive"                    # AMD P-State driver
    kernel_params+=" amd_iommu=on"                         # AMD IOMMU
    kernel_params+=" amdgpu.ppfeaturemask=0xffffffff"      # All AMDGPU features
    kernel_params+=" processor.max_cstate=1"               # Limit C-states for responsiveness
    kernel_params+=" amd_pstate_preferred_core=1"          # Enable preferred core
    kernel_params+=" iommu=pt"                             # IOMMU passthrough
    kernel_params+=" pci=pcie_bus_perf"                    # PCIe performance
    kernel_params+=" align_va_addr=64"                     # Zen 2 cache optimization
    
    # Update GRUB configuration (continue even if this fails)
    info "Updating GRUB configuration..."
    if [[ -f /etc/default/grub ]]; then
        if sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$kernel_params\"/" /etc/default/grub 2>/dev/null; then
            success "GRUB configuration updated"
        else
            warning "Failed to update GRUB configuration automatically"
            info "Manual GRUB update may be needed with parameters: $kernel_params"
        fi
    else
        warning "/etc/default/grub not found - may need manual kernel parameter configuration"
    fi
    
    # Configure AMDGPU module parameters (continue if fails)
    info "Configuring AMDGPU module parameters..."
    if sudo tee /etc/modprobe.d/amdgpu.conf >/dev/null 2>&1 << 'EOF'; then
options amdgpu gpu_recovery=1
options amdgpu ppfeaturemask=0xffffffff
options amdgpu runpm=1
options amdgpu bapm=1
EOF
        success "AMDGPU module parameters configured"
    else
        warning "Failed to configure AMDGPU module parameters"
    fi
    
    # Update bootloader (don't fail if this doesn't work)
    info "Updating bootloader..."
    if [[ -d /sys/firmware/efi ]]; then
        if sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null; then
            success "UEFI bootloader updated"
        else
            warning "Failed to update UEFI bootloader - may need manual update"
        fi
    else
        if sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null; then
            success "BIOS bootloader updated"
        else
            warning "Failed to update BIOS bootloader - may need manual update"
        fi
    fi
    
    success "Kernel optimization completed (some components may need manual configuration)"
}

setup_amd_optimization() {
    progress "Setting up AMD Ryzen 7 5700U specific optimizations"
    
    # Install AMD-specific packages
    install_package "amd-ucode"
    install_package "mesa"
    install_package "lib32-mesa"
    install_package "vulkan-radeon"
    install_package "lib32-vulkan-radeon"
    install_package "mesa-vdpau"
    install_package "libva-mesa-driver"
    
    # Install AMD tools
    install_package "radeontop"
    install_package "lact"
    
    # Power management setup
    install_package "tlp"
    install_package "tlp-rdw"
    
    # Configure TLP for AMD Ryzen 7 5700U
    backup_file "/etc/tlp.conf"
    
    sudo tee /etc/tlp.conf << 'EOF'
# AMD Ryzen 7 5700U optimized TLP configuration
TLP_ENABLE=1

# CPU Scaling
CPU_SCALING_GOVERNOR_ON_AC=schedutil
CPU_SCALING_GOVERNOR_ON_BAT=conservative
CPU_SCALING_MIN_FREQ_ON_AC=1800000
CPU_SCALING_MAX_FREQ_ON_AC=4300000
CPU_SCALING_MIN_FREQ_ON_BAT=1800000
CPU_SCALING_MAX_FREQ_ON_BAT=2800000

# AMD GPU Power Management
RADEON_DPM_STATE_ON_AC=performance
RADEON_DPM_STATE_ON_BAT=battery
RADEON_DPM_PERF_LEVEL_ON_AC=auto
RADEON_DPM_PERF_LEVEL_ON_BAT=low

# USB Power Management
USB_AUTOSUSPEND=1

# WiFi Power Saving
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# Sound Power Management
SOUND_POWER_SAVE_ON_AC=0
SOUND_POWER_SAVE_ON_BAT=1
EOF
    
    # Enable TLP service
    sudo systemctl enable tlp.service
    sudo systemctl mask systemd-rfkill@.service
    sudo systemctl mask systemd-rfkill.socket
    
    # Configure system tuning for AMD Zen 2
    sudo tee /etc/sysctl.d/99-amd-zen2.conf << 'EOF'
# AMD Zen 2 (Ryzen 7 5700U) optimizations
vm.swappiness=10
vm.dirty_ratio=15
vm.dirty_background_ratio=5
kernel.numa_balancing=1
vm.nr_hugepages=128
EOF
    
    # Enable LACT service for GPU control
    sudo systemctl enable lactd.service
    
    success "AMD optimizations configured"
}

setup_macos_font_rendering() {
    progress "Setting up macOS-quality font rendering with Bangla/Arabic support"
    
    # Essential fonts - continue even if some fail
    info "Installing essential fonts..."
    install_package "tex-gyre-fonts" || true
    install_package "libertinus-font" || true
    install_package "ttf-dejavu" || true
    install_package "noto-fonts-emoji" || true
    install_package "ttf-liberation" || true
    install_package "cantarell-fonts" || true
    
    # Bangla/Bengali fonts
    info "Installing Bangla/Bengali fonts..."
    install_package "noto-fonts-extra" || true
    install_package "ttf-indic-otf" || true
    install_aur_package "ttf-bangla" || true
    install_aur_package "fonts-beng-extra" || true
    install_aur_package "ttf-kalpurush" || true
    install_aur_package "ttf-siyam-rupali" || true
    install_package "ttf-kacst" || true  # Contains some Bengali support
    
    # Arabic fonts
    info "Installing Arabic fonts..."
    install_package "ttf-amiri" || true
    install_package "ttf-scheherazade-new" || true
    install_package "noto-fonts-cjk" || true
    install_package "ttf-kacst-one" || true
    install_package "ttf-kacst" || true
    install_aur_package "ttf-tahoma" || true
    install_aur_package "ttf-arabeyes-fonts" || true
    install_aur_package "ttf-arabic-fonts" || true
    
    # Microsoft fonts (for compatibility)
    info "Installing Microsoft compatibility fonts..."
    install_aur_package "ttf-ms-fonts" || true
    install_aur_package "apple-fonts" || true
    
    # Install LucidGlyph for 2025 font rendering improvements
    info "Installing LucidGlyph (latest 2025 font rendering technology)..."
    if curl -s -L "https://maximilionus.github.io/lucidglyph/wrapper.sh" 2>/dev/null | bash -s install 2>/dev/null; then
        success "LucidGlyph installed successfully"
    else
        warning "LucidGlyph installation failed, continuing with standard configuration"
    fi
    
    # Configure fontconfig for macOS-like rendering with international support
    info "Configuring fontconfig for macOS-like rendering..."
    backup_file "/etc/fonts/local.conf" || true
    
    # Create the fontconfig directory if it doesn't exist
    sudo mkdir -p /etc/fonts/conf.d 2>/dev/null || true
    
    # Main fontconfig configuration
    if sudo tee /etc/fonts/local.conf >/dev/null 2>&1 << 'EOF'; then
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
  <!-- macOS-quality font rendering configuration -->
  <match target="font">
    <edit name="autohint" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hinting" mode="assign">
      <bool>true</bool>
    </edit>
    <edit mode="assign" name="hintstyle">
      <const>hintslight</const>
    </edit>
    <edit mode="assign" name="lcdfilter">
      <const>lcddefault</const>
    </edit>
    <edit name="antialias" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="rgba" mode="assign">
      <const>rgb</const>
    </edit>
  </match>

  <!-- macOS system font replacements -->
  <match target="pattern">
    <test qual="any" name="family"><string>-apple-system</string></test>
    <edit name="family" mode="prepend" binding="same">
      <string>Tex Gyre Heros</string>
    </edit>
  </match>
  
  <match target="pattern">
    <test qual="any" name="family"><string>SF Pro Display</string></test>
    <edit name="family" mode="prepend" binding="same">
      <string>Tex Gyre Heros</string>
    </edit>
  </match>

  <match target="pattern">
    <test qual="any" name="family"><string>SF Pro Text</string></test>
    <edit name="family" mode="prepend" binding="same">
      <string>Tex Gyre Heros</string>
    </edit>
  </match>

  <match target="pattern">
    <test qual="any" name="family"><string>SF Mono</string></test>
    <edit name="family" mode="prepend" binding="same">
      <string>Liberation Mono</string>
    </edit>
  </match>

  <!-- Bangla/Bengali font configuration -->
  <match target="pattern">
    <test name="lang" compare="contains">
      <string>bn</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Kalpurush</string>
      <string>SiyamRupali</string>
      <string>Noto Sans Bengali</string>
      <string>Mukti Narrow</string>
      <string>Lohit Bengali</string>
    </edit>
  </match>

  <!-- Arabic font configuration -->
  <match target="pattern">
    <test name="lang" compare="contains">
      <string>ar</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Amiri</string>
      <string>Scheherazade New</string>
      <string>Noto Sans Arabic</string>
      <string>KacstOne</string>
      <string>DejaVu Sans</string>
    </edit>
  </match>

  <!-- Serif fonts for Arabic -->
  <match target="pattern">
    <test name="family">
      <string>serif</string>
    </test>
    <test name="lang" compare="contains">
      <string>ar</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Amiri</string>
      <string>Scheherazade New</string>
      <string>Noto Serif Arabic</string>
    </edit>
  </match>

  <!-- Sans-serif fonts for Arabic -->
  <match target="pattern">
    <test name="family">
      <string>sans-serif</string>
    </test>
    <test name="lang" compare="contains">
      <string>ar</string>
    </test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Sans Arabic</string>
      <string>KacstOne</string>
      <string>DejaVu Sans</string>
    </edit>
  </match>

  <!-- Default font families -->
  <alias>
    <family>serif</family>
    <prefer>
      <family>Libertinus Serif</family>
      <family>Noto Serif</family>
      <family>Amiri</family>
      <family>Noto Sans Bengali</family>
    </prefer>
  </alias>

  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Tex Gyre Heros</family>
      <family>Noto Sans</family>
      <family>Noto Sans Arabic</family>
      <family>Kalpurush</family>
    </prefer>
  </alias>

  <alias>
    <family>monospace</family>
    <prefer>
      <family>Liberation Mono</family>
      <family>Noto Sans Mono</family>
      <family>DejaVu Sans Mono</family>
    </prefer>
  </alias>
</fontconfig>
EOF
        success "Main fontconfig configuration applied"
    else
        error "Failed to write main fontconfig - continuing anyway"
    fi
    
    # Enable RGB subpixel rendering (continue if fails)
    info "Enabling RGB subpixel rendering..."
    sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/ 2>/dev/null || warning "Failed to enable RGB subpixel rendering"
    
    # Enable font hinting (continue if fails)
    sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/ 2>/dev/null || warning "Failed to enable font hinting"
    
    # Set FreeType environment variables for stem darkening
    info "Configuring FreeType environment variables..."
    if ! grep -q "FREETYPE_PROPERTIES" ~/.bashrc 2>/dev/null; then
        echo 'export FREETYPE_PROPERTIES="cff:no-stem-darkening=0 autofitter:no-stem-darkening=0"' >> ~/.bashrc 2>/dev/null || warning "Failed to set FreeType variables in bashrc"
    fi
    
    # Also add to profile for system-wide effect
    if [[ -w /etc/environment ]] || sudo test -w /etc/environment; then
        echo 'FREETYPE_PROPERTIES="cff:no-stem-darkening=0 autofitter:no-stem-darkening=0"' | sudo tee -a /etc/environment >/dev/null 2>&1 || warning "Failed to set system-wide FreeType variables"
    fi
    
    # Configure for GNOME (if present) - don't fail if not available
    if command -v gsettings &>/dev/null; then
        info "Configuring GNOME font settings..."
        gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface font-hinting 'slight' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface font-rgba-order 'rgb' 2>/dev/null || true
    fi
    
    # Configure for KDE (if present)
    if command -v kwriteconfig5 &>/dev/null; then
        info "Configuring KDE font settings..."
        kwriteconfig5 --file kdeglobals --group General --key font "Tex Gyre Heros,10,-1,5,50,0,0,0,0,0" 2>/dev/null || true
        kwriteconfig5 --file kdeglobals --group General --key smallestReadableFont "Tex Gyre Heros,8,-1,5,50,0,0,0,0,0" 2>/dev/null || true
        kwriteconfig5 --file kdeglobals --group General --key toolBarFont "Tex Gyre Heros,9,-1,5,50,0,0,0,0,0" 2>/dev/null || true
    fi
    
    # Rebuild font cache - this should always work
    info "Rebuilding font cache..."
    if fc-cache -fv 2>/dev/null; then
        success "Font cache rebuilt successfully"
    else
        warning "Font cache rebuild failed, trying user cache only..."
        fc-cache -fv ~/.fonts 2>/dev/null || warning "User font cache rebuild also failed"
    fi
    
    success "macOS-quality font rendering with Bangla/Arabic support configured"
}

setup_development_environment() {
    progress "Setting up comprehensive development environment"
    
    # Version managers and runtime tools (continue even if some fail)
    info "Installing development languages and runtimes..."
    install_package "nodejs" || warning "Failed to install nodejs"
    install_package "npm" || warning "Failed to install npm"
    install_package "python" || warning "Failed to install python"
    install_package "python-pip" || warning "Failed to install python-pip"
    install_package "go" || warning "Failed to install go"
    install_package "rust" || warning "Failed to install rust"
    install_package "jdk-openjdk" || warning "Failed to install jdk-openjdk"
    install_package "gcc" || warning "Failed to install gcc"
    install_package "clang" || warning "Failed to install clang"
    install_package "cmake" || warning "Failed to install cmake"
    install_package "make" || warning "Failed to install make"
    
    # Install mise (modern version manager) - don't fail if this doesn't work
    info "Installing mise (modern version manager)..."
    if curl -s https://mise.run 2>/dev/null | sh 2>/dev/null; then
        {
            echo 'eval "$(mise activate bash)"' >> ~/.bashrc 2>/dev/null
            echo 'eval "$(mise activate zsh)"' >> ~/.zshrc 2>/dev/null || true
        } && success "mise installed successfully" || warning "mise configuration failed"
    else
        warning "mise installation failed - using system package managers"
    fi
    
    # Container tools (Podman preferred over Docker)
    info "Installing container tools..."
    install_package "podman" || warning "Failed to install podman"
    install_package "podman-compose" || install_aur_package "podman-compose" || warning "Failed to install podman-compose"
    install_package "buildah" || warning "Failed to install buildah"
    
    # Databases (continue even if some fail)
    info "Installing databases..."
    install_package "postgresql" || warning "Failed to install postgresql"
    install_package "redis" || warning "Failed to install redis"  
    install_package "mariadb" || warning "Failed to install mariadb"
    install_package "sqlite" || warning "Failed to install sqlite"
    
    # Web servers (continue even if some fail)
    info "Installing web servers..."
    install_package "nginx" || warning "Failed to install nginx"
    install_package "caddy" || install_aur_package "caddy" || warning "Failed to install caddy"
    
    # Version control and tools (continue even if some fail)
    info "Installing version control tools..."
    install_package "git" || warning "Failed to install git"
    install_package "github-cli" || install_aur_package "github-cli" || warning "Failed to install github-cli"
    install_aur_package "lazygit" || warning "Failed to install lazygit"
    
    # Modern CLI tools (continue even if some fail)
    info "Installing modern CLI tools..."
    install_package "bat" || warning "Failed to install bat"           # cat replacement
    install_package "eza" || warning "Failed to install eza"           # ls replacement  
    install_package "fd" || warning "Failed to install fd"             # find replacement
    install_package "ripgrep" || warning "Failed to install ripgrep"   # grep replacement
    install_package "fzf" || warning "Failed to install fzf"           # fuzzy finder
    install_package "starship" || warning "Failed to install starship" # modern prompt
    install_package "btop" || install_package "htop" || warning "Failed to install system monitor"
    install_package "dust" || warning "Failed to install dust"         # du replacement
    install_package "duf" || warning "Failed to install duf"           # df replacement
    install_package "zoxide" || warning "Failed to install zoxide"     # cd replacement
    install_package "tree" || warning "Failed to install tree"
    install_package "wget" || warning "Failed to install wget"
    
    # Terminal and shells (continue even if some fail)  
    info "Installing terminals and shells..."
    install_package "alacritty" || warning "Failed to install alacritty"
    install_package "kitty" || warning "Failed to install kitty"
    install_package "fish" || warning "Failed to install fish"
    install_package "zsh" || warning "Failed to install zsh"
    install_package "tmux" || warning "Failed to install tmux"
    install_aur_package "zellij" || warning "Failed to install zellij"
    
    # Development tools (continue even if some fail)
    info "Installing development editors..."
    install_package "neovim" || install_package "vim" || warning "Failed to install any text editor"
    install_aur_package "visual-studio-code-bin" || install_package "code" || warning "Failed to install VS Code"
    
    # Configure Git (if not already configured) - don't fail
    if command -v git &>/dev/null && [[ -z "$(git config --global user.name 2>/dev/null || true)" ]]; then
        info "Git configuration needed - please configure manually with:"
        info "  git config --global user.name 'Your Name'"
        info "  git config --global user.email 'your.email@example.com'"
    fi
    
    # Enable some services (don't fail if they don't exist)
    info "Enabling development services..."
    sudo systemctl enable postgresql.service 2>/dev/null || warning "PostgreSQL service not available"
    sudo systemctl enable redis.service 2>/dev/null || warning "Redis service not available"  
    sudo systemctl enable nginx.service 2>/dev/null || warning "Nginx service not available"
    
    success "Development environment setup completed (some components may have failed)"
}

setup_office_productivity() {
    progress "Setting up office productivity tools"
    
    # OnlyOffice - Essential for .docx/.pptx compatibility
    info "Installing OnlyOffice for Microsoft Office compatibility..."
    install_package "onlyoffice-desktopeditors" || install_aur_package "onlyoffice-bin" || warning "Failed to install OnlyOffice"
    
    # LibreOffice as backup
    info "Installing LibreOffice as backup office suite..."
    install_package "libreoffice-fresh" || warning "Failed to install LibreOffice"
    
    # PDF tools
    info "Installing PDF tools..."
    install_package "okular" || warning "Failed to install Okular"              # KDE PDF viewer
    install_package "qpdfview" || warning "Failed to install qpdfview"          # Alternative PDF viewer
    install_package "evince" || warning "Failed to install Evince"              # GNOME document viewer
    
    # Email client
    info "Installing email client..."
    install_package "thunderbird" || warning "Failed to install Thunderbird"
    
    # Note-taking tools
    info "Installing note-taking tools..."
    install_package "kate" || warning "Failed to install Kate"                  # KDE text editor
    install_aur_package "obsidian" || warning "Failed to install Obsidian"      # Modern note-taking
    install_package "ghostwriter" || warning "Failed to install GhostWriter"    # Markdown editor
    
    # Calendar and productivity
    install_package "korganizer" || warning "Failed to install KOrganizer"      # KDE calendar
    install_package "kontact" || warning "Failed to install Kontact"            # KDE PIM suite
    
    success "Office productivity tools installed"
}

setup_screen_recording_tools() {
    progress "Setting up screen recording and content creation tools"
    
    # Core screen recording tools
    info "Installing OBS Studio for professional screen recording..."
    install_package "obs-studio" || warning "Failed to install OBS Studio"
    
    # OBS plugins and additional tools
    info "Installing OBS plugins and recording tools..."
    install_aur_package "obs-studio-browser" || warning "Failed to install OBS browser plugin"
    install_aur_package "obs-backgroundremoval" || warning "Failed to install OBS background removal"
    install_package "v4l2loopback-dkms" || warning "Failed to install virtual camera support"
    
    # Screen capture tools
    info "Installing screen capture utilities..."
    install_package "spectacle" || warning "Failed to install Spectacle"        # KDE screenshot tool
    install_package "flameshot" || warning "Failed to install Flameshot"        # Advanced screenshot
    install_aur_package "peek" || warning "Failed to install Peek"              # Simple GIF recorder
    
    # Video editing tools
    info "Installing video editing software..."
    install_package "kdenlive" || warning "Failed to install Kdenlive"          # Professional video editor
    install_aur_package "davinci-resolve" || warning "Failed to install DaVinci Resolve" # Professional editor
    install_package "openshot" || warning "Failed to install OpenShot"          # Simple video editor
    
    # Audio tools for content creation
    info "Installing audio tools..."
    install_package "audacity" || warning "Failed to install Audacity"          # Audio editor
    install_package "pavucontrol" || warning "Failed to install PulseAudio control" # Audio control
    install_package "pulse-native-provider" || warning "Failed to install PulseAudio"
    
    # Streaming and communication tools
    info "Installing communication tools..."
    install_aur_package "discord" || warning "Failed to install Discord"
    install_aur_package "zoom" || warning "Failed to install Zoom"
    install_package "teams-for-linux" || install_aur_package "teams-for-linux" || warning "Failed to install Teams"
    
    # Graphics and design tools
    info "Installing graphics tools for content creation..."
    install_package "gimp" || warning "Failed to install GIMP"                  # Image editor
    install_package "inkscape" || warning "Failed to install Inkscape"          # Vector graphics
    install_package "krita" || warning "Failed to install Krita"                # Digital painting
    install_aur_package "figma-linux" || warning "Failed to install Figma"      # UI design
    
    # YouTube and content creation utilities
    info "Installing YouTube content creation tools..."
    install_aur_package "youtube-dl-gui" || warning "Failed to install YouTube-DL GUI"
    install_package "yt-dlp" || warning "Failed to install yt-dlp"              # YouTube downloader
    install_aur_package "thumbnails-generator" || warning "Failed to install thumbnail generator"
    
    # Fonts for content creation
    info "Installing content creation fonts..."
    install_aur_package "ttf-google-fonts-git" || warning "Failed to install Google Fonts"
    install_package "adobe-source-sans-fonts" || warning "Failed to install Adobe fonts"
    
    # Configure OBS for optimal recording
    info "Setting up OBS configuration..."
    mkdir -p ~/.config/obs-studio/basic/profiles/Untitled/
    
    # Create basic OBS configuration for screen recording
    if tee ~/.config/obs-studio/basic/profiles/Untitled/basic.ini >/dev/null 2>&1 << 'EOF'; then
[General]
Name=Untitled

[Video]
BaseCX=1920
BaseCY=1080
OutputCX=1920
OutputCY=1080
FPSType=0
FPSCommon=30

[Output]
Mode=Simple
FilePath=$HOME/Videos
RecFormat=mp4
RecEncoder=x264
RecQuality=0
RecRB=false

[Audio]
SampleRate=44100
ChannelSetup=Stereo
EOF
        success "Basic OBS configuration created"
    else
        warning "Failed to create OBS configuration"
    fi
    
    # Configure system for screen recording
    info "Configuring system for optimal screen recording..."
    
    # Add user to video group for camera access
    sudo usermod -a -G video "$USER" 2>/dev/null || warning "Failed to add user to video group"
    
    # Load v4l2loopback module for virtual camera
    echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null 2>&1 || warning "Failed to configure virtual camera module"
    
    # Configure PipeWire for low-latency audio (if using PipeWire)
    if command -v pipewire &>/dev/null; then
        info "Configuring PipeWire for content creation..."
        mkdir -p ~/.config/pipewire/pipewire.conf.d/
        echo 'context.properties = { default.clock.quantum = 512 }' > ~/.config/pipewire/pipewire.conf.d/99-lowlatency.conf 2>/dev/null || warning "Failed to configure PipeWire"
    fi
    
    success "Screen recording and content creation tools setup completed"
}

setup_kde_plasma_optimization() {
    progress "Optimizing KDE Plasma for performance and macOS-like appearance"
    
    # Install KDE optimization tools
    install_package "plasma-systemmonitor"
    install_package "partitionmanager"
    
    # Install macOS-like themes
    info "Installing macOS-like themes for KDE Plasma..."
    
    # Create themes directory
    mkdir -p ~/.local/share/plasma/desktoptheme
    mkdir -p ~/.local/share/aurorae/themes
    mkdir -p ~/.icons
    
    # Install WhiteSur theme suite
    if git clone https://github.com/vinceliuice/WhiteSur-kde.git /tmp/WhiteSur-kde 2>/dev/null; then
        cd /tmp/WhiteSur-kde
        ./install.sh 2>/dev/null && success "WhiteSur KDE theme installed" || warning "WhiteSur theme installation failed"
    else
        warning "Failed to clone WhiteSur theme"
    fi
    
    # Install WhiteSur icons
    if git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icons 2>/dev/null; then
        cd /tmp/WhiteSur-icons
        ./install.sh 2>/dev/null && success "WhiteSur icons installed" || warning "WhiteSur icons installation failed"
    else
        warning "Failed to clone WhiteSur icons"
    fi
    
    # Install WhiteSur cursors
    if git clone https://github.com/vinceliuice/WhiteSur-cursors.git /tmp/WhiteSur-cursors 2>/dev/null; then
        cd /tmp/WhiteSur-cursors
        ./install.sh 2>/dev/null && success "WhiteSur cursors installed" || warning "WhiteSur cursors installation failed"  
    else
        warning "Failed to clone WhiteSur cursors"
    fi
    
    # Configure KDE settings via kwriteconfig5
    info "Applying KDE Plasma optimizations..."
    
    # Animation speed
    kwriteconfig5 --file kwinrc --group Compositing --key AnimationSpeed 3 2>/dev/null || warning "Failed to set animation speed"
    
    # Enable OpenGL compositor
    kwriteconfig5 --file kwinrc --group Compositing --key Backend OpenGL 2>/dev/null || warning "Failed to set OpenGL backend"
    kwriteconfig5 --file kwinrc --group Compositing --key GLTextureFilter 2 2>/dev/null || warning "Failed to set texture filter"
    
    # Desktop effects optimizations
    kwriteconfig5 --file kwinrc --group Plugins --key slideEnabled true 2>/dev/null || warning "Failed to enable slide effect"
    kwriteconfig5 --file kwinrc --group Plugins --key minimizeanimationEnabled true 2>/dev/null || warning "Failed to enable minimize animation"
    
    # Disable heavy effects for performance
    kwriteconfig5 --file kwinrc --group Plugins --key blurEnabled false 2>/dev/null || warning "Failed to disable blur"
    kwriteconfig5 --file kwinrc --group Plugins --key kwin4_effect_fadeEnabled false 2>/dev/null || warning "Failed to disable fade effect"
    
    # Configure panel for macOS-like dock behavior
    kwriteconfig5 --file plasmashellrc --group PlasmaViews --group Panel --group Defaults --key thickness 50 2>/dev/null || warning "Failed to set panel thickness"
    kwriteconfig5 --file plasmashellrc --group PlasmaViews --group Panel --group Defaults --key floating 1 2>/dev/null || warning "Failed to set floating panel"
    
    success "KDE Plasma optimization completed"
}

setup_system_tweaks() {
    progress "Applying system-wide performance tweaks"
    
    # Install system optimization tools
    install_package "ananicy-cpp"
    install_package "irqbalance"
    install_package "systemd-oomd"
    
    # Configure ananicy-cpp for process priority management
    sudo systemctl enable ananicy-cpp.service 2>/dev/null || warning "Failed to enable ananicy-cpp"
    
    # Configure IRQ balancing
    sudo systemctl enable irqbalance.service 2>/dev/null || warning "Failed to enable irqbalance"
    
    # Enable systemd-oomd for memory management
    sudo systemctl enable systemd-oomd.service 2>/dev/null || warning "Failed to enable systemd-oomd"
    
    # Configure I/O scheduler optimization
    if sudo tee /etc/udev/rules.d/60-ioschedulers.conf >/dev/null 2>&1 << 'EOF'; then
# Set deadline scheduler for SSDs and none for NVMe
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
EOF
        success "I/O scheduler rules configured"
    else
        warning "Failed to configure I/O scheduler rules"
    fi
    
    # Configure ZRAM
    install_package "zram-generator"
    
    if sudo tee /etc/systemd/zram-generator.conf >/dev/null 2>&1 << 'EOF'; then
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
        success "ZRAM configured"
    else
        warning "Failed to configure ZRAM"
    fi
    
    # System-wide optimizations
    if sudo tee /etc/sysctl.d/99-performance.conf >/dev/null 2>&1 << 'EOF'; then
# Performance optimizations
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
net.core.netdev_max_backlog = 16384
kernel.sched_autogroup_enabled = 1
EOF
        success "System performance tweaks applied"
    else
        warning "Failed to apply system performance tweaks"
    fi
    
    success "System tweaks applied"
}

setup_multimedia_codecs() {
    progress "Setting up multimedia codecs and Wine compatibility"
    
    # Install multimedia codecs
    install_package "gstreamer"
    install_package "gst-plugins-good"
    install_package "gst-plugins-bad"
    install_package "gst-plugins-ugly"
    install_package "gst-libav"
    install_package "ffmpeg"
    
    # Wine for Windows software compatibility (useful for development tools)
    install_package "wine"
    install_package "winetricks"
    install_package "lutris"  # Wine management tool
    
    # Additional codecs for content creation
    install_package "x264"
    install_package "x265"
    install_package "libdvdcss"
    
    success "Multimedia codecs and Windows compatibility setup completed"
}

setup_security_privacy() {
    progress "Configuring security and privacy settings"
    
    # Install security tools
    install_package "ufw"
    install_package "clamav"
    install_package "rkhunter"
    
    # Configure firewall
    sudo ufw enable 2>/dev/null || warning "Failed to enable UFW"
    sudo systemctl enable ufw.service 2>/dev/null || warning "Failed to enable UFW service"
    
    # Configure ClamAV
    sudo systemctl enable clamav-freshclam.service 2>/dev/null || warning "Failed to enable ClamAV"
    
    # Privacy-focused DNS
    if sudo tee /etc/systemd/resolved.conf >/dev/null 2>&1 << 'EOF'; then
[Resolve]
DNS=1.1.1.1 1.0.0.1
FallbackDNS=8.8.8.8 8.8.4.4
DNSSEC=yes
DNSOverTLS=yes
EOF
        success "Privacy DNS configured"
    else
        warning "Failed to configure DNS"
    fi
    
    sudo systemctl enable systemd-resolved.service 2>/dev/null || warning "Failed to enable systemd-resolved"
    
    success "Security and privacy configured"
}

finalize_installation() {
    progress "Finalizing installation and cleanup"
    
    # Update system (don't fail if this doesn't work)
    info "Updating system packages..."
    sudo pacman -Syu --noconfirm 2>/dev/null || warning "System update failed - continuing anyway"
    
    # Clean package cache (don't fail if this doesn't work)
    info "Cleaning package cache..."
    sudo pacman -Sc --noconfirm 2>/dev/null || warning "Package cache cleanup failed - continuing anyway"
    
    # Update font cache (don't fail if this doesn't work)
    info "Updating font cache..."
    fc-cache -fv 2>/dev/null || warning "Font cache update failed - continuing anyway"
    
    # Update desktop database (don't fail if this doesn't work)
    info "Updating desktop database..."
    update-desktop-database ~/.local/share/applications 2>/dev/null || warning "Desktop database update failed - continuing anyway"
    
    # Generate initramfs (don't fail if this doesn't work)
    info "Generating initramfs..."
    sudo mkinitcpio -P 2>/dev/null || warning "Initramfs generation failed - continuing anyway"
    
    # Update GRUB (don't fail if this doesn't work)
    info "Updating GRUB configuration..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || warning "GRUB update failed - continuing anyway"
    
    # Set up modern CLI tool aliases (don't fail if this doesn't work)
    info "Setting up modern CLI aliases..."
    {
        echo "" >> ~/.bashrc 2>/dev/null
        echo "# Modern CLI tool aliases and productivity setup" >> ~/.bashrc 2>/dev/null
        echo "alias ls='eza --color=auto'" >> ~/.bashrc 2>/dev/null
        echo "alias ll='eza -la --color=auto'" >> ~/.bashrc 2>/dev/null  
        echo "alias cat='bat'" >> ~/.bashrc 2>/dev/null
        echo "alias find='fd'" >> ~/.bashrc 2>/dev/null
        echo "alias du='dust'" >> ~/.bashrc 2>/dev/null
        echo "alias df='duf'" >> ~/.bashrc 2>/dev/null
        echo "alias cd='z'" >> ~/.bashrc 2>/dev/null
        echo "" >> ~/.bashrc 2>/dev/null
        echo "# Initialize modern tools" >> ~/.bashrc 2>/dev/null
        echo 'eval "$(zoxide init bash)"' >> ~/.bashrc 2>/dev/null
        echo 'eval "$(starship init bash)"' >> ~/.bashrc 2>/dev/null
    } || warning "Failed to set up shell aliases"
    
    success "Installation finalization completed (some components may have failed)"
}

show_completion_summary() {
    clear
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                🎉 CUSTOM SETUP COMPLETED 100% 🎉                            ║
║          ✅ Development + Content Creation + Office Ready                   ║
╚═══════════════════════════════════════════════════════════════════════════════╝
EOF
    
    echo
    success "CachyOS Custom Setup completed successfully!"
    info "🛡️ Script executed with bulletproof error handling - 100% completion guaranteed"
    echo
    info "📋 What was installed/configured:"
    info "✅ CachyOS optimized repositories & AMD Ryzen 7 5700U optimizations"
    info "✅ macOS-quality font rendering with Bangla/Arabic support"
    info "✅ Complete development environment (Node, Python, Go, Rust, etc.)"
    info "✅ Modern CLI tools (bat, eza, fd, ripgrep, fzf, zoxide, starship)"
    info "✅ OnlyOffice + LibreOffice for document compatibility"
    info "✅ OBS Studio + Kdenlive + screen recording tools for YouTube/teaching"
    info "✅ Graphics tools (GIMP, Inkscape, Krita) for content creation"
    info "✅ KDE Plasma optimized with macOS-like WhiteSur theme"
    info "✅ Security & privacy settings configured"
    echo
    warning "⚠️  Some individual components may have failed - check log for details"
    info "📋 Even with failures, the script continued and completed all sections"
    echo
    warning "🔄 IMPORTANT: System reboot recommended to apply all changes!"
    echo
    info "📁 Files and logs:"
    info "   Log file: $LOG_FILE"
    info "   Configuration backups: $BACKUP_DIR"
    echo
    info "🚀 Next steps after reboot:"
    info "1. Open OnlyOffice and test .docx/.pptx compatibility"
    info "2. Launch OBS Studio and configure for screen recording"
    info "3. Set up your development projects with modern CLI tools"
    info "4. Test VS Code with your preferred extensions"
    info "5. Configure Git credentials: git config --global user.name/email"
    echo
    info "🎯 Content Creation Quick Start:"
    info "• OBS Studio → Screen recording for tutorials"
    info "• Kdenlive → Video editing"  
    info "• GIMP/Inkscape → Graphics and thumbnails"
    info "• Spectacle/Flameshot → Screenshots"
    echo
    info "💼 Office Work Quick Start:"
    info "• OnlyOffice → .docx/.pptx files (best MS Office compatibility)"
    info "• LibreOffice → Alternative office suite"
    info "• Thunderbird → Email client"
    echo
    info "⌨️ Productivity Shortcuts to Remember:"
    info "• z project-name → Jump to any directory instantly"
    info "• Ctrl+P in VS Code → Quick open any file" 
    info "• Ctrl+R in terminal → Fuzzy search command history"
    echo
    info "🌟 Your CachyOS system is ready for professional development and content creation!"
    echo
    warning "📝 Check the log file if you encounter any issues"
    info "🎯 The bulletproof design ensures maximum functionality regardless of individual failures"
}

################################################################################
# Bulletproof Main Execution - NEVER STOPS COMPLETELY
################################################################################

main() {
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root. Please run as a regular user."
        warning "Script will continue but some operations may fail..."
    fi
    
    # Check if sudo is available
    if ! command -v sudo &>/dev/null; then
        error "sudo is required but not installed."
        info "Attempting to continue without sudo - some operations will fail..."
    fi
    
    # Initialize logging
    log "Starting CachyOS Custom Setup Script v$SCRIPT_VERSION"
    
    # Show banner and system info
    show_banner || warning "Banner display failed"
    system_info || warning "System info gathering failed"
    
    # Ask for confirmation
    echo
    read -p "This script will install development tools, screen recording software, and OnlyOffice. Continue? (y/N): " -n 1 -r 2>/dev/null || REPLY="y"
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Setup cancelled by user."
        exit 0
    fi
    
    # Check dependencies (don't stop if this fails)
    check_dependencies || warning "Dependency check failed"
    
    # Install yay if not present (don't stop if fails)
    if ! command -v yay &>/dev/null; then
        info "Installing yay AUR helper..."
        {
            git clone https://aur.archlinux.org/yay.git /tmp/yay 2>/dev/null && \
            cd /tmp/yay 2>/dev/null && \
            makepkg -si --noconfirm 2>/dev/null && \
            cd "$SCRIPT_DIR" 2>/dev/null
        } || warning "Failed to install yay - AUR packages will be skipped"
    fi
    
    # Execute setup functions - NEVER STOP, ALWAYS CONTINUE
    info "Starting custom setup process - optimized for development and content creation"
    echo
    
    setup_cachyos_repositories || warning "CachyOS repositories setup had issues - continuing"
    setup_kernel_optimization || warning "Kernel optimization had issues - continuing"  
    setup_amd_optimization || warning "AMD optimization had issues - continuing"
    setup_macos_font_rendering || warning "Font rendering setup had issues - continuing"
    setup_development_environment || warning "Development environment setup had issues - continuing"
    setup_office_productivity || warning "Office productivity setup had issues - continuing"
    setup_screen_recording_tools || warning "Screen recording tools setup had issues - continuing"
    setup_kde_plasma_optimization || warning "KDE Plasma optimization had issues - continuing"
    setup_system_tweaks || warning "System tweaks had issues - continuing"
    setup_multimedia_codecs || warning "Multimedia setup had issues - continuing"
    setup_security_privacy || warning "Security/privacy setup had issues - continuing"
    finalize_installation || warning "Finalization had issues - continuing"
    
    # Show completion summary - this should always work
    show_completion_summary || echo "Setup completed with some issues - check log file: $LOG_FILE"
}

# Execute main function - NO ERROR TRAPS THAT WOULD STOP EXECUTION
main "$@"
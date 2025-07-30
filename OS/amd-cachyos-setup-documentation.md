# CachyOS Custom Setup Script - Complete Documentation

## 📋 **Overview**

This script transforms a fresh CachyOS installation into a professional development and content creation workstation optimized for:
- **Full-stack development** with modern tools
- **Screen recording and YouTube content creation**
- **Office productivity** with Microsoft Office compatibility
- **AMD Ryzen 7 5700U** specific optimizations
- **macOS-quality** font rendering with international language support

---

## 🚀 **Installation Guide**

### **Prerequisites**
- Fresh CachyOS installation
- Internet connection
- User account with sudo privileges

### **How to Run**
```bash
# 1. Download the script
curl -L -o cachyos-setup.sh [script-url]

# 2. Make executable
chmod +x cachyos-setup.sh

# 3. Run the script
./cachyos-setup.sh

# 4. Follow prompts and wait for completion
# 5. Reboot when finished
sudo reboot
```

### **What to Expect**
- **Duration**: 30-60 minutes (depending on internet speed)
- **Progress**: 13 steps with clear progress indicators
- **Bulletproof**: Script continues even if individual components fail
- **Logging**: All actions logged to `/tmp/cachyos-setup-[timestamp].log`
- **Backups**: Original configs backed up to `~/.config/cachyos-setup-backup-[timestamp]/`

---

## 🛠️ **Development Environment**

### **Programming Languages & Runtimes**
**What's Installed:**
- Node.js + npm
- Python + pip
- Go, Rust, Java (OpenJDK)
- GCC, Clang, CMake, Make

**How to Use:**
```bash
# Check versions
node --version
python --version
go version
rustc --version

# Start new projects
npm init                    # Node.js project
cargo new my-rust-app       # Rust project
go mod init my-go-app       # Go project
```

### **Modern Version Manager (mise)**
**What it Does:** Manages multiple versions of programming languages

**How to Use:**
```bash
# Install specific versions
mise install node@18.17.0
mise install python@3.11.5

# Set global versions
mise global node@18.17.0
mise global python@3.11.5

# List available versions
mise list-all node
mise list-all python
```

### **Container Tools (Podman)**
**What's Installed:** Podman (rootless Docker alternative) + Buildah

**How to Use:**
```bash
# Pull and run containers
podman pull nginx
podman run -d -p 8080:80 nginx

# Build images
podman build -t myapp .

# Manage containers
podman ps                   # List running containers
podman images              # List images
podman-compose up          # Docker-compose alternative
```

### **Databases**
**What's Installed:** PostgreSQL, Redis, MariaDB, SQLite

**How to Use:**
```bash
# Start services
sudo systemctl start postgresql
sudo systemctl start redis
sudo systemctl start mariadb

# Connect to databases
psql -U postgres           # PostgreSQL
redis-cli                  # Redis
mysql -u root -p           # MariaDB
sqlite3 database.db       # SQLite
```

### **Web Servers**
**What's Installed:** Nginx, Caddy

**How to Use:**
```bash
# Nginx
sudo systemctl start nginx
# Config: /etc/nginx/nginx.conf
# Web root: /var/www/html

# Caddy (automatic HTTPS)
caddy run                  # Run with Caddyfile
caddy file-server          # Simple file server
```

---

## 💻 **Modern CLI Tools**

### **Enhanced Command Replacements**
| Old Command | New Tool | Usage Example |
|-------------|----------|---------------|
| `ls` | `eza` | `ll` (shows detailed list with colors) |
| `cat` | `bat` | `bat file.js` (syntax highlighting) |
| `find` | `fd` | `fd "*.js"` (faster, simpler syntax) |
| `grep` | `ripgrep` | `rg "function"` (faster searching) |
| `du` | `dust` | `dust` (visual disk usage) |
| `df` | `duf` | `duf` (prettier filesystem info) |
| `cd` | `zoxide` | `z project` (smart directory jumping) |

### **Essential Productivity Tools**

#### **fzf (Fuzzy Finder)**
```bash
# Search files
Ctrl + T                   # Insert file path

# Search command history  
Ctrl + R                   # Interactive history search

# Search directories
Alt + C                    # Change to selected directory
```

#### **zoxide (Smart cd)**
```bash
# Jump to directories (learns from your usage)
z documents               # Jump to Documents
z proj                    # Jump to Projects
z backend                 # Jump to backend folder
zi                        # Interactive directory picker
```

#### **starship (Modern Prompt)**
Automatically shows:
- Current directory
- Git status
- Programming language versions
- Command execution time

---

## 📝 **Office & Productivity Tools**

### **OnlyOffice (Primary Office Suite)**
**Best for:** Microsoft Office compatibility (.docx, .pptx, .xlsx)

**How to Use:**
```bash
# Launch OnlyOffice
onlyoffice-desktopeditors

# Or from application menu: Office → OnlyOffice
```

**Features:**
- Near-perfect MS Office compatibility
- Real-time collaboration
- Modern interface similar to MS Office
- Support for complex formatting

### **LibreOffice (Backup Suite)**
**How to Use:**
```bash
libreoffice --writer      # Word alternative
libreoffice --calc        # Excel alternative  
libreoffice --impress     # PowerPoint alternative
```

### **PDF Tools**
- **Okular**: Advanced PDF viewer with annotations
- **Evince**: Simple PDF viewer
- **qpdfview**: Alternative PDF viewer

### **Note-Taking & Writing**
- **Kate**: Advanced text editor with syntax highlighting
- **Obsidian**: Modern note-taking with linking
- **GhostWriter**: Distraction-free Markdown editor

### **Email & Calendar**
- **Thunderbird**: Professional email client
- **KOrganizer**: Calendar and task management
- **Kontact**: Complete PIM suite

---

## 🎥 **Screen Recording & Content Creation**

### **OBS Studio (Professional Recording)**
**How to Use:**
1. **Launch OBS Studio**
2. **Add Sources:**
   - **Display Capture**: Record entire screen
   - **Window Capture**: Record specific window
   - **Audio Input/Output**: Capture microphone/system audio

3. **Recording Setup:**
   ```
   Settings → Output → Recording
   - Format: MP4
   - Encoder: x264
   - Quality: High Quality, Medium File Size
   ```

4. **Start Recording:** Click "Start Recording" or `Ctrl + Shift + R`

**Advanced Features:**
- **Virtual Camera**: Share screen in video calls
- **Streaming**: Direct to YouTube/Twitch
- **Scenes**: Switch between different layouts

### **Video Editing**

#### **Kdenlive (Professional Editor)**
**How to Use:**
1. **Import Media**: Drag files to Project Bin
2. **Timeline Editing**: Drag clips to timeline
3. **Effects**: Add transitions, filters, titles
4. **Export**: Render → Custom → MP4

**Features:**
- Multi-track editing
- Professional effects and transitions
- Audio mixing
- Color correction

#### **OpenShot (Simple Editor)**
**Best for:** Quick edits and simple projects
- Drag-and-drop interface
- Basic cuts, transitions, titles
- Easy to learn

### **Screen Capture Tools**

#### **Spectacle (KDE Screenshot Tool)**
```bash
# Shortcuts (configure in System Settings)
Print                     # Full screen
Shift + Print            # Select area
Alt + Print              # Current window
```

#### **Flameshot (Advanced Screenshots)**
```bash
flameshot gui            # Launch capture tool
# Features: arrows, text, blur, upload to cloud
```

#### **Peek (GIF Recorder)**
```bash
peek                     # Launch GIF recorder
# Record small area as animated GIF
```

### **Graphics & Design**

#### **GIMP (Image Editor)**
**How to Use:**
1. **Open Image**: File → Open
2. **Basic Edits**: Colors → Auto → White Balance
3. **Resize**: Image → Scale Image
4. **Export**: File → Export As → .jpg/.png

#### **Inkscape (Vector Graphics)**
**Best for:** Logos, icons, scalable graphics
- **Text Tool**: Create titles and graphics
- **Shape Tools**: Rectangles, circles, paths
- **Export**: File → Export PNG Image

#### **Krita (Digital Art)**
**Best for:** Digital painting, concept art
- Pressure-sensitive brush support
- Professional art tools
- Animation capabilities

### **Communication Tools**
- **Discord**: Community and streaming
- **Zoom**: Video conferences and recording
- **Teams**: Business meetings

---

## 🎨 **macOS-Quality Typography**

### **Font Rendering Features**
- **LucidGlyph**: Latest 2025 font rendering technology
- **Subpixel Hinting**: Sharp, clear text
- **International Support**: Bengali/Arabic fonts
- **Microsoft Font Compatibility**: Better document display

### **Installed Font Collections**
- **System Fonts**: Tex Gyre Heros (San Francisco alternative)
- **Bengali**: Kalpurush, SiyamRupali, Noto Sans Bengali
- **Arabic**: Amiri, Scheherazade New, Noto Sans Arabic
- **Development**: Liberation Mono, DejaVu Sans Mono
- **Content Creation**: Google Fonts, Adobe Source Sans

### **How Fonts Are Configured**
- Automatic font substitution for better compatibility
- Language-specific font selection
- Optimized rendering for different screen types

---

## 🖥️ **KDE Plasma Customization**

### **macOS-like Theme (WhiteSur)**
**What's Applied:**
- **Window Decorations**: macOS-style title bars
- **Icons**: macOS Big Sur icon set
- **Cursors**: macOS pointer style
- **Colors**: macOS color scheme

### **Performance Optimizations**
- **GPU Acceleration**: OpenGL compositor
- **Animation Speed**: Balanced for smoothness
- **Effects**: Optimized for performance

### **Dock Configuration**
- **Floating Panel**: macOS-style dock behavior
- **Auto-hide**: Maximizes screen space
- **Icon-only**: Clean, minimal appearance

---

## ⚡ **System Performance**

### **AMD Ryzen 7 5700U Optimizations**
- **CPU Governor**: Schedutil for responsiveness
- **Power Management**: TLP configured for balance
- **Graphics**: AMDGPU fully enabled
- **Memory**: ZRAM compression for better performance

### **Boot Optimizations**
- **Kernel Parameters**: AMD-specific optimizations
- **I/O Schedulers**: Optimized for SSD/NVMe
- **Process Priority**: Automatic priority management

### **Memory Management**
- **Swappiness**: Reduced to prefer RAM
- **ZRAM**: Compressed swap in memory
- **Cache Settings**: Optimized for interactive use

---

## 🔧 **Productivity Workflows**

### **Development Workflow**
```bash
# 1. Navigate to project
z myproject

# 2. Open in VS Code
code .

# 3. Start development server
npm run dev

# 4. Open additional terminal
Ctrl + Shift + `
```

### **Content Creation Workflow**
```bash
# 1. Prepare recording
obs                      # Launch OBS Studio

# 2. Record content
# Configure sources and start recording

# 3. Edit video
kdenlive                 # Launch video editor

# 4. Create thumbnails
gimp                     # Launch image editor
```

### **Office Workflow**
```bash
# 1. Open document
onlyoffice-desktopeditors

# 2. Edit and collaborate
# Work on .docx/.pptx files

# 3. Export/share
# Save in Microsoft Office formats
```

---

## ⌨️ **Essential Shortcuts**

### **System-Wide (KDE)**
| Shortcut | Action |
|----------|--------|
| `Super + T` | Open Terminal |
| `Super + E` | Open File Manager |
| `Super + L` | Lock Screen |
| `Ctrl + Alt + T` | Open Terminal |
| `Print` | Screenshot |
| `Alt + F4` | Close Window |
| `Super + Left/Right` | Snap Window |

### **VS Code**
| Shortcut | Action |
|----------|--------|
| `Ctrl + P` | Quick Open File |
| `Ctrl + Shift + P` | Command Palette |
| `Ctrl + `` ` | Toggle Terminal |
| `Ctrl + D` | Multi-cursor Selection |
| `Ctrl + /` | Toggle Comment |

### **Terminal**
| Shortcut | Action |
|----------|--------|
| `Ctrl + R` | Fuzzy History Search |
| `Ctrl + T` | Fuzzy File Search |
| `Alt + C` | Fuzzy Directory Search |
| `Ctrl + L` | Clear Screen |
| `Ctrl + C` | Cancel Command |

### **Modern CLI**
| Command | Description |
|---------|-------------|
| `z project` | Jump to project directory |
| `ll` | Detailed file listing |
| `bat file.js` | View file with syntax highlighting |
| `fd "*.py"` | Find Python files |
| `rg "function"` | Search for text in files |

---

## 🔍 **Troubleshooting**

### **Common Issues**

#### **Package Installation Failed**
```bash
# Update package databases
sudo pacman -Sy

# Try installing manually
sudo pacman -S package-name

# Check AUR helper
yay -S aur-package-name
```

#### **Font Rendering Issues**
```bash
# Rebuild font cache
fc-cache -fv

# Check font configuration
fc-list | grep -i "font-name"
```

#### **OBS Audio Issues**
```bash
# Check audio devices
pacmd list-sources
pacmd list-sinks

# Restart PulseAudio
pulseaudio -k && pulseaudio --start
```

#### **VS Code Extensions Not Working**
```bash
# Reset VS Code settings
rm -rf ~/.config/Code/User/settings.json

# Reinstall extensions
code --install-extension ms-python.python
```

### **Log Files**
- **Script Log**: `/tmp/cachyos-setup-[timestamp].log`
- **System Log**: `journalctl -xe`
- **Package Log**: `/var/log/pacman.log`

### **Configuration Backups**
Original configurations backed up to:
`~/.config/cachyos-setup-backup-[timestamp]/`

---

## 🎯 **Quick Start Guides**

### **First-Time Setup**
1. **Reboot** after script completion
2. **Configure Git**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```
3. **Test OnlyOffice** with a .docx file
4. **Launch OBS Studio** and test screen recording
5. **Open VS Code** and install preferred extensions

### **Development Project Setup**
```bash
# Create new project
mkdir my-project && cd my-project

# Initialize git
git init

# Open in VS Code
code .

# Add to zoxide for quick access
# (automatically happens when you visit the directory)
```

### **Content Creation Setup**
1. **Configure OBS**:
   - Add Display Capture source
   - Set up microphone input
   - Configure recording settings
2. **Test Recording**:
   - Record a short test video
   - Check audio levels
3. **Set up Kdenlive**:
   - Create new project
   - Import test footage
   - Export test video

### **Office Document Setup**
1. **Open OnlyOffice**
2. **Test Microsoft Office files**:
   - Open existing .docx/.pptx files
   - Create new documents
   - Test formatting compatibility
3. **Configure Thunderbird** for email
4. **Set up KOrganizer** for calendar

---

## 📚 **Advanced Tips**

### **Development Optimization**
```bash
# Use mise for project-specific versions
echo "node 18.17.0" > .tool-versions
echo "python 3.11.5" >> .tool-versions

# Container development
podman run -it --rm -v $(pwd):/workspace node:18 bash
```

### **Content Creation Tips**
- **OBS Scenes**: Create different layouts for different content types
- **Kdenlive Proxy**: Enable proxy clips for 4K footage
- **Audio**: Use Audacity for post-processing audio

### **Office Productivity**
- **OnlyOffice**: Use collaboration features for team work
- **Templates**: Create document templates for consistent formatting
- **PDF Export**: Export to PDF for universal compatibility

### **System Maintenance**
```bash
# Update system
sudo pacman -Syu

# Clean package cache
sudo pacman -Sc

# Update AUR packages
yay -Syu

# Rebuild font cache
fc-cache -fv
```

---

## 🌟 **Conclusion**

This script creates a professional-grade workstation that excels in:
- **Development**: Modern tools, fast workflow, excellent performance
- **Content Creation**: Professional recording and editing capabilities
- **Office Work**: Perfect Microsoft Office compatibility
- **Daily Use**: Beautiful interface, optimized performance, great typography

The bulletproof design ensures maximum functionality even if some components fail during installation. All configurations are backed up, and the system is optimized specifically for AMD Ryzen 7 5700U hardware.
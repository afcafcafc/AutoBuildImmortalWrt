#!/bin/bash
# Log file for debugging
source shell/custom-packages.sh
echo "第三方软件包: $CUSTOM_PACKAGES"
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE
echo "编译固件大小为: $PROFILE MB"
echo "Include Docker: $INCLUDE_DOCKER"

echo "Create pppoe-settings"
mkdir -p  /home/build/immortalwrt/files/etc/config

# 创建pppoe配置文件 yml传入环境变量ENABLE_PPPOE等 写入配置文件 供99-custom.sh读取
cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF

echo "cat pppoe-settings"
cat /home/build/immortalwrt/files/etc/config/pppoe-settings

if [ -z "$CUSTOM_PACKAGES" ]; then
  echo "⚪️ 未选择 任何第三方软件包"
else
  # ============= 同步第三方插件库==============
  # 同步第三方软件仓库run/ipk
  echo "🔄 正在同步第三方软件仓库 Cloning run file repo..."
  git clone --depth=1 https://github.com/wukongdaily/store.git /tmp/store-run-repo

  # 拷贝 run/x86 下所有 run 文件和ipk文件 到 extra-packages 目录
  mkdir -p /home/build/immortalwrt/extra-packages
  cp -r /tmp/store-run-repo/run/x86/* /home/build/immortalwrt/extra-packages/

  echo "✅ Run files copied to extra-packages:"
  ls -lh /home/build/immortalwrt/extra-packages/*.run
  # 解压并拷贝ipk到packages目录
  sh shell/prepare-packages.sh
  ls -lah /home/build/immortalwrt/packages/
fi

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建固件..."

# ============= imm仓库内的插件==============
# 定义所需安装的包列表 下列插件你都可以自行删减
PACKAGES=""


packages=(
  luci-i18n-airplay2-zh-cn
  luci-i18n-openlist-zh-cn
  luci-app-argon-config
  luci-i18n-ddns-go-zh-cn
  luci-i18n-frpc-zh-cn
  luci-i18n-ttyd-zh-cn
  luci-i18n-vsftpd-zh-cn
  luci-i18n-wol-zh-cn
  luci-i18n-zerotier-zh-cn
  luci-i18n-autoreboot-zh-cn
  luci-i18n-firewall-zh-cn
  luci-app-argon-config
  luci-i18n-argon-config-zh-cn
  luci-i18n-diskman-zh-cn
  luci-i18n-package-manager-zh-cn
  luci-i18n-ttyd-zh-cn
  luci-app-openclash
  luci-i18n-samba4-zh-cn
  openssh-sftp-server
  ppp-mod-pptp
  script-utils
  fdisk
  xl2tpd
  adb
  curl
  ntpdate
  usbutils
  python3
  python3-pip
  python3-requests  
  kmod-usb-core
  kmod-xfrm-interface
  kmod-ipsec
  kmod-ipsec4
  kmod-ipsec6
  iptables-mod-ipsec
  iptables-nft
  kmod-usb2
  kmod-usb3
  mt7601u-firmware
  #kmod-usb-net-rtl8152
  kmod-usb-net-asix-ax88179
  kmod-usb-net-asix
  kmod-ath9k-htc
  kmod-mt76
  kmod-mt7601u
  kmod-mt76x0u
  kmod-mt76x2u
  kmod-mt7921u
  kmod-usb-ohci
  kmod-usb-uhci
  kmod-ata-ahci
  kmod-ata-core
  kmod-fs-ntfs
  kmod-fs-ext4
  kmod-usb-storage
  kmod-usb-storage-extras
  kmod-usb-serial
  kmod-usb-serial-pl2303
  kmod-usb-serial-ch341
  kmod-usb-printer
  kmod-usb-net-rndis
  kmod-i2c-core
  kmod-i2c-gpio
  kmod-spi-dev
  kmod-gpio-button-hotplug
  kmod-leds-gpio
  kmod-hid
  kmod-hid-generic
  kmod-sound-core
  kmod-usb-audio
)

# 使用循环逐个追加
for pkg in "${packages[@]}"; do
  PACKAGES="$PACKAGES $pkg"
done

# （可选）去重，防止重复包名
PACKAGES=$(echo "$PACKAGES" | tr ' ' '\n' | sort -u | tr '\n' ' ')


# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-i18n-dockerman-zh-cn"
fi

# 若构建openclash 则添加内核
if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
    echo "✅ 已选择 luci-app-openclash，添加 openclash core"
    mkdir -p files/etc/openclash/core
    # Download clash_meta
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz"
    wget -qO- $META_URL | tar xOvz > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta
    # Download GeoIP and GeoSite
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O files/etc/openclash/GeoIP.dat
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O files/etc/openclash/GeoSite.dat
else
    echo "⚪️ 未选择 luci-app-openclash"
fi

# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE="generic" PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$PROFILE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."

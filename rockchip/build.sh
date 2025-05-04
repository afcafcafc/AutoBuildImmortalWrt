#!/bin/bash
# Log file for debugging
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE
# yml 传入的路由器型号 PROFILE
echo "Building for profile: $PROFILE"
# yml 传入的固件大小 ROOTFS_PARTSIZE
echo "Building for ROOTFS_PARTSIZE: $ROOTFS_PARTSIZE"

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

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting build process..."


# 定义所需安装的包列表 下列插件你都可以自行删减
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
# 服务——FileBrowser 用户名admin 密码admin
PACKAGES="$PACKAGES luci-i18n-filebrowser-go-zh-cn"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-passwall-zh-cn"
PACKAGES="$PACKAGES luci-app-openclash"
PACKAGES="$PACKAGES luci-i18n-homeproxy-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
# 增加几个必备组件 方便用户安装iStore
PACKAGES="$PACKAGES fdisk"
PACKAGES="$PACKAGES script-utils"
PACKAGES="$PACKAGES luci-i18n-samba4-zh-cn"
# 定义所需安装的包列表
PACKAGES=""


packages=(
  luci-i18n-airplay2-zh-cn
  luci-i18n-alist-zh-cn
  luci-app-argon-config
  luci-i18n-ddns-go-zh-cn
  luci-i18n-frpc-zh-cn
  luci-i18n-ttyd-zh-cn
  luci-i18n-vsftpd-zh-cn
  luci-i18n-wol-zh-cn
  luci-i18n-zerotier-zh-cn
  #luci-app-autoreboot
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
  luci-i18n-dockerman-zh-cn
  #luci-app-autoreboot-zh-cn
  #luci-app-ipsec-vpnd
  #luci-app-softethervpn
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
  kmod-usb-net-rtl8152
  kmod-usb-net-asix-ax88179
  kmod-usb-net-asix
  kmod-ath9k-htc
  kmod-mt76
  kmod-mt7601u
  kmod-mt76x0u
  kmod-mt76x2u
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
for pkg in "${packages[@]}"; do
  PACKAGES="$PACKAGES $pkg"
done

# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE=$PROFILE PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$ROOTFS_PARTSIZE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."

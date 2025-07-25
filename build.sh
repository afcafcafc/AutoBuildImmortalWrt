#!/bin/bash
# yml 传入的路由器型号 PROFILE
echo "Building for profile: $PROFILE"
echo "Include Docker: $INCLUDE_DOCKER"
# yml 传入的固件大小 ROOTFS_PARTSIZE
echo "Building for ROOTFS_PARTSIZE: $ROOTSIZE"

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting build process..."


# 定义所需安装的包列表
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
for pkg in "${packages[@]}"; do
  PACKAGES="$PACKAGES $pkg"
done



# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-i18n-dockerman-zh-cn"
fi


# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE=$PROFILE PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$ROOTSIZE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."

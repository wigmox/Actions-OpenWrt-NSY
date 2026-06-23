dir=`pwd`
mkdir custfeed
sed -i "1i src-link external $dir/custfeed" feeds.conf.default

#sed -i '1i src-git pppoex https://github.com/pppoex/openwrt-packages.git' feeds.conf.default
git clone https://github.com/immortalwrt/immortalwrt.git immortalwrt --depth=1
git clone https://github.com/immortalwrt/luci.git  immortalwrt_luci  --depth=1
git clone https://github.com/immortalwrt/packages.git immortalwrt_package  --depth=1
cp -rp immortalwrt/package/emortal/cpufreq custfeed/
cp -rp immortalwrt_package/net/ddns-go custfeed/
cp -rp immortalwrt_luci/applications/luci-app-cpufreq custfeed/
cp -rp immortalwrt_luci/applications/luci-app-ddns-go custfeed/
cp -rp immortalwrt_luci/applications/luci-app-zerotier custfeed/

find custfeed/ -type f -name 'Makefile' -exec sed -i 's|\.\./\.\./luci\.mk|$(TOPDIR)/feeds/luci/luci.mk|g' {} +
find custfeed/ -type f -name 'Makefile' -exec sed -i 's|\.\./\.\./lang|$(TOPDIR)/feeds/packages/lang|g' {} +


./scripts/feeds update -a
./scripts/feeds install -a
#echo "# CONFIG_ALL_NONSHARED is not set" >> .config
#echo "# CONFIG_ALL_KMODS is not set" >> .config
#echo "# CONFIG_ALL is not set" >> .config
#echo CONFIG_PACKAGE-luci-app-cpufreq=y >> .config
#echo CONFIG_PACKAGE-luci-app-ddns-go=y >> .config
#echo CONFIG_PACKAGE-luci-app-zerotier=y >> .config
make defconfig
make package/luci-app-cpufreq/compile \
    package/luci-app-ddns-go/compile \
    package/luci-app-zerotier/compile \
    -j4
make package/index
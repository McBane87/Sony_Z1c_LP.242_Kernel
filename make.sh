### GCC 4.9.x

rm -f arch/arm/boot/*.dtb
rm -f .version

### get defconfig
ARCH=arm CROSS_COMPILE=./arm-eabi-4.6/bin/arm-eabi- make rhine_amami_row_defconfig

### compile kernel
ARCH=arm CROSS_COMPILE=./arm-eabi-4.6/bin/arm-eabi- make CONFIG_NO_ERROR_ON_MISMATCH=y

echo "checking for compiled kernel..."
if [[ -f arch/arm/boot/zImage || -f arch/arm/boot/Image ]]; then

	echo "generating device tree..."
	./dtbTool -o dt.img -s 2048 -p ./scripts/dtc/ ./arch/arm/boot/
	echo "DONE"

fi

if [[ -f arch/arm/boot/zImage  ]]; then
       kernel=arch/arm/boot/zImage
elif [[ -f arch/arm/boot/Image  ]]; then
       kernel=arch/arm/boot/Image
fi

echo "creating boot.img"


if [[ -f dt.img  ]]; then
       echo "dt.img found and will be included"
	### D5503
       ./mkbootimg --cmdline "androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3b7 ehci-hcd.park=3 androidboot.bootdevice=msm_sdcc.1 vmalloc=300M dwc3.maximum_speed=high dwc3_msm.prop_chg_detect=Y" --base 0x00000000 --kernel $kernel --ramdisk kernel.sin-ramdisk.cpio.gz --ramdisk_offset 0x02000000 -o boot.img --dt dt.img --tags_offset 0x01E00000
else
       echo "dt.img not found, creating without it"
	### D5503
        ./mkbootimg --cmdline "androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3b7 ehci-hcd.park=3 androidboot.bootdevice=msm_sdcc.1 vmalloc=300M dwc3.maximum_speed=high dwc3_msm.prop_chg_detect=Y" --base 0x00000000 --kernel $kernel --ramdisk kernel.sin-ramdisk.cpio.gz --ramdisk_offset 0x02000000 -o boot.img --tags_offset 0x01E00000
fi

echo "DONE"

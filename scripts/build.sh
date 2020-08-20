#!/bin/bash

# Notes:
# - calculate partition offset: use fdisk to get partition start sector and multiple value by 512

case "$1" in
        lite-armhf)
            OS_FILE=2020-05-27-raspios-buster-lite-armhf
            OS_URL=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2020-05-28/${OS_FILE}.zip
            OFFSET_BOOT=4194304         # offset = start sector * 512 =   8192 * 512
            OFFSET_ROOTFS=272629760     # offset = start sector * 512 = 532480 * 512
            ;;
        *)
            echo $"Usage: $0 {lite-armhf}"
            exit 1
esac

SRC_PATH=$PWD
BUILD_PATH=${SRC_PATH}/build

# setup build location

rm -rf ${BUILD_PATH}
BUILD_CACHE_PATH=${BUILD_PATH}/cache && mkdir -p ${BUILD_CACHE_PATH}
BUILD_IMAGE_PATH=${BUILD_PATH}/image && mkdir -p ${BUILD_IMAGE_PATH}
BUILD_MOUNT_PATH=${BUILD_PATH}/mount && mkdir -p ${BUILD_MOUNT_PATH}

# unpack os

TEMP_FILE=${BUILD_CACHE_PATH}/raspios.zip
curl -o ${TEMP_FILE} -fL ${OS_URL}
unzip ${TEMP_FILE} -d ${BUILD_IMAGE_PATH}
rm -rf $TEMP_FILE

OS_IMAGE=${BUILD_IMAGE_PATH}/${OS_FILE}.img

# edit rootfs partition

echo "Editing rootfs partition..."
OS_ROOTFS_PATH=${BUILD_MOUNT_PATH}/rootfs && mkdir -p ${OS_ROOTFS_PATH}
mount -v -o offset=${OFFSET_ROOTFS} -t ext4 ${OS_IMAGE} ${OS_ROOTFS_PATH}

cp --no-preserve=mode,ownership ${SRC_PATH}/config/rootfs/etc/rc.local ${OS_ROOTFS_PATH}/etc/rc.local

umount ${OS_ROOTFS_PATH} || true

# edit boot partition

echo "Editing boot partition..."
OS_BOOT_PATH=${BUILD_MOUNT_PATH}/boot && mkdir -p ${OS_BOOT_PATH}
mount -v -o offset=${OFFSET_BOOT} -t vfat ${OS_IMAGE} ${OS_BOOT_PATH}

cp -r ${SRC_PATH}/config/boot/* ${OS_BOOT_PATH}

umount ${OS_BOOT_PATH} || true

# done

exit 0

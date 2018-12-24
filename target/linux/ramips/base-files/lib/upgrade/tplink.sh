#
# Copyright (C) 2018 OpenWrt.org
#
. /lib/functions/system.sh

tplink_get_uboot_args_partition() {
	local board=$(board_name)

	case "$board" in
	tplink,c50-v4)
		echo "romfile"
		;;
	esac
}

platform_upgrade_tpl_recovery() {
	local uboot_args_part=$(tplink_get_uboot_args_partition)
	local uboot_args_mtd=$(find_mtd_chardev $uboot_args_part)

	dd if=$uboot_args_mtd of=/tmp/romfile && \
	printf '\xef\xcd\xab\x89' | \
	dd of=/tmp/romfile bs=1 seek=0 conv=notrunc \
	&& mtd write /tmp/romfile $uboot_args_part

	default_do_upgrade "$ARGV"

	printf '\x00\x00\x00\x00' | \
	dd of=/tmp/romfile bs=1 seek=0 conv=notrunc \
	&& mtd write /tmp/romfile $uboot_args_part \
	&& rm /tmp/romfile
}

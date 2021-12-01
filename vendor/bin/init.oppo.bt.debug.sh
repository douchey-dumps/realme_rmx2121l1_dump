#! /system/bin/sh
#***********************************************************
#** Copyright (C), 2008-2016, OPPO Mobile Comm Corp., Ltd.
#** VENDOR_EDIT
#**
#** Version: 1.0
#** Date : 2019/11/07
#** Author: Li.Chen@PSW.CN.BT.Basic.Log.2543830, 2019/11/07
#** Add for: mtk bt coredump related log collection and DCS handle
#**
#** ---------------------Revision History: ---------------------
#**  <author>    <data>       <version >       <desc>
#**  Li.Chen    2019/11/07     1.0        build this module
#****************************************************************/

config="$1"

#collectBTCoredumpLog service start kernel log collect and zip file to DCS path
function collectBTCoredumpLog(){
    BT_DUMP_PARENT_DIR=/data/vendor/connsyslog/
    BT_DUMP_PATH=/data/vendor/connsyslog/bt
    DCS_BT_LOG_PATH=/data/oppo/log/DCS/de/network_logs/stp_dump
    if [ ! -d ${DCS_BT_LOG_PATH} ];then
        mkdir -p ${DCS_BT_LOG_PATH}
    fi
    chown -R system:system ${DCS_BT_LOG_PATH}
    chmod -R 777 ${BT_DUMP_PARENT_DIR}
    chmod -R 777 ${BT_DUMP_PATH}

    zip_name=`getprop vendor.connsys.bt.dump.zip.name`
    kinfo_name=`getprop vendor.connsys.bt.dump.kinfo.name`

    debtdumpcount=`ls -l /data/oppo/log/DCS/de/network_logs/stp_dump  | grep "connsys_core_dump" | wc -l`
    enbtdumpcount=`ls -l /data/oppo/log/DCS/en/network_logs/stp_dump  | grep "connsys_core_dump" | wc -l`
    if [ $debtdumpcount -lt 10 ] && [ $enbtdumpcount -lt 10 ];then
        dmesg > ${BT_DUMP_PATH}/${kinfo_name}.kinfo
        sleep 2
        $XKIT tar -czvf  ${DCS_BT_LOG_PATH}/${zip_name}.tar.gz -C ${BT_DUMP_PATH} ${BT_DUMP_PATH}
    fi
    chown -R system:system ${DCS_BT_LOG_PATH}
    chmod -R 777 ${DCS_BT_LOG_PATH}
    rm -rf ${BT_DUMP_PATH}/*

    chown -R system:system ${BT_DUMP_PARENT_DIR}
    chmod -R 776 ${BT_DUMP_PARENT_DIR}
    chmod -R 776 ${BT_DUMP_PATH}
    setprop vendor.connsys.bt.dump.status "0"
}

case "$config" in
        "collectBTCoredumpLog")
        collectBTCoredumpLog
    ;;
esac

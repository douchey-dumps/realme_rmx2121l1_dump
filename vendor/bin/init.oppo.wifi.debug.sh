#! /system/bin/sh
#***********************************************************
#** Copyright (C), 2008-2016, OPPO Mobile Comm Corp., Ltd.
#** VENDOR_EDIT
#** 
#** Version: 1.0
#** Date : 2019/10/18
#** Author: JiaoBo@PSW.CN.WiFi.Basic.Log.1162004, 2019/10/18
#** Add for: mtk coredump related log collection and DCS handle
#**
#** ---------------------Revision History: ---------------------
#**  <author>    <data>       <version >       <desc>
#**  Bo.Jiao    2019/10/18     1.0        build this module
#****************************************************************/

config="$1"

#collectWifiCoredumpLog service start kernel log collect and zip file to DCS path
function collectWifiCoredumpLog(){
    WIFI_DUMP_PARENT_DIR=/data/vendor/connsyslog/
    WIFI_DUMP_PATH=/data/vendor/connsyslog/wifi
    DCS_WIFI_LOG_PATH=/data/oppo/log/DCS/de/network_logs/stp_dump
    if [ ! -d ${DCS_WIFI_LOG_PATH} ];then
        mkdir -p ${DCS_WIFI_LOG_PATH}
    fi
    #WangXia@PSW.CN.WiFi.Connect, 2020/04/10
    #Add for: record wifi core dump time
    WIFI_DUMP_FILE_NOTIFY=/data/oppo/log/DCS/de/network_logs/stp_dump/recordWCDTime
    if [ -f ${WIFI_DUMP_FILE_NOTIFY} ]; then
        rm -rf ${WIFI_DUMP_FILE_NOTIFY}
    fi
    touch ${WIFI_DUMP_FILE_NOTIFY}

    chown -R system:system ${DCS_WIFI_LOG_PATH}
    chmod -R 777 ${WIFI_DUMP_PARENT_DIR}
    chmod -R 777 ${WIFI_DUMP_PATH}

    zip_name=`getprop vendor.connsys.wifi.dump.zip.name`
    kinfo_name=`getprop vendor.connsys.wifi.dump.kinfo.name`
    dump_skip=`getprop oppo.wifi.dump.skip.status`
    if [ -z $dump_skip ];then
        echo "dump_skip is empty"
        setprop oppo.wifi.dump.skip.status "0"
        dump_skip=0
    fi

    dewifidumpcount=`ls -l /data/oppo/log/DCS/de/network_logs/stp_dump  | grep "connsys_core_dump" | wc -l`
    enwifidumpcount=`ls -l /data/oppo/log/DCS/en/network_logs/stp_dump  | grep "connsys_core_dump" | wc -l`
    if [ $dewifidumpcount -lt 10 ] && [ $enwifidumpcount -lt 10 ] && [ $dump_skip -ne 1 ];then
        dmesg > ${WIFI_DUMP_PATH}/${kinfo_name}.kinfo
        sleep 2
        $XKIT tar -czvf  ${DCS_WIFI_LOG_PATH}/${zip_name}.tar.gz -C ${WIFI_DUMP_PATH} ${WIFI_DUMP_PATH}
    fi
    chown -R system:system ${DCS_WIFI_LOG_PATH}
    chmod -R 777 ${DCS_WIFI_LOG_PATH}
    rm -rf ${WIFI_DUMP_PATH}/*

    chown -R system:system ${WIFI_DUMP_PARENT_DIR}
    chmod -R 776 ${WIFI_DUMP_PARENT_DIR}
    chmod -R 776 ${WIFI_DUMP_PATH}
    setprop vendor.connsys.wifi.dump.status "0"
}

case "$config" in
        "collectWifiCoredumpLog")
        collectWifiCoredumpLog
    ;;
esac

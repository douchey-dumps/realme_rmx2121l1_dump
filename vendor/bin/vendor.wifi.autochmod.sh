#!/vendor/bin/sh
#***********************************************************
#** Copyright (C), 2008-2016, OPPO Mobile Comm Corp., Ltd.
#** VENDOR_EDIT
#**
#** Version: 1.0
#** Date : 2020/02/20
#** Author : JiaoBo
#** add for: vendor domain operation
#**
#** ---------------------Revision History: ---------------------
#**  <author>    <data>       <version >       <desc>
#**  Jiao.Bo       2020/02/20     1.0     build this module
#****************************************************************/

config="$1"

#ifdef VENDOR_EDIT
#JiaoBo@PSW.CN.WiFi.Basic.Custom.2795386, 2020/02/20
#Add for: support auto update function, include mtk fw, mtk wifi.cfg, qcom fw, qcom bdf, qcom ini
#common info
defaultVersion="20190101000000"
nullVersion="null"
sauEntityConfigXmlfile=/vendor/etc/vendor_wifi_sau_config.xml
isConfigXmlParseDone="false"
#mtk platform info
mtkWifiSauEntityVersionList="null;null;null;null;null"
mtkWifiSauEntityTypeList=("wifi.cfg" "wifi.fw.soc3" "wifi.fw.soc2" "wifi.fw.soc1" "wifi.nv")
mtkWifiSauEntityVersionFileNameList=(
"wifi.cfg"
"WIFI_RAM_CODE_soc3_0_1_1.bin"
"WIFI_RAM_CODE_soc2_0_3b_1.bin"
"WIFI_RAM_CODE_soc1_0_2_1.bin"
"WIFI")
mtkWifiSauEntityFileNameList=(
"wifi.cfg"
"WIFI_RAM_CODE_soc3_0_1_1.bin;soc3_0_ram_wifi_1_1_hdr.bin;soc3_0_ram_wmmcu_1_1_hdr.bin;soc3_0_patch_wmmcu_1_1_hdr.bin"
"WIFI_RAM_CODE_soc2_0_3b_1.bin;soc2_0_ram_wifi_3b_1_hdr.bin;soc2_0_ram_bt_3b_1_hdr.bin;soc2_0_ram_mcu_3b_1_hdr.bin;soc2_0_patch_mcu_3b_1_hdr.bin"
"WIFI_RAM_CODE_soc1_0_2_1.bin;soc1_0_ram_wifi_2_1_hdr.bin"
"WIFI")
mtkWifiSauEntityVendorPathList=(
"/vendor/firmware/"
"/vendor/firmware/"
"/vendor/firmware/"
"/vendor/firmware/"
"/vendor/firmware/")
#qcom paltform info
qcomWifiSauEntityVersionList="null;null;null"
qcomWifiSauEntityTypeList=("wifi.ini" "wifi.fw" "wifi.bdf")
qcomWifiSauEntityVersionFileNameList=(
"WCNSS_qcom_cfg.ini"
"wlandsp.mbn"
"bin_version")
qcomWifiSauEntityFileNameList=(
"WCNSS_qcom_cfg.ini"
"wlandsp.mbn"
"bin_version;bdwlan.bin")
qcomWifiSauEntityVendorPathList=(
"/vendor/firmware_mnt/"
"/vendor/firmware_mnt/"
"/vendor/firmware_mnt/")

#function: get the entity type index
function getSauEntityTypeIdx() {
    local platform=$1
    local type=$2
    if [ "$platform" = "mtk" ]; then
        if [ "$type" = "wifi.cfg" ]; then
            return 0
        elif [ "$type" = "wifi.fw.soc3" ]; then
            return 1
        elif [ "$type" = "wifi.fw.soc2" ]; then
            return 2
        elif [ "$type" = "wifi.fw.soc1" ]; then
            return 3
        elif [ "$type" = "wifi.nv" ]; then
            return 4
        fi
    elif [ "$platform" = "qcom" ]; then
        if [ "$type" = "wifi.ini" ]; then
            return 0
        elif [ "$type" = "wifi.fw" ]; then
            return 1
        elif [ "$type" = "wifi.bdf" ]; then
            return 2
        fi
    fi
    return 0
}

#function: get the vendor suppprt Entity file name which include version information
function parseSupportSauEntityConfigXml() {
    if [ "$isConfigXmlParseDone" = "false" ]; then
        local cmd=`sed -n -e 's/<Entity //' -e 's/\/>//p' $sauEntityConfigXmlfile | sed -e 's/platform="//' -e 's/type="//' -e 's/versionFileName="//' -e 's/fileNameList="//' -e 's/"//g'`
        execute=($(echo $cmd))
        local length=${#execute[*]}
        local i=0
        while [ i -lt length ]
        do
            local platform=${execute[i]}
            local type=${execute[++i]}
            local versionFileName=${execute[++i]}
            local fileNameList=${execute[++i]}
            getSauEntityTypeIdx $platform $type
            local typeIdx=$?
            if [ "$platform" = "mtk" ]; then
                mtkWifiSauEntityVersionFileNameList[typeIdx]=$versionFileName
                mtkWifiSauEntityFileNameList[typeIdx]=$fileNameList
            elif [ "$platform" = "qcom" ]; then
                qcomWifiSauEntityVersionFileNameList[typeIdx]=$versionFileName
                qcomWifiSauEntityFileNameList[typeIdx]=$fileNameList
            fi
            echo "Entity$typeIdx: platform:$platform type:$type"
            echo "         versionFileName:${mtkWifiSauEntityVersionFileNameList[typeIdx]}"
            echo "         fileNameList:${mtkWifiSauEntityFileNameList[typeIdx]}"
            i=$((i+1))
        done
        isConfigXmlParseDone="true"
    else
        echo "already parse done."
    fi
}

#function: get all vendor suppprt Entity version for mtk
function sauMtkWifiObjsVendorVerGet() {
    parseSupportSauEntityConfigXml
    mtkWifiSauEntityVersionList=""
    local length=${#mtkWifiSauEntityTypeList[@]}
    local i=0
    while [ i -lt length ]
    do
        local type=${mtkWifiSauEntityTypeList[i]}
        local file=${mtkWifiSauEntityVendorPathList[i]}${mtkWifiSauEntityVersionFileNameList[i]}
        if [ -f $file ]; then
            if [ "$type" = "wifi.cfg" ]; then
                str=`head -c 25 $file`
                version=${str:9:14}
            elif [ "$type" = "wifi.fw.soc3" ]; then
                str=`tail -c 19 $file`
                version=${str:0:14}
            elif [ "$type" = "wifi.fw.soc2" ]; then
                str=`tail -c 19 $file`
                version=${str:0:14}
            elif [ "$type" = "wifi.fw.soc1" ]; then
                str=`tail -c 19 $file`
                version=${str:0:14}
            elif [ "$type" = "wifi.nv" ]; then
                #default not support update this entity
                version=$nullVersion
            else
                version=$nullVersion
            fi
        else
            version=$nullVersion
        fi
        mtkWifiSauEntityVersionList+=$version";"
        i=$((i+1))
    done
    mtkWifiSauEntityVersionList=${mtkWifiSauEntityVersionList%;*}
    echo "mtkWifiSauEntityVersionList=$mtkWifiSauEntityVersionList"
}

#function: get all vendor suppprt Entity version for qcom
function sauQcomWifiObjsVendorVerGet() {
    parseSupportSauEntityConfigXml
    qcomWifiSauEntityVersionList=""
    local length=${#qcomWifiSauEntityTypeList[@]}
    local i=0
    while [ i -lt length ]
    do
        local type=${qcomWifiSauEntityTypeList[i]}
        local file=${qcomWifiSauEntityVendorPathList[i]}${qcomWifiSauEntityVersionFileNameList[i]}
        if [ -f $file ]; then
            if [ "$type" = "wifi.ini" ]; then
                #default not support update this entity
                version=$nullVersion
            elif [ "$type" = "wifi.fw" ]; then
                #default not support update this entity
                version=$nullVersion
            elif [ "$type" = "wifi.bdf" ]; then
                #default not support update this entity
                version=$nullVersion
            else
                version=$nullVersion
            fi
        else
            version=$nullVersion
        fi
        qcomWifiSauEntityVersionList+=$version";"
        i=$((i+1))
    done
    qcomWifiSauEntityVersionList=${qcomWifiSauEntityVersionList%;*}
    echo "qcomWifiSauEntityVersionList=$qcomWifiSauEntityVersionList"
}

#function: set the versionlist to attribute when bootup
function sauWifiVendorVerBootCheck() {
    local platform=$1
    if [ "$platform" = "mtk" ]; then
        setprop persist.vendor.mtk.wifi.sau.version.oper "idle"
        sauMtkWifiObjsVendorVerGet
        setprop persist.vendor.mtk.wifi.sau.version $mtkWifiSauEntityVersionList
        setprop persist.vendor.mtk.wifi.sau.version.oper "mtk-bootcheck-done"
    elif [ "$platform" = "qcom" ]; then
        setprop persist.vendor.qcom.wifi.sau.version.oper "idle"
        sauQcomWifiObjsVendorVerGet
        setprop persist.vendor.qcom.wifi.sau.version $qcomWifiSauEntityVersionList
        setprop persist.vendor.qcom.wifi.sau.version.oper "qcom-bootcheck-done"
    fi
}

#function: set the versionlist to attribute when sau upgrade
function sauWifiVendorVerUpgradeCheck() {
    local platform=$1
    echo "sauWifiVendorVerUpgradeCheck platform=$platform"
    if [ "$platform" = "mtk" ]; then
        setprop persist.vendor.mtk.wifi.sau.version.oper "idle"
        sauMtkWifiObjsVendorVerGet
        setprop persist.vendor.mtk.wifi.sau.version $mtkWifiSauEntityVersionList
        setprop persist.vendor.mtk.wifi.sau.version.oper "mtk-upgradeCheck-done"
    elif [ "$platform" = "qcom" ]; then
        setprop persist.vendor.qcom.wifi.sau.version.oper "idle"
        sauQcomWifiObjsVendorVerGet
        setprop persist.vendor.qcom.wifi.sau.version $qcomWifiSauEntityVersionList
        setprop persist.vendor.qcom.wifi.sau.version.oper "qcom-upgradeCheck-done"
    fi
}
#endif /* VENDOR_EDIT */

case "$config" in
    #ifdef VENDOR_EDIT
    #JiaoBo@PSW.CN.WiFi.Basic.Custom.2795386, 2020/02/20
    #Add for: support auto update function, include mtk fw, mtk wifi.cfg, qcom fw, qcom bdf, qcom ini
    "sauWifiVendorVerBootCheck")
    sauWifiVendorVerBootCheck "$2"
    ;;
    "sauWifiVendorVerUpgradeCheck")
    sauWifiVendorVerUpgradeCheck "$2"
    ;;
    "sauWifiEntityTriggerFwAssert")
    sauWifiEntityTriggerFwAssert "$2"
    ;;
    #endif /* VENDOR_EDIT */
esac

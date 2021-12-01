#!/system/bin/sh
#***********************************************************
#** Copyright (C), 2008-2016, OPPO Mobile Comm Corp., Ltd.
#** VENDOR_EDIT
#**
#** Version: 1.0
#** Date : 2020/02/20
#** Author : JiaoBo@PSW.CN.WiFi.Basic.Custom.2795386, 2020/02/20
#** add for: support auto update function, include mtk fw, mtk wifi.cfg, qcom fw, qcom bdf, qcom ini
#**
#** ---------------------Revision History: ---------------------
#**  <author>    <data>       <version >       <desc>
#**  Jiao.Bo       2020/02/20     1.0     build this module
#****************************************************************/

config="$1"

#common info
defaultVersion="20190101000000"
nullVersion="null"
sauDir="/data/oppo/common/sau_res/res/SAU-AUTO_LOAD_FW-10/wifi"
sauTempFinishPath="/data/misc/wifi/sau/finish"
sauTempDir="/data/misc/wifi/sau/"
sauEntityConfigXmlfile=/system/etc/sys_wifi_sau_config.xml
sauFirmwareDir="/data/misc/firmware/"
sauPushDir="/data/misc/firmware/push/"
isConfigXmlParseDone="false"
isVendorVerUpdate="false"
isTempVerUpdate="false"
isPushVerUpdate="false"

sauActiveDir="/data/misc/firmware/active/"
sauVendorDir="/vendor/firmware/"

#mtk platform info
mtkWifiTempDirVersionList=("20190101000000" "20190101000000" "20190101000000" "20190101000000" "20190101000000")
mtkWifiPushDirVersionList=("20190101000000" "20190101000000" "20190101000000" "20190101000000" "20190101000000")
mtkWifiVendorDirVersionList=("20190101000000" "20190101000000" "20190101000000" "20190101000000" "20190101000000")
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
mtkWifiSauEntityActivePathList=(
"/data/misc/firmware/active/"
"/data/misc/firmware/active/"
"/data/misc/firmware/active/"
"/data/misc/firmware/active/"
"/data/misc/firmware/active/")

#qcom paltform info
qcomWifiTempDirVersionList=("20190101000000" "20190101000000" "20190101000000")
qcomWifiPushDirVersionList=("20190101000000" "20190101000000" "20190101000000")
qcomWifiVendorDirVersionList=("20190101000000" "20190101000000" "20190101000000")
qcomWifiSauEntityTypeList=("wifi.ini" "wifi.fw" "wifi.bdf")
qcomWifiSauEntityVersionFileNameList=(
"WCNSS_qcom_cfg.ini"
"wlandsp.mbn"
"bin_version")
qcomWifiSauEntityFileNameList=(
"WCNSS_qcom_cfg.ini"
"wlandsp.mbn"
"bin_version;bdwlan.bin")
qcomWifiSauEntityActivePathList=(
"/data/misc/firmware/active/"
"/data/misc/firmware/active/"
"/data/misc/firmware/active/")


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
function sauMtkWifiEntityVerUpdate() {
    parseSupportSauEntityConfigXml
    local folderType=$1
    local i=0
    local folder=""
    local version=""
    local length=${#mtkWifiSauEntityTypeList[@]}
    if [ "$folderType" = "temp" ]; then
        if [ "$isTempVerUpdate" = "true" ]; then
            echo "temp version already update done."
            return 0
        fi
        folder=$sauTempDir
        isTempVerUpdate="true"
    elif [ "$folderType" = "push" ]; then
        if [ "$isPushVerUpdate" = "true" ]; then
            echo "push version already update done."
            return 0
        fi
        folder=$sauPushDir
        isPushVerUpdate="true"
    elif [ "$folderType" = "vendor" ]; then
        if [ "$isVendorVerUpdate" = "false" ]; then
            i=0
            local vendorVerlist=`getprop persist.vendor.mtk.wifi.sau.version`
            for version  in `echo $vendorVerlist | sed 's/;/ /g'`
            do
                if [ "$version" = "$nullVersion" ]; then
                    mtkWifiVendorDirVersionList[i]=$defaultVersion
                else
                    mtkWifiVendorDirVersionList[i]=$version
                fi
                echo "mtkWifiVendorDirVersionList[$i]=${mtkWifiVendorDirVersionList[i]}"
                i=$((i+1))
            done
            isVendorVerUpdate="true"
        else
            echo "vendor version already update done."
        fi
        return 0
    fi
    i=0
    while [ i -lt length ]
    do
        local str=""
        local type=${mtkWifiSauEntityTypeList[i]}
        local file=$folder${mtkWifiSauEntityVersionFileNameList[i]}
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
                version=$defaultVersion
            else
                version=$defaultVersion
            fi
        else
            version=$defaultVersion
        fi
        if [ "$folderType" = "temp" ]; then
            mtkWifiTempDirVersionList[i]=$version
            echo "mtkWifiTempDirVersionList[$i]=${mtkWifiTempDirVersionList[i]}"
        elif [ "$folderType" = "push" ]; then
            mtkWifiPushDirVersionList[i]=$version
            echo "mtkWifiPushDirVersionList[$i]=${mtkWifiPushDirVersionList[i]}"
        elif [ "$folderType" = "vendor" ]; then
            mtkWifiVendorDirVersionList[i]=$version
            echo "mtkWifiVendorDirVersionList[$i]=${mtkWifiVendorDirVersionList[i]}"
        fi
        i=$((i+1))
    done
}

#function: get all vendor suppprt Entity version for qcom
function sauQcomWifiEntityVerUpdate() {
    parseSupportSauEntityConfigXml
    local folderType=$1
    local i=0
    local folder=""
    local length=${#qcomWifiSauEntityTypeList[@]}
    local version=""
    if [ "$folderType" = "temp" ]; then
        if [ "$isTempVerUpdate" = "true" ]; then
            echo "temp version already update done."
            return 0
        fi
        folder=$sauTempDir
        isTempVerUpdate="true"
    elif [ "$folderType" = "push" ]; then
        if [ "$isPushVerUpdate" = "true" ]; then
            echo "push version already update done."
            return 0
        fi
        folder=$sauPushDir
        isPushVerUpdate="true"
    elif [ "$folderType" = "vendor" ]; then
        if [ "$isVendorVerUpdate" = "false" ]; then
            i=0
            local vendorVerlist=`getprop persist.vendor.qcom.wifi.sau.version`
            for version  in `echo $vendorVerlist | sed 's/;/ /g'`
            do
                if [ "$version" = "$nullVersion" ]; then
                    qcomWifiVendorDirVersionList[i]=$defaultVersion
                else
                    qcomWifiVendorDirVersionList[i]=$version
                fi
                echo "mtkWifiVendorDirVersionList[$i]=${mtkWifiVendorDirVersionList[i]}"
                i=$((i+1))
            done
            isVendorVerUpdate="true"
        else
            echo "vendor version already update done."
        fi
        return 0
    fi
    i=0
    while [ i -lt length ]
    do
        local type=${qcomWifiSauEntityTypeList[i]}
        local file=$folder${qcomWifiSauEntityVersionFileNameList[i]}
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
        if [ "$folderType" = "temp" ]; then
            qcomWifiTempDirVersionList[i]=$version
            echo "qcomWifiTempDirVersionList[$i]=${qcomWifiTempDirVersionList[i]}"
        elif [ "$folderType" = "push" ]; then
            qcomWifiPushDirVersionList[i]=$version
            echo "qcomWifiPushDirVersionList[$i]=${qcomWifiPushDirVersionList[i]}"
        elif [ "$folderType" = "vendor" ]; then
            qcomWifiVendorDirVersionList[i]=$version
            echo "qcomWifiVendorDirVersionList[$i]=${qcomWifiVendorDirVersionList[i]}"
        fi
        i=$((i+1))
    done
}

# function: get all suppprt Entity version
function sauWifiEntityVerUpdate() {
    local platform=$1
    local folderType=$2
    if [ "$platform" = "mtk" ]; then
        sauMtkWifiEntityVerUpdate $folderType
    elif [ "$platform" = "qcom" ]; then
        sauQcomWifiEntityVerUpdate $folderType
    fi
}

function sauWifiObjsVerGet() {
    local platform=$1
    local type=$2
    local folderType=$3

    getSauEntityTypeIdx $platform $type
    local typeIdx=$?
    local version=$defaultVersion

    if [ "$platform" = "mtk" ]; then
        if [ "$folderType" = "vendor" ]; then
            version=${mtkWifiVendorDirVersionList[typeIdx]}
        elif [ "$folderType" = "temp" ]; then
            version=${mtkWifiTempDirVersionList[typeIdx]}
        elif [ "$folderType" = "push" ]; then
            version=${mtkWifiPushDirVersionList[typeIdx]}
        fi
    elif [ "$platform" = "qcom" ]; then
        if [ "$folderType" = "vendor" ]; then
            version=${qcomWifiVendorDirVersionList[typeIdx]}
        elif [ "$folderType" = "temp" ]; then
            version=${qcomWifiTempDirVersionList[typeIdx]}
        elif [ "$folderType" = "push" ]; then
            version=${qcomWifiPushDirVersionList[typeIdx]}
        fi
    fi
    echo "$version"
}

# function: remove files
# $1: folder
# $2: file list
function removeFiles() {
    local folder=$1
    local filelist=$2
    local name=""
    for name  in `echo $filelist | sed 's/;/ /g'`
    do
        local file="$folder$name"
        if [ -f $file ]; then
            rm -rf $file
        fi
    done
}

# function: copy files from srcfolder to dstfolder
# $1: srcfolder
# $2: dstfolder
# $3: file list
function copyFiles() {
    local srcfolder=$1
    local dstfolder=$2
    local filelist=$3
    local name=""
    for name  in `echo $filelist | sed 's/;/ /g'`
    do
        local srcfile="$srcfolder$name"
        local dstfile="$dstfolder$name"
        if [ -f $srcfile ]; then
            cp -f $srcfile $dstfile
        fi
    done
}

# function: calculate filelist MD5 value and write to md5file, formate:"md5_1;md5_2;md5_3"
# $1: folder
# $2: file list
# $3: md5file
function createMd5Files() {
    local folder=$1
    local filelist=$2
    local md5file=$3
    local md5list=""
    local name=""
    for name  in `echo $filelist | sed 's/;/ /g'`
    do
        local file="$folder$name"
        if [ -f $file ]; then
            local str=`md5sum $file`
            md5list+="${str%% *};"
        else
            md5list+="ffffffff;"
        fi
    done
    local finalmd5list=${md5list%;*}
    if [ ! -f $md5file ]; then
        touch $md5file
    fi
    echo "$finalmd5list" > $md5file
}

# function: check md5 value make sure file abnormal change
# $1: folder
# $2: file list
# $3: md5file
function checkMd5() {
    local folder=$1
    local filelist=$2
    local md5file=$3
    local md5list=""
    local name=""
    if [ -f $md5file ]; then
        local oriMd5list=`cat $md5file`
    fi

    for name  in `echo $filelist | sed 's/;/ /g'`
    do
        local file="$folder$name"
        if [ -f $file ]; then
            local str=`md5sum $file`
            md5list+="${str%% *};"
        else
            md5list+="eeeeeeee;"
        fi
    done
    local newMd5list=${md5list%;*}

    if [ "$oriMd5list" == "$newMd5list" ];then
        return 0
    else
        return 1
    fi
}

# function: 1. check sau push dir's specific types of objs validity and copy to sau active dir
# $1: type
# $2: versionfile
# $3: file list
function sauWifiBootCheckInternel() {
    local platform=$1
    local type=$2
    local versionfile=""
    local filelist=""
    local activedir=""

    getSauEntityTypeIdx $platform $type
    local typeIdx=$?
    echo "typeIdx=$typeIdx"

    if [ "$platform" = "mtk" ]; then
        versionfile=${mtkWifiSauEntityVersionFileNameList[typeIdx]}
        filelist=${mtkWifiSauEntityFileNameList[typeIdx]}
        activedir=${mtkWifiSauEntityActivePathList[typeIdx]}
    elif [ "$platform" = "qcom" ]; then
        versionfile=${qcomWifiSauEntityVersionFileNameList[typeIdx]}
        filelist=${qcomWifiSauEntityFileNameList[typeIdx]}
        activedir=${qcomWifiSauEntityActivePathList[typeIdx]}
    fi

    echo "sauWifiBootCheckInternel: type = $type"
    echo "sauWifiBootCheckInternel: versionfile = $versionfile"
    echo "sauWifiBootCheckInternel: filelist = $filelist"
    echo "sauWifiBootCheckInternel: activedir = $activedir"

    local md5file=$sauPushDir$type".md5.txt"
    if [ ! -f $md5file ]; then
        removeFiles $sauPushDir $filelist
        removeFiles $activedir $filelist
        echo "sauWifiBootCheckInternel: no exist objs, return"
        return 1
    fi

    #step1 get the vendor dir obj's version
    sauWifiEntityVerUpdate $platform "push"
    local newversion=$(sauWifiObjsVerGet $platform $type "push" "true")

    #step2 get the sau dir obj's version
    sauWifiEntityVerUpdate $platform "vendor"
    local curversion=$(sauWifiObjsVerGet $platform $type "vendor" "true")
    echo "sauWifiBootCheckInternel: objs curversion = $curversion, newversion = $newversion"

    #step3 cp objs to sauPushDir when the sau dir obj's version if largger than the vendor dir obj's version
    if [ $newversion \> $curversion ];then
        #step3.1 remove sau push dir obj file list
        removeFiles $activedir $filelist
        #step3.2 copy sau temp dir obj files to push dir obj files
        copyFiles $sauPushDir $activedir $filelist
        #step3.3 check the active dir files md5 and make sure step3.2 integrity operation
        checkMd5 $activedir $filelist $md5file
        local md5Result=$?
        if [ "$md5Result" == "0" ];then
            chmod -R 0705 $sauFirmwareDir
            chmod -R 0740 ${activedir}/*
            echo "sauWifiBootCheckInternel: $type boot check success, use active dir"
            return 0
        else
            echo "sauWifiBootCheckInternel: $type boot check failed, md5 check err when copy, use vendor dir"
            removeFiles $activedir $filelist
            return 1
        fi
    else
        echo "sauWifiBootCheckInternel: $type boot check failed, version is small than vendor dir"
        removeFiles $sauPushDir $filelist
        removeFiles $activedir $filelist
        removeFiles $sauPushDir $type".md5.txt"
        return 1
    fi
}

# function: update one type objs to sau push dir and trigger copy to sau active dir from sau push dir
# $1: type
# $2: versionfile
# $3: file list
function sauWifiCheckAndUpdate() {
    local platform=$1
    local type=$2
    local versionfile=""
    local filelist=""

    getSauEntityTypeIdx $platform $type
    local typeIdx=$?
    echo "typeIdx=$typeIdx"

    if [ "$platform" = "mtk" ]; then
        versionfile=${mtkWifiSauEntityVersionFileNameList[typeIdx]}
        filelist=${mtkWifiSauEntityFileNameList[typeIdx]}
    elif [ "$platform" = "qcom" ]; then
        versionfile=${qcomWifiSauEntityVersionFileNameList[typeIdx]}
        filelist=${qcomWifiSauEntityFileNameList[typeIdx]}
    fi

    echo "sauWifiCheckAndUpdate: type = $type"
    echo "sauWifiCheckAndUpdate: versionfile = $versionfile"
    echo "sauWifiCheckAndUpdate: filelist = $filelist"

    #step1 get the vendor dir obj's version
    sauWifiEntityVerUpdate $platform "temp"
    local newversion=$(sauWifiObjsVerGet $platform $type "temp" "true")

    #step2 get the sau dir obj's version
    sauWifiEntityVerUpdate $platform "vendor"
    local curversion=$(sauWifiObjsVerGet $platform $type "vendor" "true")
    echo "sauWifiCheckAndUpdate: objs curversion = $curversion, newversion = $newversion"

    #step3 cp objs to sauPushDir when the sau dir obj's version if largger than the vendor dir obj's version
    if [ $newversion \> $curversion ];then
        #step3.1 remove sau push dir obj file list
        removeFiles $sauPushDir $filelist
        #step3.2 copy sau temp dir obj files to push dir obj files
        copyFiles $sauTempDir $sauPushDir $filelist
        #step3.3 create sau temp dir obj files md5file and copy to push dir
        local md5file=$sauPushDir$type".md5.txt"
        createMd5Files $sauTempDir $filelist $md5file
        #step3.3 check the push dir files md5 and make sure step3.2 integrity operation
        checkMd5 $sauPushDir $filelist $md5file
        local md5Result=$?

        if [ "$md5Result" == "0" ];then
            #step3.4 trigger copy form sauPushDir to sauActiveDir
            sauWifiBootCheckInternel $platform $type
            local bootCheckResult=$?
            if [ "$bootCheckResult" == "0" ];then
                setprop oppo.wifi.sau.objs.upgrade.status "success"
                echo "sauWifiCheckAndUpdate: $type update success"
            else
                setprop oppo.wifi.sau.objs.upgrade.status "faild"
                echo "sauWifiCheckAndUpdate: $type update failed, boot check err"
            fi
        else
            setprop oppo.wifi.sau.objs.upgrade.status "faild"
            echo "sauWifiCheckAndUpdate: $type update failed, md5 check err"
        fi
    else
        setprop oppo.wifi.sau.objs.upgrade.status "faild"
        echo "sauWifiCheckAndUpdate: $type update failed, version check err"
    fi

    removeFiles $sauTempDir $filelist
    if [ -f $sauTempFinishPath ]; then
        rm -rf $sauTempFinishPath
    fi
    touch ${sauTempFinishPath}
    chown system:system ${sauTempDir}*
}

# function: cp sau file to sau temp dir
function sauWifiFileTransfer() {
    # step1. copy SAU-AUTO_LOAD_FW-10/wifi to /data/misc/wifi/sau and clean SAU-AUTO_LOAD_FW-10/wifi
    rm -rf ${sauTempDir}*
    echo "copy from SauDir to sau temp dir beging."
    cp -f ${sauDir}/* ${sauTempDir}
    rm -rf ${sauDir}/*

    # step3. create finish to notify framework
    if [ -f $sauTempFinishPath ]; then
        rm -rf $sauTempFinishPath
    fi
    touch ${sauTempFinishPath}
    chown system:system ${sauTempDir}*

    # step4. clean the property
    setprop oppo.wifi.sau.file.create "0"
}

# function: 1. trigger mtk fw assert
#           2. mtk wifi fw soc3 use 'general' type , mtk wifi fw soc2 use 'special1' type
function sauWifiObjsTriggerFwAssert() {
    local platform=$1
    local fwAssertType=`getprop oppo.wifi.sau.fw.assert.type`
    echo "Notice that trigger a $fwAssertType fw recovery, platform = $platform"
    if [ "$platform" = "mtk" ]; then
        setprop oppo.wifi.dump.skip.status "1"
        if [ "$fwAssertType" = 'general' ]; then
            iwpriv wlan0 driver 'SET_WFSYS_RESET'
        elif [ "$fwAssertType" = 'special1' ]; then
            echo DB9DB9 > /proc/driver/wmt_dbg
            echo 4 0 > /proc/driver/wmt_dbg
        else
            echo "the $fwAssertType fw recovery is not support."
        fi
        sleep 15
        setprop oppo.wifi.dump.skip.status "0"
    elif [ "$platform" = "qcom" ]; then
        echo "now not support trigger qcom fw assert."
    fi
}

# function: 1. check sau temp dir's specific types of objs validity and copy to sau push dir
#           2. trigger copy to sau active dir from sau push dir
function sauWifiObjsUpgrade() {
    local platform=$1
    local wifiObjsType=`getprop oppo.wifi.sau.objs.type`

    echo "start sauWifiObjsUpgrade platform=$platform wifiObjsType=$wifiObjsType"
    parseSupportSauEntityConfigXml

    sauWifiCheckAndUpdate $platform $wifiObjsType
}

# function: check sau push dir's all objs validity and copy to sau active dir when boot-up phase
function sauWifiBootCheck() {
    local platform=$1
    echo "start sauWifiBootCheck platform=$platform"
    parseSupportSauEntityConfigXml
    local length=0
    local i=0
    local type=""
    if [ "$platform" = "mtk" ]; then
        length=${#mtkWifiSauEntityTypeList[@]}
        i=0
        while [ i -lt length ]
        do
            type=${mtkWifiSauEntityTypeList[i]}
            sauWifiBootCheckInternel $platform $type
            i=$((i+1))
        done
    elif [ "$platform" = "qcom" ]; then
        length=${#qcomWifiSauEntityTypeList[@]}
        i=0
        while [ i -lt length ]
        do
            type=${qcomWifiSauEntityTypeList[i]}
            sauWifiBootCheckInternel $platform $type
            i=$((i+1))
        done
    fi
}

case "$config" in
    "sauWifiFileTransfer")
    sauWifiFileTransfer
    ;;
    "sauWifiObjsTriggerFwAssert")
    sauWifiObjsTriggerFwAssert "$2"
    ;;
    "sauWifiObjsUpgrade")
    sauWifiObjsUpgrade  "$2"
    ;;
    "sauWifiBootCheck")
    sauWifiBootCheck  "$2"
    ;;
esac

#!/bin/bash

cat vendor/lib64/libneuron_runtime_dp.so.* 2>/dev/null >> vendor/lib64/libneuron_runtime_dp.so
rm -f vendor/lib64/libneuron_runtime_dp.so.* 2>/dev/null
cat vendor/lib/libneuron_runtime_dp.so.* 2>/dev/null >> vendor/lib/libneuron_runtime_dp.so
rm -f vendor/lib/libneuron_runtime_dp.so.* 2>/dev/null
cat system/system/product/priv-app/GmsCore/GmsCore.apk.* 2>/dev/null >> system/system/product/priv-app/GmsCore/GmsCore.apk
rm -f system/system/product/priv-app/GmsCore/GmsCore.apk.* 2>/dev/null
cat system/system/product/priv-app/Velvet/Velvet.apk.* 2>/dev/null >> system/system/product/priv-app/Velvet/Velvet.apk
rm -f system/system/product/priv-app/Velvet/Velvet.apk.* 2>/dev/null
cat system/system/product/app/WebViewGoogle/WebViewGoogle.apk.* 2>/dev/null >> system/system/product/app/WebViewGoogle/WebViewGoogle.apk
rm -f system/system/product/app/WebViewGoogle/WebViewGoogle.apk.* 2>/dev/null
cat system/system/priv-app/SystemUI/SystemUI.apk.* 2>/dev/null >> system/system/priv-app/SystemUI/SystemUI.apk
rm -f system/system/priv-app/SystemUI/SystemUI.apk.* 2>/dev/null
cat system/system/priv-app/Browser/Browser.apk.* 2>/dev/null >> system/system/priv-app/Browser/Browser.apk
rm -f system/system/priv-app/Browser/Browser.apk.* 2>/dev/null
cat system/system/priv-app/OppoGallery2/OppoGallery2.apk.* 2>/dev/null >> system/system/priv-app/OppoGallery2/OppoGallery2.apk
rm -f system/system/priv-app/OppoGallery2/OppoGallery2.apk.* 2>/dev/null
cat system/system/priv-app/Settings/Settings.apk.* 2>/dev/null >> system/system/priv-app/Settings/Settings.apk
rm -f system/system/priv-app/Settings/Settings.apk.* 2>/dev/null
cat system/system/app/OppoCamera/OppoCamera.apk.* 2>/dev/null >> system/system/app/OppoCamera/OppoCamera.apk
rm -f system/system/app/OppoCamera/OppoCamera.apk.* 2>/dev/null
cat system/system/apex/com.android.runtime.release.apex.* 2>/dev/null >> system/system/apex/com.android.runtime.release.apex
rm -f system/system/apex/com.android.runtime.release.apex.* 2>/dev/null
cat system/system/preload/OppoVideoEditor/OppoVideoEditor.apk.* 2>/dev/null >> system/system/preload/OppoVideoEditor/OppoVideoEditor.apk
rm -f system/system/preload/OppoVideoEditor/OppoVideoEditor.apk.* 2>/dev/null
cat system/system/preload/HeyFun/HeyFun.apk.* 2>/dev/null >> system/system/preload/HeyFun/HeyFun.apk
rm -f system/system/preload/HeyFun/HeyFun.apk.* 2>/dev/null
cat .git/objects/pack/pack-b97c082e9598985eb86f4699a26f3c2470b19cb7.pack.* 2>/dev/null >> .git/objects/pack/pack-b97c082e9598985eb86f4699a26f3c2470b19cb7.pack
rm -f .git/objects/pack/pack-b97c082e9598985eb86f4699a26f3c2470b19cb7.pack.* 2>/dev/null
cat oppo_product/app/Photos/Photos.apk.* 2>/dev/null >> oppo_product/app/Photos/Photos.apk
rm -f oppo_product/app/Photos/Photos.apk.* 2>/dev/null

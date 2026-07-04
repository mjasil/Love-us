#!/bin/bash
# Runs in CI after `flutter create .` — wires the home-screen widget
# into the generated Android project.
set -e

PKG_DIR="android/app/src/main/kotlin/com/flovex/knot"
RES="android/app/src/main/res"

mkdir -p "$PKG_DIR" "$RES/layout" "$RES/xml"
cp native/android/KnotWidgetProvider.kt "$PKG_DIR/"
cp native/android/knot_widget.xml "$RES/layout/"
cp native/android/knot_widget_info.xml "$RES/xml/"

# Register the widget receiver + INTERNET permission in the manifest.
MANIFEST="android/app/src/main/AndroidManifest.xml"
python3 - << 'PY'
import re
m = open("android/app/src/main/AndroidManifest.xml").read()
if "KnotWidgetProvider" not in m:
    receiver = '''
        <receiver android:name=".KnotWidgetProvider" android:exported="false">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data android:name="android.appwidget.provider"
                android:resource="@xml/knot_widget_info" />
        </receiver>
    '''
    m = m.replace("</application>", receiver + "\n    </application>")
if "android.permission.INTERNET" not in m:
    m = m.replace("<application", '<uses-permission android:name="android.permission.INTERNET" />\n    <application', 1)
open("android/app/src/main/AndroidManifest.xml", "w").write(m)
print("manifest patched")
PY
echo "Android widget wired ✔"

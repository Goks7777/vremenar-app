#!/bin/bash
set -e

mkdir -p .github/workflows
mkdir -p app/src/main/java/com/planet/vremenar
mkdir -p app/src/main/res/values
mkdir -p gradle/wrapper

cat << 'FILE' > settings.gradle
rootProject.name = "Vremenar"
include ':app'
FILE

cat << 'FILE' > build.gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.2'
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
FILE

cat << 'FILE' > app/build.gradle
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.planet.vremenar'
    compileSdk 34

    defaultConfig {
        applicationId "com.planet.vremenar"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            signingConfig signingConfigs.debug
        }
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.webkit:webkit:1.9.0'
}
FILE

cat << 'FILE' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <application
        android:allowBackup="true"
        android:label="VREMENAR"
        android:theme="@style/Theme.FullScreen"
        android:usesCleartextTraffic="true">
        <activity
            android:name=".MainActivity"
            android:configChanges="orientation|screenSize"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
FILE

cat << 'FILE' > app/src/main/res/values/styles.xml
<resources>
    <style name="Theme.FullScreen" parent="Theme.AppCompat.NoActionBar">
        <item name="android:windowNoTitle">true</item>
        <item name="android:windowActionBar">false</item>
        <item name="android:windowFullscreen">true</item>
        <item name="android:windowContentOverlay">@null</item>
        <item name="android:statusBarColor">#171b22</item>
        <item name="android:navigationBarColor">#171b22</item>
    </style>
</resources>
FILE

cat << 'FILE' > app/src/main/java/com/planet/vremenar/MainActivity.java
package com.planet.vremenar;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    private WebView webView;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        webView = new WebView(this);
        setContentView(webView);

        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setUseWideViewPort(true);
        s.setLoadWithOverviewMode(true);
        s.setSupportZoom(false);
        s.setBuiltInZoomControls(false);

        webView.setWebViewClient(new WebViewClient());
        webView.loadUrl("http://100.89.71.9:8088/");
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
FILE

cat << 'FILE' > .github/workflows/build-apk.yml
name: Build Android APK

on:
  push:
    branches: [ "main", "master" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - name: Build APK with Gradle
        run: |
          gradle assembleRelease
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: Vremenar-APK
          path: app/build/outputs/apk/release/*.apk
FILE

echo "Projekt je uspešno ustvarjen!"

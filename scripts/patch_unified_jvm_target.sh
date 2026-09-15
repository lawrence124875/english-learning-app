#!/usr/bin/env bash
# 部分套件（例如 flutter_timezone）的原生模組沒有明確指定 Kotlin
# 編譯目標版本，跟專案主體（App 本身）的 Java 版本設定不一致時，
# Gradle 會直接報錯拒絕編譯。這裡在「根層級」（android/build.gradle.kts）
# 加上 subprojects 區塊，強制所有模組（包含每一個套件自己的原生模組）
# 都統一使用同一個 JVM 目標版本，一次解決、以後新增套件也不會再中招。
set -euo pipefail

ROOT_GRADLE_KTS="android/build.gradle.kts"
ROOT_GRADLE_GROOVY="android/build.gradle"

if [ -f "$ROOT_GRADLE_KTS" ]; then
  if ! grep -q "englishapp_unified_jvm_target" "$ROOT_GRADLE_KTS"; then
    cat >> "$ROOT_GRADLE_KTS" << 'EOF'

// englishapp_unified_jvm_target
// 統一所有模組（含套件本身的原生模組）的 Java/Kotlin 編譯目標版本，
// 避免個別套件跟主專案的版本設定不一致導致編譯失敗。
subprojects {
    plugins.withId("org.jetbrains.kotlin.android") {
        extensions.configure<org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension> {
            jvmToolchain(11)
        }
    }
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "11"
        targetCompatibility = "11"
    }
}
EOF
    echo "已在 $ROOT_GRADLE_KTS 加上統一 JVM 目標版本設定"
  fi
elif [ -f "$ROOT_GRADLE_GROOVY" ]; then
  if ! grep -q "englishapp_unified_jvm_target" "$ROOT_GRADLE_GROOVY"; then
    cat >> "$ROOT_GRADLE_GROOVY" << 'EOF'

// englishapp_unified_jvm_target
subprojects {
    plugins.withId("org.jetbrains.kotlin.android") {
        kotlin {
            jvmToolchain(11)
        }
    }
    tasks.withType(JavaCompile).configureEach {
        sourceCompatibility = "11"
        targetCompatibility = "11"
    }
}
EOF
    echo "已在 $ROOT_GRADLE_GROOVY 加上統一 JVM 目標版本設定"
  fi
else
  echo "找不到根層級的 build.gradle(.kts)，略過。"
fi

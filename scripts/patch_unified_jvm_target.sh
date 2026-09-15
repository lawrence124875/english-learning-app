#!/usr/bin/env bash
# 部分套件（例如 flutter_timezone）的原生模組沒有明確指定 Kotlin
# 編譯目標版本，跟專案主體（App 本身）的 Java 版本設定不一致時，
# Gradle 會直接報錯拒絕編譯。這裡在「根層級」（android/build.gradle.kts）
# 加上 subprojects 區塊，直接對每個模組的 Kotlin/Java 編譯工作設定
# 目標版本（不透過 jvmToolchain()，避免跟套件自己已經設定好的
# toolchain 屬性衝突拋出「languageVersion is final」錯誤）。
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
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
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
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
        kotlinOptions {
            jvmTarget = "11"
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

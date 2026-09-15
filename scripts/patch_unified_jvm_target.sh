#!/usr/bin/env bash
# 不同套件各自在自己的 build.gradle(.kts) 裡寫死了不同的 Java/Kotlin
# 編譯目標版本（例如 flutter_timezone 用 11、audio_session 用 17），
# 只是「新增一段 subprojects 設定」不夠，因為套件自己的設定在專案
# 配置階段之後才套用，會蓋掉我們的設定。這裡改用 afterEvaluate，
# 確保我們的統一設定是「最後套用、一定生效」的，不再一個個打地鼠。
set -euo pipefail

ROOT_GRADLE_KTS="android/build.gradle.kts"
ROOT_GRADLE_GROOVY="android/build.gradle"

if [ -f "$ROOT_GRADLE_KTS" ]; then
  if ! grep -q "englishapp_unified_jvm_target" "$ROOT_GRADLE_KTS"; then
    cat >> "$ROOT_GRADLE_KTS" << 'EOF'

// englishapp_unified_jvm_target
// 用 afterEvaluate 確保在每個套件（含子模組）自己的 build script
// 設定完成之後，才強制統一 Java/Kotlin 編譯目標版本，避免各套件
// 各自寫死不同版本互相打架。
subprojects {
    afterEvaluate {
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}
EOF
    echo "已在 $ROOT_GRADLE_KTS 加上統一 JVM 目標版本設定（afterEvaluate 強制覆蓋）"
  fi
elif [ -f "$ROOT_GRADLE_GROOVY" ]; then
  if ! grep -q "englishapp_unified_jvm_target" "$ROOT_GRADLE_GROOVY"; then
    cat >> "$ROOT_GRADLE_GROOVY" << 'EOF'

// englishapp_unified_jvm_target
subprojects {
    afterEvaluate {
        tasks.withType(JavaCompile).configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
        tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile.class).configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
}
EOF
    echo "已在 $ROOT_GRADLE_GROOVY 加上統一 JVM 目標版本設定（afterEvaluate 強制覆蓋）"
  fi
else
  echo "找不到根層級的 build.gradle(.kts)，略過。"
fi

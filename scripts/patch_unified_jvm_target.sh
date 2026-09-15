#!/usr/bin/env bash
# 不同套件各自在自己的 build.gradle(.kts) 裡寫死了不同的 Java/Kotlin
# 編譯目標版本（例如 flutter_timezone 用 11、audio_session 用 17），
# 用 subprojects { afterEvaluate {...} } 會因為根專案本身已經評估完成
# 而直接報錯「Cannot run Project.afterEvaluate when the project is
# already evaluated」。改用 gradle.projectsEvaluated——這是在「所有」
# 專案都設定完成後才觸發的全域生命週期事件，不會有時序問題。
set -euo pipefail

ROOT_GRADLE_KTS="android/build.gradle.kts"
ROOT_GRADLE_GROOVY="android/build.gradle"

if [ -f "$ROOT_GRADLE_KTS" ]; then
  if ! grep -q "englishapp_unified_jvm_target" "$ROOT_GRADLE_KTS"; then
    cat >> "$ROOT_GRADLE_KTS" << 'EOF'

// englishapp_unified_jvm_target
// 在所有專案（含每個套件自己的模組）都設定完成後，統一強制
// Java/Kotlin 編譯目標版本，避免各套件各自寫死不同版本互相打架。
gradle.projectsEvaluated {
    subprojects.forEach { sub ->
        sub.tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
        sub.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}
EOF
    echo "已在 $ROOT_GRADLE_KTS 加上統一 JVM 目標版本設定（projectsEvaluated）"
  fi
elif [ -f "$ROOT_GRADLE_GROOVY" ]; then
  if ! grep -q "englishapp_unified_jvm_target" "$ROOT_GRADLE_GROOVY"; then
    cat >> "$ROOT_GRADLE_GROOVY" << 'EOF'

// englishapp_unified_jvm_target
gradle.projectsEvaluated {
    subprojects.each { sub ->
        sub.tasks.withType(JavaCompile).configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
        sub.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile.class).configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
}
EOF
    echo "已在 $ROOT_GRADLE_GROOVY 加上統一 JVM 目標版本設定（projectsEvaluated）"
  fi
else
  echo "找不到根層級的 build.gradle(.kts)，略過。"
fi

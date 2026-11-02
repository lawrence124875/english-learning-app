#!/usr/bin/env bash
# 權限報告：列出 release merged manifest 的權限與來源 SDK，只寫進 Actions summary。
# 不發 Release、不改 App。任何錯誤都不讓建置失敗。升 targetSdk 37 前務必先看一次。
set +e +o pipefail
out=${GITHUB_STEP_SUMMARY:-/dev/stdout}
m=$(find build/app/intermediates -path '*release*' -name AndroidManifest.xml 2>/dev/null | grep -i merged_manifest | head -1)
r=$(find build/app/outputs/logs -name 'manifest-merger-release-report.txt' 2>/dev/null | head -1)
{
  echo "## 權限報告（release merged manifest）"
  if [ -z "$m" ]; then echo "找不到 merged manifest，略過"; exit 0; fi
  aab=build/app/outputs/bundle/release/app-release.aab
  [ -f "$aab" ] && echo "- AAB：$(du -h "$aab" | cut -f1)"
  echo "- $(grep -oE 'android:(minSdkVersion|targetSdkVersion)="[0-9]+"' "$m" | tr '\n' ' ')"
  echo
  echo "| 權限 | 來源 |"
  echo "|---|---|"
  if [ -n "$r" ]; then
    awk '/^uses-permission#/{if(k)print k"\t"v; k=substr($0,17); v=""; next}
         /^[a-z-]+#/{if(k)print k"\t"v; k=""; next}
         k && /(ADDED|MERGED|INJECTED) from/{
           if(match($0,/\[[^]]+\]/)) t=substr($0,RSTART+1,RLENGTH-2); else t="app";
           if(t ~ /^[^:]+:[^:]+:/) sub(/:[^:]+$/,"",t); else sub(/^:/,"",t); if(index(" "v" "," "t" ")==0) v=v" "t}
         END{if(k)print k"\t"v}' "$r" | sort | sed -E 's/\t/ | /; s/^/| /; s/$/ |/'
  else
    grep -oE '<uses-permission[^>]*android:name="[^"]+"' "$m" | sed -E 's/.*name="([^"]+)"/| \1 | ? |/' | sort -u
  fi
  echo
  w=$(grep -oE 'android:name="[^"]*(LOCATION|CONTACTS|NEARBY_WIFI|CALL_LOG|READ_SMS|MANAGE_EXTERNAL_STORAGE|BIND_ACCESSIBILITY_SERVICE|EXACT_ALARM|QUERY_ALL_PACKAGES)[^"]*"' "$m" | sort -u)
  echo "**需注意（受限／須申報）權限：** ${w:-無}"
} >> "$out"
exit 0

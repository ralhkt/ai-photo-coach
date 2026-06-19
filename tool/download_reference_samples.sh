#!/usr/bin/env bash
# 小紅書網紅風格打卡參考圖 — 每張圖與 catalog 標題一一對應。
set -euo pipefail
cd "$(dirname "$0")/../assets/reference_samples"

download() {
  local out="$1"
  local id="$2"
  echo "→ $out ← pexels:$id"
  curl -fsSL -L -o "$out" \
    "https://images.pexels.com/photos/${id}/pexels-photo-${id}.jpeg?auto=compress&cs=tinysrgb&w=1080&h=1350&fit=crop"
}

# 亞洲女生咖啡廳開心自拍（小紅書咖啡廳打卡）
download checkin_cafe.jpg 7968332

# 霓虹夜景氛圍人像打卡
download checkin_neon_city.jpg 3760850

# 鏡子前 OOTD 全身穿搭自拍
download checkin_street_portrait.jpg 8788701

# 白洋裝女生咖啡廳窗邊座位
download checkin_brunch.jpg 20775929

# 女生山頂俯瞰風景旅遊打卡
download checkin_travel_alps.jpg 1557802

# 海邊日落氛圍人像
download checkin_beach_sunset.jpg 2671078

echo "Downloaded $(ls -1 checkin_*.jpg | wc -l | tr -d ' ') 小紅書風格打卡參考圖."
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

# 亞洲女生咖啡廳站姿自拍（暖色吊燈、工業風吧台）
download checkin_cafe.jpg 5709520

# 亞洲女生霓虹夜景街拍（ZAZA 招牌、電影感側臉）
download checkin_neon_city.jpg 19461244

# 精品店全身鏡 OOTD（綠色洋裝、藤編包）
download checkin_street_portrait.jpg 8989509

# 白洋裝女生咖啡廳窗邊座位
download checkin_brunch.jpg 20775929

# 登山者山頂俯瞰綠色山脈（人小景大旅遊打卡）
download checkin_travel_alps.jpg 1271619

# 女生海邊夕陽背影剪影（海岸岩石、逆光）
download checkin_beach_sunset.jpg 2486169

echo "Downloaded $(ls -1 checkin_*.jpg | wc -l | tr -d ' ') 小紅書風格打卡參考圖."
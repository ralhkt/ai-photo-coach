#include <metal_stdlib>
using namespace metal;

struct SilhouetteUniforms {
  float2 viewportSize;
  float strokeWidth;
  float alpha;
  float exposureBias;
  float4 color;
  float4 glowColor;
};

struct VertexOut {
  float4 position [[position]];
  float2 localCoord;
};

vertex VertexOut silhouetteVertex(
    uint vid [[vertex_id]],
    constant float2* vertices [[buffer(0)]],
    constant SilhouetteUniforms& uniforms [[buffer(1)]]) {
  VertexOut out;
  float2 pixel = vertices[vid];
  float2 ndc = float2(
      (pixel.x / uniforms.viewportSize.x) * 2.0 - 1.0,
      1.0 - (pixel.y / uniforms.viewportSize.y) * 2.0);
  out.position = float4(ndc, 0, 1);
  out.localCoord = vertices[vid];
  return out;
}

fragment float4 silhouetteFragment(
    VertexOut in [[stage_in]],
    constant SilhouetteUniforms& uniforms [[buffer(0)]]) {
  float lum = clamp(1.0 + uniforms.exposureBias, 0.65, 1.35);
  float4 stroke = float4(uniforms.color.rgb * lum, uniforms.alpha);
  float glow = uniforms.glowColor.a * exp(-0.0008 * dot(in.localCoord, in.localCoord));
  return stroke + float4(uniforms.glowColor.rgb * glow, glow);
}
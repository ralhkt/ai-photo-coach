#pragma once

#include <vector>

struct CGPoint2D {
  float x;
  float y;
};

struct ContourProcessor {
  static std::vector<CGPoint2D> extractBoundary(
      const float* mask, int width, int height, float threshold = 0.5f);

  static void filterTopologyNoise(
      float* mask, int width, int height, int minComponentArea = 120);

  static std::vector<CGPoint2D> douglasPeucker(
      const std::vector<CGPoint2D>& points, float epsilon);

  static std::vector<CGPoint2D> catmullRomResample(
      const std::vector<CGPoint2D>& points, int targetCount);

  static std::vector<CGPoint2D> processMask(
      const float* mask,
      int width,
      int height,
      float threshold,
      float rdpEpsilon,
      int outputPoints);
};
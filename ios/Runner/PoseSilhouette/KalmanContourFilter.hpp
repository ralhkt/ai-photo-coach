#pragma once

#include <vector>

#include "ContourProcessor.hpp"

class KalmanContourFilter {
 public:
  void reset(size_t count);
  std::vector<CGPoint2D> update(const std::vector<CGPoint2D>& measured, float dt = 1.f / 30.f);

 private:
  struct State {
    float x = 0.f;
    float y = 0.f;
    float vx = 0.f;
    float vy = 0.f;
  };

  std::vector<State> states_;
  float alpha_ = 0.38f;
  float beta_ = 0.08f;
};
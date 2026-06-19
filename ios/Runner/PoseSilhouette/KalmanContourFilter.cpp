#include "KalmanContourFilter.hpp"

void KalmanContourFilter::reset(size_t count) {
  states_.assign(count, State{});
}

std::vector<CGPoint2D> KalmanContourFilter::update(
    const std::vector<CGPoint2D>& measured,
    float dt) {
  if (measured.empty()) {
    return {};
  }
  if (states_.size() != measured.size()) {
    reset(measured.size());
    for (size_t i = 0; i < measured.size(); ++i) {
      states_[i].x = measured[i].x;
      states_[i].y = measured[i].y;
    }
    return measured;
  }

  const float safeDt = dt > 0.f ? dt : 1.f / 30.f;
  std::vector<CGPoint2D> output;
  output.reserve(measured.size());

  for (size_t i = 0; i < measured.size(); ++i) {
    auto& state = states_[i];
    state.x += state.vx * safeDt;
    state.y += state.vy * safeDt;

    const float residualX = measured[i].x - state.x;
    const float residualY = measured[i].y - state.y;
    state.x += alpha_ * residualX;
    state.y += alpha_ * residualY;
    state.vx += beta_ * residualX / safeDt;
    state.vy += beta_ * residualY / safeDt;

    output.push_back({state.x, state.y});
  }
  return output;
}
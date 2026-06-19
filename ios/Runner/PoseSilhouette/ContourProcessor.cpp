#include "ContourProcessor.hpp"

#include <algorithm>
#include <cmath>
#include <queue>

namespace {

float perpDistance(CGPoint2D point, CGPoint2D lineStart, CGPoint2D lineEnd) {
  const float dx = lineEnd.x - lineStart.x;
  const float dy = lineEnd.y - lineStart.y;
  const float lengthSq = dx * dx + dy * dy;
  if (lengthSq < 1e-6f) {
    return std::hypot(point.x - lineStart.x, point.y - lineStart.y);
  }
  const float t = ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / lengthSq;
  const float clamped = std::max(0.f, std::min(1.f, t));
  const float px = lineStart.x + clamped * dx;
  const float py = lineStart.y + clamped * dy;
  return std::hypot(point.x - px, point.y - py);
}

std::vector<CGPoint2D> traceBoundaryMoore(
    const std::vector<uint8_t>& binary, int width, int height) {
  int startX = -1;
  int startY = -1;
  for (int y = 0; y < height && startX < 0; ++y) {
    for (int x = 0; x < width; ++x) {
      if (binary[y * width + x]) {
        startX = x;
        startY = y;
        break;
      }
    }
  }
  if (startX < 0) {
    return {};
  }

  static const int dirs[8][2] = {
      {1, 0}, {1, -1}, {0, -1}, {-1, -1},
      {-1, 0}, {-1, 1}, {0, 1}, {1, 1},
  };

  std::vector<CGPoint2D> contour;
  int x = startX;
  int y = startY;
  int dir = 7;

  do {
    contour.push_back({static_cast<float>(x), static_cast<float>(y)});
    const int search = (dir + 5) % 8;
    bool found = false;
    for (int i = 0; i < 8; ++i) {
      const int d = (search + i) % 8;
      const int nx = x + dirs[d][0];
      const int ny = y + dirs[d][1];
      if (nx >= 0 && nx < width && ny >= 0 && ny < height &&
          binary[ny * width + nx]) {
        x = nx;
        y = ny;
        dir = d;
        found = true;
        break;
      }
    }
    if (!found) {
      break;
    }
  } while ((x != startX || y != startY) && contour.size() < 4096);

  if (contour.size() > 1 && contour.front().x == contour.back().x &&
      contour.front().y == contour.back().y) {
    contour.pop_back();
  }
  return contour;
}

}  // namespace

std::vector<CGPoint2D> ContourProcessor::extractBoundary(
    const float* mask, int width, int height, float threshold) {
  if (mask == nullptr || width <= 0 || height <= 0) {
    return {};
  }

  std::vector<uint8_t> binary(width * height);
  for (int i = 0; i < width * height; ++i) {
    binary[i] = mask[i] >= threshold ? 1 : 0;
  }
  return traceBoundaryMoore(binary, width, height);
}

void ContourProcessor::filterTopologyNoise(
    float* mask, int width, int height, int minComponentArea) {
  if (mask == nullptr || width <= 0 || height <= 0) {
    return;
  }

  std::vector<int> labels(width * height, -1);
  int nextLabel = 0;
  const int dx[4] = {1, -1, 0, 0};
  const int dy[4] = {0, 0, 1, -1};

  for (int y = 0; y < height; ++y) {
    for (int x = 0; x < width; ++x) {
      const int idx = y * width + x;
      if (mask[idx] < 0.5f || labels[idx] != -1) {
        continue;
      }

      std::queue<int> q;
      q.push(idx);
      labels[idx] = nextLabel;
      int area = 0;

      while (!q.empty()) {
        const int cur = q.front();
        q.pop();
        area++;
        const int cx = cur % width;
        const int cy = cur / width;
        for (int d = 0; d < 4; ++d) {
          const int nx = cx + dx[d];
          const int ny = cy + dy[d];
          if (nx < 0 || ny < 0 || nx >= width || ny >= height) {
            continue;
          }
          const int ni = ny * width + nx;
          if (mask[ni] >= 0.5f && labels[ni] == -1) {
            labels[ni] = nextLabel;
            q.push(ni);
          }
        }
      }

      if (area < minComponentArea) {
        for (int i = 0; i < width * height; ++i) {
          if (labels[i] == nextLabel) {
            mask[i] = 0.f;
          }
        }
      }
      nextLabel++;
    }
  }
}

std::vector<CGPoint2D> ContourProcessor::douglasPeucker(
    const std::vector<CGPoint2D>& points, float epsilon) {
  if (points.size() < 3) {
    return points;
  }

  float maxDistance = 0.f;
  size_t index = 0;
  const CGPoint2D start = points.front();
  const CGPoint2D finish = points.back();

  for (size_t i = 1; i + 1 < points.size(); ++i) {
    const float distance = perpDistance(points[i], start, finish);
    if (distance > maxDistance) {
      maxDistance = distance;
      index = i;
    }
  }

  if (maxDistance > epsilon) {
    std::vector<CGPoint2D> left(points.begin(), points.begin() + index + 1);
    std::vector<CGPoint2D> right(points.begin() + index, points.end());
    auto leftResult = douglasPeucker(left, epsilon);
    auto rightResult = douglasPeucker(right, epsilon);
    if (!leftResult.empty()) {
      leftResult.pop_back();
    }
    leftResult.insert(leftResult.end(), rightResult.begin(), rightResult.end());
    return leftResult;
  }

  return {start, finish};
}

std::vector<CGPoint2D> ContourProcessor::catmullRomResample(
    const std::vector<CGPoint2D>& points, int targetCount) {
  if (points.size() < 2 || targetCount < 3) {
    return points;
  }

  const int count = static_cast<int>(points.size());
  std::vector<float> segLens(count);
  float total = 0.f;
  for (int i = 0; i < count; ++i) {
    const CGPoint2D& a = points[i];
    const CGPoint2D& b = points[(i + 1) % count];
    segLens[i] = std::hypot(b.x - a.x, b.y - a.y);
    total += segLens[i];
  }
  if (total <= 0.f) {
    return points;
  }

  std::vector<CGPoint2D> out;
  out.reserve(targetCount);
  int seg = 0;
  float segStart = 0.f;

  for (int k = 0; k < targetCount; ++k) {
    const float target = total * k / targetCount;
    while (seg < count - 1 && segStart + segLens[seg] < target) {
      segStart += segLens[seg];
      seg++;
    }
    const float segLen = segLens[seg];
    const float frac = segLen > 0.f ? (target - segStart) / segLen : 0.f;
    const CGPoint2D& p0 = points[seg];
    const CGPoint2D& p1 = points[(seg + 1) % count];
    out.push_back({
        p0.x + (p1.x - p0.x) * frac,
        p0.y + (p1.y - p0.y) * frac,
    });
  }
  return out;
}

std::vector<CGPoint2D> ContourProcessor::processMask(
    const float* mask,
    int width,
    int height,
    float threshold,
    float rdpEpsilon,
    int outputPoints) {
  std::vector<float> working(mask, mask + width * height);
  filterTopologyNoise(working.data(), width, height, 120);

  auto boundary = extractBoundary(working.data(), width, height, threshold);
  if (boundary.size() < 8) {
    return {};
  }

  if (boundary.size() > 256) {
    const int step = static_cast<int>(boundary.size() / 256);
    std::vector<CGPoint2D> reduced;
    for (size_t i = 0; i < boundary.size(); i += step) {
      reduced.push_back(boundary[i]);
    }
    boundary = reduced;
  }

  auto simplified = douglasPeucker(boundary, rdpEpsilon);
  if (simplified.size() < 4) {
    return {};
  }

  const int target = std::max(outputPoints, 8);
  if (static_cast<int>(simplified.size()) < target) {
    return catmullRomResample(simplified, target);
  }
  return simplified;
}
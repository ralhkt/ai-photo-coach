#import "KalmanContourFilterBridge.h"

#import <UIKit/UIKit.h>

#include "KalmanContourFilter.hpp"

@implementation KalmanContourFilterBridge {
  KalmanContourFilter _filter;
}

- (NSArray<NSValue *> *)smooth:(NSArray<NSValue *> *)points {
  if (points.count < 2) {
    return points;
  }

  std::vector<CGPoint2D> measured;
  measured.reserve(points.count);
  for (NSValue* value in points) {
    const CGPoint point = value.CGPointValue;
    measured.push_back({static_cast<float>(point.x), static_cast<float>(point.y)});
  }

  const auto smoothed = _filter.update(measured);
  NSMutableArray<NSValue *> *result = [NSMutableArray arrayWithCapacity:smoothed.size()];
  for (const auto& point : smoothed) {
    [result addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
  }
  return result;
}

- (void)reset {
  _filter.reset(0);
}

@end
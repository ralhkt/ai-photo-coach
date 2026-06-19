#import "ContourProcessorBridge.h"

#import <UIKit/UIKit.h>

#include "ContourProcessor.hpp"

@implementation ContourProcessorBridge

+ (NSArray<NSValue *> *)contourFromMask:(float *)mask
                                 width:(int)width
                                height:(int)height
                             threshold:(float)threshold
                            rdpEpsilon:(float)rdpEpsilon
                          outputPoints:(int)outputPoints {
  const auto points = ContourProcessor::processMask(
      mask, width, height, threshold, rdpEpsilon, outputPoints);
  if (points.empty()) {
    return nil;
  }

  NSMutableArray<NSValue *> *result = [NSMutableArray arrayWithCapacity:points.size()];
  for (const auto& point : points) {
    [result addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
  }
  return result;
}

@end
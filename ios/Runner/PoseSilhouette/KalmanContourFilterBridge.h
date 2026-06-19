#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface KalmanContourFilterBridge : NSObject

- (NSArray<NSValue *> *)smooth:(NSArray<NSValue *> *)points;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
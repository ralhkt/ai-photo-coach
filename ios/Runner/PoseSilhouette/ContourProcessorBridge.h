#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContourProcessorBridge : NSObject

+ (NSArray<NSValue *> * _Nullable)contourFromMask:(float *)mask
                                            width:(int)width
                                           height:(int)height
                                        threshold:(float)threshold
                                       rdpEpsilon:(float)rdpEpsilon
                                     outputPoints:(int)outputPoints;

@end

NS_ASSUME_NONNULL_END
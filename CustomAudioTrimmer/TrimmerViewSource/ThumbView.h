//
//  AudioTrimmerLeftOverlay.h
//  AudioTrimmer


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThumbView : UIView

@property (strong, nonatomic, nullable) UIColor *color;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color right:(BOOL)flag NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame thumbImage:(UIImage *)image NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

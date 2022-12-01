//
//  RulerView.h
//  AudioTrimmer

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RulerView : UIView

@property (assign, nonatomic) CGFloat widthPerSecond;
@property (strong, nonatomic) UIColor *themeColor;
@property (assign, nonatomic) NSInteger labelInterval;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame widthPerSecond:(CGFloat)width themeColor:(UIColor *)color labelInterval:(NSInteger)interval NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

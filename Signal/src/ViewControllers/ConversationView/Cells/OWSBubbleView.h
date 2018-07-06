//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "OWSBubbleView.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat kOWSMessageCellCornerRadius_Large;
extern const CGFloat kOWSMessageCellCornerRadius_Small;

@class OWSBubbleView;

@protocol OWSBubbleViewPartner <NSObject>

- (void)updateLayers;

- (void)setBubbleView:(OWSBubbleView *)bubbleView;

@end

#pragma mark -

@interface OWSBubbleView : UIView

+ (UIBezierPath *)roundedBezierRectWithBubbleTop:(CGFloat)bubbleTop
                                      bubbleLeft:(CGFloat)bubbleLeft
                                    bubbleBottom:(CGFloat)bubbleBottom
                                     bubbleRight:(CGFloat)bubbleRight
                               sharpCornerRadius:(CGFloat)sharpCornerRadius
                                wideCornerRadius:(CGFloat)wideCornerRadius
                                    sharpCorners:(UIRectCorner)sharpCorners;

@property (nonatomic, nullable) UIColor *bubbleColor;

@property (nonatomic) UIRectCorner sharpCorners;

- (UIBezierPath *)maskPath;

#pragma mark - Coordination

- (void)addPartnerView:(id<OWSBubbleViewPartner>)view;

- (void)clearPartnerViews;

- (void)updatePartnerViews;

- (CGFloat)minWidth;

@end

NS_ASSUME_NONNULL_END

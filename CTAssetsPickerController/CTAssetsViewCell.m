/*
 CTAssetsViewCell.m
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "CTAssetsViewCell.h"
#import "ALAsset+assetType.h"
#import "ALAsset+accessibilityLabel.h"
#import "NSDateFormatter+timeIntervalFormatter.h"
#import "UIImage+CTAssetsPickerController.h"




@interface CTAssetsViewCell ()

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *videoImage;

@end





@implementation CTAssetsViewCell

static UIFont *titleFont;
static CGFloat titleHeight;
static UIImage *videoIcon;
static UIColor *titleColor;
static UIImage *checkedIcon;
static UIColor *selectedColor;
static UIColor *disabledColor;

+ (void)initialize
{
    titleFont       = [UIFont systemFontOfSize:12];
    titleHeight     = 20.0f;
    videoIcon       = [UIImage ctassetsPickerControllerImageNamed:@"CTAssetsPickerVideo"];
    titleColor      = [UIColor whiteColor];
    checkedIcon     = [UIImage ctassetsPickerControllerImageNamed:@"CTAssetsPickerChecked"];
    selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
    disabledColor   = [UIColor colorWithWhite:1 alpha:0.9];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                 = YES;
        self.isAccessibilityElement = YES;
        self.accessibilityTraits    = UIAccessibilityTraitImage;
        self.enabled                = YES;
    }
    
    return self;
}

- (void)bind:(ALAsset *)asset
{
    self.asset  = asset;
    self.image  = (asset.thumbnail == NULL) ? [UIImage ctassetsPickerControllerImageNamed:@"CTAssetsPickerEmptyCell"] : [UIImage imageWithCGImage:asset.thumbnail];
    
    if ([self.asset isVideo])
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        self.title = [df stringFromTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}


#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawThumbnailInRect:rect];
    
    if ([self.asset isVideo])
        [self drawVideoMetaInRect:rect];
    
    if (!self.isEnabled)
        [self drawDisabledViewInRect:rect];
    
    [self drawSelectedViewInRect:rect isSelected:self.isSelected];
}

- (void)drawThumbnailInRect:(CGRect)rect
{
    [self.image drawInRect:rect];
}

- (void)drawVideoMetaInRect:(CGRect)rect
{
    // Create a gradient from transparent to black
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.8,
        0.0, 0.0, 0.0, 1.0
    };
    
    CGFloat locations [] = {0.0, 0.75, 1.0};
    
    CGColorSpaceRef baseSpace   = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient      = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
    
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGFloat height          = rect.size.height;
    CGPoint startPoint      = CGPointMake(CGRectGetMidX(rect), height - titleHeight);
    CGPoint endPoint        = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
    
    CGColorSpaceRelease(baseSpace);
    CGGradientRelease(gradient);
    
    CGSize titleSize = [self.title sizeWithAttributes:@{NSFontAttributeName : titleFont}];
    CGRect titleRect = CGRectMake(rect.size.width - titleSize.width - 2, startPoint.y + (titleHeight - 12) / 2, titleSize.width, titleHeight);
    
    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
    titleStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.title drawInRect:titleRect
            withAttributes:@{NSFontAttributeName : titleFont,
                             NSForegroundColorAttributeName : titleColor,
                             NSParagraphStyleAttributeName : titleStyle}];
    
    [videoIcon drawAtPoint:CGPointMake(4, startPoint.y + 1 + (titleHeight - videoIcon.size.height) / 2)];
}

- (void)drawDisabledViewInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, disabledColor.CGColor);
    CGContextFillRect(context, rect);
}

- (void)drawSelectedViewInRect:(CGRect)rect isSelected:(BOOL)isSelected
{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, selectedColor.CGColor);
//    CGContextFillRect(context, rect);
    
//    [checkedIcon drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - checkedIcon.size.width, CGRectGetMinY(rect))];

    if (isSelected) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBStrokeColor(context, 0.157f, 0.694f, 0.275f, 1.0f);
        CGContextSetLineWidth(context, 5);
        CGContextStrokeRect(context, rect);
    }
    
    // Set default values
    CGFloat borderWidth = 1.0;
    CGFloat checkmarkLineWidth = 1.2;
    
    UIColor *borderColor = [UIColor whiteColor];
    UIColor *bodyColor = isSelected ? [UIColor colorWithRed:0.157f green:0.694f blue:0.275f alpha:1.0] :
                                        [UIColor colorWithWhite:0 alpha:0.5];
    UIColor *checkmarkColor = [UIColor whiteColor];
    
    // Set shadow
//    self.layer.shadowColor = [[UIColor grayColor] CGColor];
//    self.layer.shadowOffset = CGSizeMake(0, 0);
//    self.layer.shadowOpacity = 0.6;
//    self.layer.shadowRadius = 2.0;

    CGRect checkmarkFrame = CGRectMake(self.bounds.size.width - 10 - 20, 10, 20, 20);
    
    // Border
    [borderColor setFill];
    [[UIBezierPath bezierPathWithOvalInRect:checkmarkFrame] fill];
    
    // Body
    [bodyColor setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(checkmarkFrame, borderWidth, borderWidth)] fill];
    
    if (isSelected) {
        // Checkmark
//        UIBezierPath *checkmarkPath = [UIBezierPath bezierPath];
//        checkmarkPath.lineWidth = checkmarkLineWidth;
//        
//        [checkmarkPath moveToPoint:CGPointMake(checkmarkFrame.origin.x + CGRectGetWidth(checkmarkFrame) * (6.0 / 24.0), checkmarkFrame.origin.y + CGRectGetHeight(checkmarkFrame) * (12.0 / 24.0))];
//        [checkmarkPath addLineToPoint:CGPointMake(checkmarkFrame.origin.x + CGRectGetWidth(checkmarkFrame) * (10.0 / 24.0), checkmarkFrame.origin.y + CGRectGetHeight(checkmarkFrame) * (16.0 / 24.0))];
//        [checkmarkPath addLineToPoint:CGPointMake(checkmarkFrame.origin.x + CGRectGetWidth(checkmarkFrame) * (18.0 / 24.0), checkmarkFrame.origin.y + CGRectGetHeight(checkmarkFrame) * (8.0 / 24.0))];
//        
//        [checkmarkColor setStroke];
//        [checkmarkPath stroke];
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentCenter];
        
        UIFont* font = [UIFont fontWithName:@"Arial" size:12];
        UIColor* textColor = [UIColor whiteColor];
        NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor, NSParagraphStyleAttributeName : style};
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", self.tag + 1] attributes:stringAttrs];
        
        [attrStr drawInRect:CGRectOffset(checkmarkFrame, 0, 3)];
    }
}


#pragma mark - Accessibility Label

- (NSString *)accessibilityLabel
{
    return self.asset.accessibilityLabel;
}

@end
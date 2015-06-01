/*
 CTAssetsGroupViewCell.m
 
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

#import "CTAssetsPickerCommon.h"
#import "CTAssetsGroupViewCell.h"
#import "NSBundle+CTAssetsPickerController.h"



@interface CTAssetsGroupViewCell ()

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end





@implementation CTAssetsGroupViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.opaque                             = YES;
        self.isAccessibilityElement             = YES;
        self.textLabel.backgroundColor          = self.backgroundColor;
        self.detailTextLabel.backgroundColor    = self.backgroundColor;
        self.detailTextLabel.textColor          = [UIColor colorWithRed:0.506 green:0.502 blue:0.490 alpha:1.000];
        
        UIView *bottomBorder = [[UIView alloc] init];
        bottomBorder.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
        [self.contentView addSubview:bottomBorder];
        PREPCONSTRAINTS(bottomBorder);
        ALIGN_BOTTOM(bottomBorder, 0);
        CONSTRAIN_HEIGHT(bottomBorder, 1.0 / [UIScreen mainScreen].scale);
        ALIGN_LEFT(bottomBorder, 0);
        ALIGN_RIGHT(bottomBorder, -40);
    }
    
    return self;
}

- (void)bind:(ALAssetsGroup *)assetsGroup showNumberOfAssets:(BOOL)showNumberOfAssets;
{
    self.assetsGroup            = assetsGroup;
    
    CGImageRef posterImage      = assetsGroup.posterImage;
    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = height / (CTAssetThumbnailLength);
    
    self.imageView.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    self.textLabel.text         = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
    
    if (showNumberOfAssets) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setLocale:[NSLocale currentLocale]];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:0];
        NSString *theString = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:assetsGroup.numberOfAssets]];
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@ Photo%@", theString, (assetsGroup.numberOfAssets > 1 ? @"s": @"")];
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    // Makes imageView get placed in the corner
    self.imageView.frame = CGRectMake( 0, 0, 64, 64);
    
    // Get textlabel frame
    //self.textLabel.backgroundColor = [UIColor blackColor];
    CGRect textlabelFrame = self.textLabel.frame;
    
    // Figure out new width
    textlabelFrame.size.width = textlabelFrame.size.width + textlabelFrame.origin.x - 75;
    // Change origin to what we want
    textlabelFrame.origin.x = 75;
    
    // Assign the the new frame to textLabel
    self.textLabel.frame = textlabelFrame;

    // Get textlabel frame
    //self.textLabel.backgroundColor = [UIColor blackColor];
    CGRect detailTextLabelFrame = self.detailTextLabel.frame;
    
    // Figure out new width
    detailTextLabelFrame.size.width = detailTextLabelFrame.size.width + detailTextLabelFrame.origin.x - 75;
    // Change origin to what we want
    detailTextLabelFrame.origin.x = 75;
    
    // Assign the the new frame to textLabel
    self.detailTextLabel.frame = detailTextLabelFrame;
}


#pragma mark - Accessibility Label

- (NSString *)accessibilityLabel
{
    NSString *label = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    return [label stringByAppendingFormat:CTAssetsPickerControllerLocalizedString(@"%ld Photos"), (long)self.assetsGroup.numberOfAssets];
}

@end
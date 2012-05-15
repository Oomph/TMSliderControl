//
//  TMSliderControlSmall.m
//  TMSliderControl
//
//  Created by Rick Fillion on 10-12-19.
//  All code is provided under the New BSD license.
//

#import "TMSliderControlSmall.h"

@implementation TMSliderControlSmall

+ (NSImage*)sliderWellOn
{
    return [NSImage imageNamed:@"SmallSliderWellOn"];
}

+ (NSImage*)sliderWellOff
{
    return [NSImage imageNamed:@"SmallSliderWellOff"];
}

+ (NSImage*)sliderHandleImage
{
    return [NSImage imageNamed:@"SmallSliderHandle"];
}

+ (NSImage*)sliderHandleDownImage
{
    return [NSImage imageNamed:@"SmallSliderHandleDown"];
}

+ (NSImage*)overlayMask
{
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"state"])
    {
        sliderWell.contents = (self.state == kTMSliderControlState_Active ? [[self class] sliderWellOn] : [[self class] sliderWellOff]);
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)dealloc
{
    [sliderWellOn release];
    [sliderWellOff release];
    [super dealloc];
}

- (BOOL)isFlipped
{
    return NO;
}

- (void)layoutHandle
{
    handleControlRectOff = CGRectMake(0,0, 27, 18);
    handleControlRectOn = CGRectMake([self bounds].size.width - 27, 0, 27, 18);
}

@end

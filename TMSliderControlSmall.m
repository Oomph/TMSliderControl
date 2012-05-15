//
//  TMSliderControlSmall.m
//  TMSliderControl
//
//  Created by Rick Fillion on 10-12-19.
//  All code is provided under the New BSD license.
//

#import "TMSliderControlSmall.h"

@implementation TMSliderControlSmall

+ (NSImage*)sliderHandleImage
{
    return [NSImage imageNamed:@"SmallSliderHandle"];
}

+ (NSImage*)sliderHandleDownImage
{
    return [NSImage imageNamed:@"SmallSliderHandleDown"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"state"])
    {
        sliderWell.contents = (self.state == kTMSliderControlState_Active ? [NSImage imageNamed:@"SmallSliderWellOn"] : [NSImage imageNamed:@"SmallSliderWellOff"]);
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

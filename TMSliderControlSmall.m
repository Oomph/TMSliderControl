//
//  TMSliderControlSmall.m
//  TMSliderControl
//
//  Created by Rick Fillion on 10-12-19.
//  All code is provided under the New BSD license.
//

#import "TMSliderControlSmall.h"

@interface TMSliderControlSmall (Private)
- (void)drawBacking;
- (void)drawHandle;
@end

@implementation TMSliderControlSmall (Private)

- (void)drawBacking
{
    [sliderWellOff drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    CGFloat percentOn = (handleControlRect.origin.x - handleControlRectOff.origin.x) / (handleControlRectOn.origin.x - handleControlRectOff.origin.x);
    [sliderWellOn drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:percentOn];
}


- (void)drawHandle
{
    NSImage *sliderImage;
    if (controlState == kTMSliderControlState_Active)
    {
        sliderImage = sliderHandleDown;
    }
    else
    {
        sliderImage = sliderHandle;
    }
    [sliderHandleView setImage: sliderImage];
}

- (void)layoutHandle
{
    handleControlRectOff = NSMakeRect(0,0, 27, 18);
    handleControlRectOn = NSMakeRect([self bounds].size.width - 27, 0, 27, 18);
    handleControlRect = handleControlRectOff;
}

@end

@implementation TMSliderControlSmall

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        sliderWellOn = [[NSImage imageNamed:@"SmallSliderWellOn"] retain];
        sliderWellOff = [[NSImage imageNamed:@"SmallSliderWellOff"] retain];

        [sliderHandle release];
        sliderHandle = [[NSImage imageNamed:@"SmallSliderHandle"] retain];
        [sliderHandleDown release];
        sliderHandleDown = [[NSImage imageNamed:@"SmallSliderHandleDown"] retain];
        [self layoutHandle];
    }
    return self;
}

- (void)dealloc
{
    [sliderWellOn release];
    [sliderWellOff release];
    [sliderHandle release];
    [sliderHandleDown release];
    [super dealloc];
}

- (void)drawRect:(NSRect)rect {
    [self drawBacking];
    [self drawHandle];
}

- (BOOL)isFlipped
{
    return NO;
}

@end

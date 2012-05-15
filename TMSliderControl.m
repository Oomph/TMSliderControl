//
//  TMSliderControl.m
//  TMSliderControl
//
//  Created by Rick Fillion on 01/02/09.
//  All code is provided under the New BSD license.
//

#import "TMSliderControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation TMSliderControl
@synthesize state, enabled;
@synthesize sliderHandleImage, sliderHandleDownImage;
@synthesize sliderWell, sliderHandle, overlayMask;
@synthesize target, action;

+ (void)initialize
{
    if (self != [TMSliderControl class])
		return;
    
    [NSObject exposeBinding:@"state"];
    [NSObject exposeBinding:@"enabled"];
}

+ (NSImage*)sliderHandleImage
{
    return [NSImage imageNamed:@"SliderHandle"];
}

+ (NSImage*)sliderHandleDownImage
{
    return [NSImage imageNamed:@"SliderHandleDown"];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self layoutHandle];

		self.state = kTMSliderControlState_Inactive;
        self.enabled = YES;
        
        self.sliderHandleImage = [[self class] sliderHandleImage];
        self.sliderHandleDownImage = [[self class] sliderHandleImage];
        
        [self setLayer:[CALayer layer]];
        [self setWantsLayer:YES];
        
        self.sliderWell = [CALayer layer];
        sliderWell.frame = NSRectToCGRect(self.bounds);
        sliderWell.contents = [NSImage imageNamed:@"SliderWell"];
        [self.layer addSublayer:sliderWell];
        
        self.sliderHandle = [CALayer layer];
        sliderHandle.frame = handleControlRectOff;
        sliderHandle.contents = sliderHandleImage;
        [sliderWell addSublayer:sliderHandle];

        self.overlayMask = [CALayer layer];
        overlayMask.frame = NSRectToCGRect(self.bounds);
        overlayMask.contents = [NSImage imageNamed:@"OverlayMask"];
        [self.layer addSublayer:overlayMask];
        
        [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:&self];
        [self addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:&self];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"state"];
    [self removeObserver:self forKeyPath:@"enabled"];
    
    [sliderWell release];
    [overlayMask release];
    [sliderHandle release];
    [sliderHandleImage release];
    [sliderHandleDownImage release];

    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"state"])
    {
        CGFloat newXPosition = (self.state == kTMSliderControlState_Active ? CGRectGetMidX(handleControlRectOn) : CGRectGetMidX(handleControlRectOff));
        
        CGPoint sliderPosition = sliderHandle.position;
        sliderPosition.x = newXPosition;
        
        sliderHandle.position = sliderPosition;
    }
    else if([keyPath isEqualToString:@"enabled"])
    {
        self.layer.opacity = (self.enabled ? 1.0 : 0.25);
    }
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(NSEvent*)theEvent
{
	if(self.enabled)
    {
        CGPoint mousePoint = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
        hasDragged = NO;
        // down on the position control rect
        if(CGRectContainsPoint(sliderHandle.frame, mousePoint))
        {
            mouseDownPosition = CGPointMake(mousePoint.x - sliderHandle.position.x, 0);
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            sliderHandle.contents = sliderHandleDownImage;
            [CATransaction commit];
        }
    }
}


- (void)mouseDragged:(NSEvent*)theEvent
{
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	hasDragged = YES;
    
		// center the rect around the mouse point
        
		float newXPosition = mousePoint.x - mouseDownPosition.x;
        
        // clamp the position .
        if (newXPosition < CGRectGetMidX(handleControlRectOff))
            newXPosition = CGRectGetMidX(handleControlRectOff);
        if (newXPosition > CGRectGetMidX(handleControlRectOn))
            newXPosition = CGRectGetMidX(handleControlRectOn);
        
        CGPoint sliderPosition = sliderHandle.position;
        sliderPosition.x = newXPosition;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        sliderHandle.position = sliderPosition;
        [CATransaction commit];
}


- (void)mouseUp:(NSEvent*)theEvent
{
    if(self.enabled)
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        sliderHandle.contents = sliderHandleImage;
        [CATransaction commit];
        
        float minimumMovement = 10.0;
        if(hasDragged && state != kTMSliderControlState_Inactive)
        {
            if (sliderHandle.frame.origin.x < [self bounds].size.width - sliderHandle.frame.size.width - minimumMovement)
            {
                // moved it enough to set it
                self.state = kTMSliderControlState_Inactive;
            }
            else
            {
                // put it back where it was.
                self.state = kTMSliderControlState_Active;
            }
        }
        else
        {
            self.state = !self.state;
        }
        
        if(target && [target respondsToSelector:action])
            [target performSelector:action withObject:self];
        hasDragged = NO;
    }
}

- (void)layoutHandle
{
    handleControlRectOff = CGRectMake(-2,1, 44, 27);
    handleControlRectOn = CGRectMake([self bounds].size.width - handleControlRectOff.size.width + 2,1, 44, 27);
}

@end

//
//  TMSliderControl.m
//  TMSliderControl
//
//  Created by Rick Fillion on 01/02/09.
//  All code is provided under the New BSD license.
//

#import "TMSliderControl.h"

/*
 * Basic NSImageView subclass for handle
 */

@interface TMSliderControlHandle : NSImageView {
}
@end
@implementation TMSliderControlHandle
- (void)mouseDown:(NSEvent *)theEvent   {    [[self superview] mouseDown:theEvent];     }
- (void)mouseDragged:(NSEvent*)theEvent {    [[self superview] mouseDragged:theEvent];  }
- (void)mouseUp:(NSEvent*)theEvent      {    [[self superview] mouseUp:theEvent];       }
@end

/*
 * Private control methods
 */

@interface TMSliderControl (Private)
- (void)drawBacking;
- (void)drawOverlay;
- (void)drawHandle;
@end

@implementation TMSliderControl (Private)

- (void)drawBacking
{
    [sliderWell drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)drawOverlay
{
    [overlayMask drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
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
    handleControlRectOff = NSMakeRect(-2,1, 44, 27);
    handleControlRectOn = NSMakeRect([self bounds].size.width - 42,1, 44, 27);
    handleControlRect = handleControlRectOff;
}

@end

@implementation TMSliderControl

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        sliderWell = [[NSImage imageNamed:@"SliderWell"] retain];
        overlayMask = [[NSImage imageNamed:@"OverlayMask"] retain];
        sliderHandle = [[NSImage imageNamed:@"SliderHandle"] retain];
        sliderHandleDown = [[NSImage imageNamed:@"SliderHandleDown"] retain];
        [self layoutHandle];
        sliderHandleView = [[TMSliderControlHandle alloc] initWithFrame: handleControlRectOff];
        [sliderHandleView setWantsLayer: YES];
        [self addSubview: sliderHandleView];
        state = NO;
        //[self setWantsLayer:YES];
    }
    return self;
}

- (void)dealloc
{
    [sliderWell release];
    [overlayMask release];
    [sliderHandle release];
    [sliderHandleDown release];
    [sliderHandleView release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [self setWantsLayer:YES];
}

- (void)drawRect:(NSRect)rect {
    [self drawBacking];
    [self drawHandle];
    [self drawOverlay];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(NSEvent*)theEvent
{
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	hasDragged = NO;
	// down on the position control rect
	if(NSPointInRect(mousePoint,handleControlRect))
	{
		controlState = kTMSliderControlState_Active;
        mouseDownPosition = NSMakePoint(mousePoint.x - handleControlRect.origin.x, 0);
        [self setNeedsDisplay:YES];
	}
}


- (void)mouseDragged:(NSEvent*)theEvent
{
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	hasDragged = YES;
    
	// dragging the position control rect
	if(controlState == kTMSliderControlState_Active)
	{
		// center the rect around the mouse point
        
		float newXPosition = mousePoint.x - mouseDownPosition.x;
        
        // clamp the position .
        if (newXPosition < handleControlRectOff.origin.x)
            newXPosition = handleControlRectOff.origin.x;
        if (newXPosition > handleControlRectOn.origin.x)
            newXPosition = handleControlRectOn.origin.x;
        
        handleControlRect.origin.x = newXPosition;
        [sliderHandleView setFrame: handleControlRect];
        [self setNeedsDisplay:YES];
	}
}


- (void)mouseUp:(NSEvent*)theEvent
{
    float minimumMovement = 10.0;
    if(controlState != kTMSliderControlState_Inactive)
	{
		// switch the state to inactive and redraw
		controlState = kTMSliderControlState_Inactive;
        if (!hasDragged)
        {
            // if they never dragged, but clicked/released in place on the handle, flip it over.
            [self setState:![self state]];
        }
        else if (state == NSOffState)
        {
            if (handleControlRect.origin.x > minimumMovement)
            {
                // moved it enough to set it
                [self setState: NSOnState];
            }
            else
            {
                // put it back where it was.
                [self setState: NSOffState];
            }
        }
        else
        {
            if (handleControlRect.origin.x < [self bounds].size.width - handleControlRect.size.width - minimumMovement)
            {
                // moved it enough to set it
                [self setState: NSOffState];
            }
            else
            {
                // put it back where it was.
                [self setState: NSOnState];
            }
        }

	}
    else
    {
        [self setState:![self state]];
    }
}


- (BOOL)state
{
    return state;
}

- (void)setState:(NSInteger)newState
{
    [super setState:newState];
    if ([self state] == NSOffState)
    {
        handleControlRect = handleControlRectOff;
    }
    else
    {
        handleControlRect = handleControlRectOn;
    }
    
    if ([sliderHandleView window])
    {
        // It's in a window, we can use CoreAnimation
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration: 0.15];
        [[sliderHandleView animator] setFrameOrigin: handleControlRect.origin];
        [NSAnimationContext endGrouping];
    }
    else {
        // It's not in a window, just set it.
        [sliderHandleView setFrameOrigin:handleControlRect.origin];
    }
    
    [self sendAction:[self action] to:[self target]];
    [self setNeedsDisplay: YES];
}


- (void)setTarget:(id)anObject
{
    target = anObject;
}
- (id)target
{
    return target;
}
- (void)setAction:(SEL)aSelector
{
    action = aSelector;
}
- (SEL)action
{
    return action;
}


@end

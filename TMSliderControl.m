//
//  TMSliderControl.m
//  TMSliderControl
//
//  Created by Rick Fillion on 01/02/09.
//  All code is provided under the New BSD license.
//

#import "TMSliderControl.h"
#import <QuartzCore/QuartzCore.h>

static void *StateObservationContext = (void *)2091;
static void *EnabledObservationContext = (void *)2092;

@implementation TMSliderControl
@synthesize state, enabled;
@synthesize sliderHandleImage, sliderHandleDownImage;
@synthesize sliderWell, sliderHandle, overlayMask;
@synthesize target, action;

//bindings support
@synthesize observedObjectForState;
@synthesize observedKeyPathForState;
@synthesize observedObjectForEnabled;
@synthesize observedKeyPathForEnabled;


+ (void)initialize
{
    if (self != [TMSliderControl class])
        return;
    
    [NSObject exposeBinding:@"state"];
    [NSObject exposeBinding:@"enabled"];
}

- (Class)valueClassForBinding:(NSString *)binding
{
    // both require numbers
    return [NSNumber class];    
}

+ (NSImage*)sliderWellOn
{
    return [NSImage imageNamed:@"SliderWell"];
}

+ (NSImage*)sliderWellOff
{
    return [NSImage imageNamed:@"SliderWell"];
}

+ (NSImage*)sliderHandleImage
{
    return [NSImage imageNamed:@"SliderHandle"];
}

+ (NSImage*)sliderHandleDownImage
{
    return [NSImage imageNamed:@"SliderHandleDown"];
}

+ (NSImage*)overlayMask
{
    return [NSImage imageNamed:@"OverlayMask"];
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code here.
        [self layoutHandle];

		self.state = kTMSliderControlState_Inactive;
        self.enabled = YES;
        
        self.sliderHandleImage = [[self class] sliderHandleImage];
        self.sliderHandleDownImage = [[self class] sliderHandleDownImage];
        
        [self setLayer:[CALayer layer]];
        [self setWantsLayer:YES];
        
        CALayer *mask = [CALayer layer];
        mask.frame = self.bounds;
        mask.contents = [[self class] sliderWellOff];
        
        self.sliderWell = [CALayer layer];
        sliderWell.frame = self.bounds;
        sliderWell.contents = [[self class] sliderWellOff];
        sliderWell.mask = mask;
        [self.layer addSublayer:sliderWell];
        
        self.sliderHandle = [CALayer layer];
        sliderHandle.frame = handleControlRectOff;
        sliderHandle.contents = sliderHandleImage;
        [sliderWell addSublayer:sliderHandle];

        self.overlayMask = [CALayer layer];
        overlayMask.frame = self.bounds;
        overlayMask.contents = [[self class] overlayMask];
        [self.layer addSublayer:overlayMask];
    }
    return self;
}

- (void)dealloc
{    
    [self unbind:@"state"];
    [self unbind:@"enabled"];

    [sliderWell release];
    [overlayMask release];
    [sliderHandle release];
    [sliderHandleImage release];
    [sliderHandleDownImage release];

    [super dealloc];
}

- (void)updateUI
{
    CGFloat newXPosition = (self.state == kTMSliderControlState_Active ? CGRectGetMidX(handleControlRectOn) : CGRectGetMidX(handleControlRectOff));
    
    CGPoint sliderPosition = sliderHandle.position;
    sliderPosition.x = newXPosition;
    
    sliderHandle.position = sliderPosition;
    self.layer.opacity = (self.enabled ? 1.0 : [self disabledOpacity]);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == StateObservationContext)
    {
        NSNumber *value = [observedObjectForState valueForKey:observedKeyPathForState];
        if(value)
            [self setValue:value forKey:@"state"];
    }
    if(context == EnabledObservationContext)
    {
        NSNumber *value = [observedObjectForEnabled valueForKey:observedKeyPathForEnabled];
        if(value)
            [self setValue:value forKey:@"enabled"];
    }
    [self updateUI];
}

- (CGFloat)minimumMovement
{
    return 10.0f;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)canBecomeKeyView
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
	if(self.enabled)
	{
		NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		hasDragged = YES;
		
		// center the rect around the mouse point
        
		CGFloat newXPosition = mousePoint.x - mouseDownPosition.x;
        
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
}


- (void)mouseUp:(NSEvent*)theEvent
{
    if(self.enabled)
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        sliderHandle.contents = sliderHandleImage;
        [CATransaction commit];
        
        CGFloat minimumMovement = [self minimumMovement];
        if(hasDragged && state != kTMSliderControlState_Inactive)
        {
            if (sliderHandle.frame.origin.x < [self bounds].size.width - sliderHandle.frame.size.width - minimumMovement)
            {
                // moved it enough to set it
                self.state = kTMSliderControlState_Inactive;
                if (observedObjectForState)
                {
                    [observedObjectForState setValue: [NSNumber numberWithBool:state]
                                          forKeyPath: observedKeyPathForState];
                }
           }
            else
            {
                // put it back where it was.
                self.state = kTMSliderControlState_Active;
                if (observedObjectForState)
                {
                    [observedObjectForState setValue: [NSNumber numberWithBool:state]
                                          forKeyPath: observedKeyPathForState];
                }
            }
        }
        else
        {
            self.state = !self.state;
            if (observedObjectForState)
            {
                [observedObjectForState setValue: [NSNumber numberWithBool:state]
                                      forKeyPath: observedKeyPathForState];
            }
        }
        [self updateUI];

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

- (IBAction)moveLeft:(id)sender
{
    self.state = NO;
}

- (IBAction)moveRight:(id)sender
{
    self.state = YES;
}

- (CGFloat)disabledOpacity
{
	return 0.25;
}

#pragma mark Bindings Support

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    if([binding isEqualToString:@"state"])
    {
        [observable addObserver:self forKeyPath:keyPath options:0 context:StateObservationContext];
        
        [self setObservedObjectForState:observable];
        [self setObservedKeyPathForState:keyPath];
    }
    else if ([binding isEqualToString:@"enabled"])
    {
        [observable addObserver:self forKeyPath:keyPath options:0 context:EnabledObservationContext];
        
        [self setObservedObjectForEnabled:observable];
        [self setObservedKeyPathForEnabled:keyPath];
    }
     
    [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    [self updateUI];
}

- (void)unbind:bindingName
{
    if ([bindingName isEqualToString:@"state"])
    {
        [observedObjectForState removeObserver:self
                                    forKeyPath:observedKeyPathForState];
        [self setObservedObjectForState:nil];
        [self setObservedKeyPathForState:nil];
    }   
    if ([bindingName isEqualToString:@"enabled"])
    {
        [observedObjectForEnabled removeObserver:self
                                     forKeyPath:observedKeyPathForEnabled];
        [self setObservedObjectForEnabled:nil];
        [self setObservedKeyPathForEnabled:nil];
    }
    [super unbind:bindingName];
    [self updateUI];
}

@end

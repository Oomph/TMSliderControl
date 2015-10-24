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

- (instancetype)initWithFrame:(NSRect)frame {
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
        _sliderWell.frame = self.bounds;
        _sliderWell.contents = [[self class] sliderWellOff];
        _sliderWell.mask = mask;
        [self.layer addSublayer:_sliderWell];
        
        self.sliderHandle = [CALayer layer];
        _sliderHandle.frame = handleControlRectOff;
        _sliderHandle.contents = _sliderHandleImage;
        [_sliderWell addSublayer:_sliderHandle];

        self.overlayMask = [CALayer layer];
        _overlayMask.frame = self.bounds;
        _overlayMask.contents = [[self class] overlayMask];
        [self.layer addSublayer:_overlayMask];
    }
    return self;
}

- (void)dealloc
{    
    [self unbind:@"state"];
    [self unbind:@"enabled"];


    
}

- (void)updateUI
{
    CGFloat newXPosition = (self.state == kTMSliderControlState_Active ? CGRectGetMidX(handleControlRectOn) : CGRectGetMidX(handleControlRectOff));
    
    CGPoint sliderPosition = _sliderHandle.position;
    sliderPosition.x = newXPosition;
    
    _sliderHandle.position = sliderPosition;
    self.layer.opacity = (float)(self.enabled ? 1.0f : [self disabledOpacity]);
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
    return [NSApp isFullKeyboardAccessEnabled];
}

- (BOOL)canBecomeKeyView
{
    return [NSApp isFullKeyboardAccessEnabled];
}

- (NSRect)focusRingMaskBounds
{
    return [self bounds];
}

- (void)drawFocusRingMask
{
    [self.layer renderInContext:[[NSGraphicsContext currentContext] graphicsPort]];
}

- (void)mouseDown:(NSEvent*)theEvent
{
	if(self.enabled)
    {
        CGPoint mousePoint = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
        hasDragged = NO;
        // down on the position control rect
        if(CGRectContainsPoint(_sliderHandle.frame, mousePoint))
        {
            mouseDownPosition = CGPointMake(mousePoint.x - _sliderHandle.position.x, 0);
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            _sliderHandle.contents = _sliderHandleDownImage;
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
        
        CGPoint sliderPosition = _sliderHandle.position;
        sliderPosition.x = newXPosition;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _sliderHandle.position = sliderPosition;
        [CATransaction commit];
	}
}


- (void)mouseUp:(NSEvent*)theEvent
{
    if(self.enabled)
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _sliderHandle.contents = _sliderHandleImage;
        [CATransaction commit];
        
        CGFloat minimumMovement = [self minimumMovement];
        if(hasDragged && _state != kTMSliderControlState_Inactive)
        {
            if (_sliderHandle.frame.origin.x < [self bounds].size.width - _sliderHandle.frame.size.width - minimumMovement)
            {
                // moved it enough to set it
                self.state = kTMSliderControlState_Inactive;
                if (observedObjectForState)
                {
                    [observedObjectForState setValue: @(_state)
                                          forKeyPath: observedKeyPathForState];
                }
           }
            else
            {
                // put it back where it was.
                self.state = kTMSliderControlState_Active;
                if (observedObjectForState)
                {
                    [observedObjectForState setValue: @(_state)
                                          forKeyPath: observedKeyPathForState];
                }
            }
        }
        else
        {
            self.state = !self.state;
            if (observedObjectForState)
            {
                [observedObjectForState setValue: @(_state)
                                      forKeyPath: observedKeyPathForState];
            }
        }
        [self updateUI];

        if(_target && [_target respondsToSelector:_action])
            [_target performSelector:_action withObject:self];
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

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:[self bounds]];
}

#pragma mark Bindings Support

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    if([binding isEqualToString:@"state"])
    {
        [observable addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:StateObservationContext];
        
        [self setObservedObjectForState:observable];
        [self setObservedKeyPathForState:keyPath];
    }
    else if ([binding isEqualToString:@"enabled"])
    {
        [observable addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:EnabledObservationContext];
        
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

#pragma mark -

- (void)setState:(BOOL)state
{
	if (_state != state)
	{
		_state = state;
		NSAccessibilityPostNotification(self, NSAccessibilityValueChangedNotification);
	}
}

#pragma mark - Accessibility

- (id)accessibilityValue
{
    return [NSNumber numberWithBool:self.state];
}

- (id)accessibilityLabel
{
    if (self.accessibilityText) {
        return self.accessibilityText;
    }
    
    return NSLocalizedStringWithDefaultValue(@"LOCALIZED_SWITCH_LABEL", @"Localizable", [NSBundle mainBundle], @"switch", @"switch label when no accessibility text is set");;
}

- (BOOL)accessibilityPerformPress
{
    self.state = !self.state;
    [self updateUI];
    return YES;
}

@end

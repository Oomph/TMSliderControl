//
//  TMSliderControl.h
//  TMSliderControl
//
//  Created by Rick Fillion on 01/02/09.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>

typedef enum 
{
    kTMSliderControlState_Inactive = 0,
    kTMSliderControlState_Active = 1
  
}TMSliderControlState;

@class TMSliderControlHandle;

@interface TMSliderControl : NSControl {
    NSImage *sliderWell;
    NSImage *overlayMask;
    NSImage *sliderHandle;
    NSImage *sliderHandleDown;
    TMSliderControlHandle *sliderHandleView;
    
    // drawing 
	NSRect handleControlRect;
    NSRect handleControlRectOn;
    NSRect handleControlRectOff;
    NSPoint mouseDownPosition;
    
    // state
    TMSliderControlState controlState;
    BOOL hasDragged;
    BOOL state;

    id target;
    SEL action;
}

// events
- (void)mouseDown:(NSEvent*)theEvent;
- (void)mouseDragged:(NSEvent*)theEvent;
- (void)mouseUp:(NSEvent*)theEvent;

- (BOOL)state;
- (void)setState:(BOOL)newState;

- (void)setTarget:(id)anObject;
- (id)target;
- (void)setAction:(SEL)aSelector;
- (SEL)action;

@end



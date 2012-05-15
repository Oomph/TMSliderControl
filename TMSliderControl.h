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
    CALayer *sliderWell;
    CALayer *overlayMask;
    NSImage *sliderHandleImage;
    NSImage *sliderHandleDownImage;
    CALayer *sliderHandle;
    
    // drawing 
    CGRect handleControlRectOn;
    CGRect handleControlRectOff;
    CGPoint mouseDownPosition;
    
    // state
    BOOL hasDragged;
    NSInteger state;
    BOOL enabled;
    
    id target;
    SEL action;
}

// events
- (void)mouseDown:(NSEvent*)theEvent;
- (void)mouseDragged:(NSEvent*)theEvent;
- (void)mouseUp:(NSEvent*)theEvent;

- (void)layoutHandle;

@property (nonatomic, retain) CALayer *sliderWell;
@property (nonatomic, retain) CALayer *overlayMask;
@property (nonatomic, retain) NSImage *sliderHandleImage;
@property (nonatomic, retain) NSImage *sliderHandleDownImage;
@property (nonatomic, retain) CALayer *sliderHandle;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;

@end



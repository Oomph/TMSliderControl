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

@interface TMSliderControl : NSView {
    
    // drawing 
    CGRect handleControlRectOn;
    CGRect handleControlRectOff;
    CGPoint mouseDownPosition;
    
    // state
    BOOL hasDragged;
    
    id observedObjectForState;
    NSString *observedKeyPathForState;

    id observedObjectForEnabled;
    NSString *observedKeyPathForEnabled;
}

- (void)updateUI;

// events
- (void)mouseDown:(NSEvent*)theEvent;
- (void)mouseDragged:(NSEvent*)theEvent;
- (void)mouseUp:(NSEvent*)theEvent;

- (IBAction)moveLeft:(id)sender;
- (IBAction)moveRight:(id)sender;

- (void)layoutHandle;
- (CGFloat)disabledOpacity;

@property (nonatomic, retain) CALayer *sliderWell;
@property (nonatomic, retain) CALayer *overlayMask;
@property (nonatomic, retain) NSImage *sliderHandleImage;
@property (nonatomic, retain) NSImage *sliderHandleDownImage;
@property (nonatomic, retain) CALayer *sliderHandle;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL state;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;

@property (nonatomic, retain) id observedObjectForState;
@property (nonatomic, copy) NSString *observedKeyPathForState;

@property (nonatomic, retain) id observedObjectForEnabled;
@property (nonatomic, copy) NSString *observedKeyPathForEnabled;

@property (nonatomic, retain) NSString *purposeDescription;

@end



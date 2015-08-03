//
//  TMSliderControl.h
//  TMSliderControl
//
//  Created by Rick Fillion on 01/02/09.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(unsigned int, TMSliderControlState) 
{
    kTMSliderControlState_Inactive = 0,
    kTMSliderControlState_Active = 1
  
};

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
@property (nonatomic, readonly) CGFloat disabledOpacity;

@property (nonatomic, strong) CALayer *sliderWell;
@property (nonatomic, strong) CALayer *overlayMask;
@property (nonatomic, strong) NSImage *sliderHandleImage;
@property (nonatomic, strong) NSImage *sliderHandleDownImage;
@property (nonatomic, strong) CALayer *sliderHandle;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL state;
@property (nonatomic, unsafe_unretained) id target;
@property (nonatomic, assign) SEL action;

@property (nonatomic, strong) id observedObjectForState;
@property (nonatomic, copy) NSString *observedKeyPathForState;

@property (nonatomic, strong) id observedObjectForEnabled;
@property (nonatomic, copy) NSString *observedKeyPathForEnabled;

@property (nonatomic, strong) NSString *purposeDescription;

@end



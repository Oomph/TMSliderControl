//
//  AppController.h
//  TMSliderControl
//
//  Created by Rick Fillion on 01/02/09.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>

@class TMSliderControl;
@class TMSliderControlSmall;

@interface AppController : NSObject {
    IBOutlet TMSliderControl * sliderControl;
    IBOutlet TMSliderControlSmall *smallSliderControl;
}

- (IBAction)sliderChanged:(id)sender;
- (IBAction)smallSliderChanged:(id)sender;

@end

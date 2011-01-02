//
//  AppController.m
//  TMSliderControl
//
//  Created by Rick Fillion on 01/02/09.
//  All code is provided under the New BSD license.
//

#import "AppController.h"
#import "TMSliderControl.h"

@implementation AppController

- (IBAction)sliderChanged:(id)sender
{
    [self willChangeValueForKey:@"onColor"];
    [self didChangeValueForKey:@"onColor"];
}

- (IBAction)smallSliderChanged:(id)sender
{
    NSLog(@"changed");
}

- (NSColor *)onColor
{
    if ([sliderControl state] == NO)
        return [NSColor blackColor];
    return [NSColor blueColor];
}

- (NSColor *)offColor
{
    return [NSColor blackColor];
}

@end

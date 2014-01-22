//
//  AppController.h
//  CMQCBackdrop
//
//  Created by Christopher Wright on 4/23/08.
//  Copyright 2008 Christopher Wright. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AppController : NSObject 
{
	IBOutlet NSWindow	*visWindow;
	IBOutlet QCView				*visView;
}

- (void) applicationWillFinishLaunching:(NSNotification*)notification;
@end

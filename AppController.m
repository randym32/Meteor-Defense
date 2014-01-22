//
//  AppController.m
//  CMQCBackdrop
//
//  Created by Christopher Wright on 4/23/08.
//  Copyright 2008 Christopher Wright. All rights reserved.
//

#import "AppController.h"
#import <OpenGL/CGLMacro.h>

/// This is the players targeting system
extern void targetArtillery(void);


/// These are the variables that define the game
/// This is the position of the artillery, where the player will shoot from.
static double _artillery_x0=0.5;
static double _artillery_y0=0.0;
/// This is the starting position of the meteor that the player will to shoot down.
static double _meteor_x0=1.0;
static double _meteor_y0=1.0;
/// This is the velocity of the meteor that the player will to shoot down.
static double _meteor_v_x=-0.9;
static double _meteor_v_y=-1.5;

/// These are the variables that the player can see
/// This is the position of the artillery, where the player will shoot from.
double artillery_x0;
double artillery_y0;
/// This is the starting position of the meteor that the player will to shoot down.
double meteor_x0;
double meteor_y0;
/// This is the velocity of the meteor that the player will to shoot down.
double meteor_v_x;
double meteor_v_y;


/// This is the velocity and direction of the artillery that the player will fire to shoot down the meteor.
/// These are the variables that the player will to calculate
double artillery_v_x=0.2;
double artillery_v_y=1.0;


/** This is used to copy the game play variables to something that the player can see.
    This is copied to prevent the player from cheating and changing the position of the meteor.
 */
static void copyPlayerStateVariables()
{
    artillery_x0= _artillery_x0;
    artillery_y0= _artillery_y0;
    meteor_v_x  = _meteor_v_x;
    meteor_v_y  = _meteor_v_y;
    meteor_x0   = _meteor_x0;
    meteor_y0   = _meteor_y0;
}


/** This is used to check that artillery and meteor collide at the given time
    @param time  The time to check for collision
    @return zero on no intersection, nonzero if collision
*/
static int intersectsAtTime(double time)
{
    // Calculate the respective positions
    double artillery_x = artillery_x0 + artillery_v_x * time;
    double artillery_y = artillery_y0 + artillery_v_y * time;
    double meteor_x = meteor_x0 + meteor_v_x * time;
    double meteor_y = meteor_y0 + meteor_v_y * time;
    
    // Check that it is on the screen
    if (artillery_y > 1.0 || artillery_y < 0.0 || artillery_x < 0.0 || artillery_x > 1.0
        || meteor_y > 1.0 || meteor_y < 0.0 || meteor_x > 1.0 || meteor_x < 0.0)
        return 0;

    // Calculate the distance
    double dX = meteor_x - artillery_x;
    double dY = meteor_y - artillery_y;
    double r2 = dX*dX + dY*dY;
    
    // check the the threshold for distance
    return r2 < 0.0000001;
}

static double timeOfFoo(double p0, double velocity)
{
    // Check that the velocity is sane
    if (fabs(velocity) < 0.01)
        return -1;
    // look up the time it crosses the zero axis
    // 0 = p0 + velocity*t0
    double t0 = -p0/velocity;
    if (t0 > 0.0)
        return t0;
    // look up the time it crosses the 1 axes
    return (1.0-p0)/velocity;
}


@implementation AppController
/** Close the application when the window is closed
 */
- (void) windowWillClose:(NSNotification*)notification
{
    [[NSApplication sharedApplication] terminate: self];
}
    

- (void) applicationWillFinishLaunching:(NSNotification*)notification
{
	[visView loadCompositionFromFile:
	 [[NSBundle mainBundle] pathForResource:@"Meteor Defense"
                                     ofType:@"qtz"]];
    [visView setMaxRenderingFrameRate:0.0];
    
    // Set up the variables
    copyPlayerStateVariables();
    // Call the player's targeting prcedure
    targetArtillery();
    // Duplicate the variables to prevent player cheating
    copyPlayerStateVariables();
    
    // Calculate the time over intercept
    bool hasIntercept = false;
    double dv_x =  meteor_v_x - artillery_v_x;
    double dv_y =  meteor_v_y - artillery_v_y;
    double dp_x = artillery_x0 - meteor_x0;
    double dp_y = artillery_y0 - meteor_y0;
    double tx=-1.0;
    if (dv_x != 0.0)
    {
        // Calculate the intersection time at the x coord
        tx = dp_x / dv_x;
        if (tx > 0.0 && intersectsAtTime(tx))
        {
            // The time of intercept works out
            hasIntercept = true;
        }
        else if (dv_y != 0.0)
        {
            double ty= dp_y / dv_y;
            if (ty > 0.0 && intersectsAtTime(ty))
            {
                // The time of intercept works out
                tx = ty;
                hasIntercept = true;
            }
        }
    }
    else if (dv_y != 0.0)
    {
        double ty= dp_y / dv_y;
        if (ty > 0.0 && intersectsAtTime(ty))
        {
            // The time of intercept works out
            tx = ty;
            hasIntercept = true;
        }
    }
    
    // Rescale the velocity for full transit
    double timeRescale = 1.0;
    if (hasIntercept)
    {
        // The velocity is so that we reach the intercept point  at time of 1
        timeRescale = 1.0/tx;
        timeRescale /= 4.0;
    }
    else
    {
        // The velocity is the time to transit from one side to the other of the screen
        double time_meteor_x = timeOfFoo(meteor_x0, meteor_v_x);
        double time_meteor_y = timeOfFoo(meteor_y0, meteor_v_y);
        double time_artillery_x= timeOfFoo(artillery_x0, artillery_v_x);
        double time_artillery_y= timeOfFoo(artillery_y0, artillery_v_y);
        double minT = time_meteor_x;
        if (minT < 0.0 || (time_meteor_y > 0.0 && time_meteor_y < minT))
            minT = time_meteor_y;
        if (minT < 0.0 || (time_artillery_x >0.0 && time_artillery_x < minT))
            minT = time_artillery_x;
        if (minT < 0.0 || (time_artillery_y >0.0 && time_artillery_y < minT))
            minT = time_artillery_y;
        if (minT < 0.5) minT = 0.5;
        timeRescale = 1.0/minT;
        timeRescale /= 3.0;
    }
    // Rescale the velocity
    meteor_v_x *= timeRescale;
    meteor_v_y *= timeRescale;
    artillery_v_x*= timeRescale;
    artillery_v_y*= timeRescale;
    
    [visView setValue: [NSNumber numberWithInt: hasIntercept ? 1:0]
          forInputKey: @"Hit"];
    [visView setValue: [NSNumber numberWithDouble: meteor_x0]
          forInputKey: @"meteor_x0"];
    [visView setValue: [NSNumber numberWithDouble: meteor_y0]
          forInputKey: @"meteor_y0"];
    [visView setValue: [NSNumber numberWithDouble: meteor_v_x]
          forInputKey: @"meteor_v_x"];
    [visView setValue: [NSNumber numberWithDouble: meteor_v_y]
          forInputKey: @"meteor_v_y"];
    [visView setValue: [NSNumber numberWithDouble: artillery_x0]
          forInputKey: @"artillery_x0"];
    [visView setValue: [NSNumber numberWithDouble: artillery_y0]
          forInputKey: @"artillery_y0"];
    [visView setValue: [NSNumber numberWithDouble: artillery_v_x]
          forInputKey: @"artillery_v_x"];
    [visView setValue: [NSNumber numberWithDouble: artillery_v_y]
          forInputKey: @"artillery_v_y"];
	[visView startRendering];

	// hide the cursor
	//CGDisplayHideCursor (kCGDirectMainDisplay);
}

@end

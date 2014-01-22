//
//  ArtilleryTargeting.c
//  Meteor Defense
//
//  Created by Randall Maas on 1/21/14.
//
//

/** This is the only file that you are allowed to modify*/

#include <stdio.h>
#include <math.h>

/// This is the position of the artillery, where you will shoot from.
/// You can not modify it.
extern const double artillery_x0;
extern const double artillery_y0;
/// This is the starting position of the meteor that you are to shoot down.
/// You can not modify it.
extern const double meteor_x0;
extern const double meteor_y0;
/// This is the velocity of the meteor that you are to shoot down.
/// You can not modify it.
extern const double meteor_v_x;
extern const double meteor_v_y;


/// This is the velocity and direction of the artillery you will fire to shoot down the meteor.
/// These are the variables that your are to calculate
extern double artillery_v_x;
extern double artillery_v_y;

/** This is the procedure that you customize to shoot stuff down.
    Your objective is to compute an artillery velocity that hits the meteor.
 */
void targetArtillery()
{
    // choose the artillery velocity.
    // This is just a dumb example
    artillery_v_x= 0.5;
    artillery_v_y= 0.5;
}
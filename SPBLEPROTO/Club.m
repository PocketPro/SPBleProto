//
//  Club.m
//  SkyProKit
//
//  Created by Gord Parke on 8/14/13.
//  Copyright (c) 2013 Gord Parke. All rights reserved.
//

#import "Club.h"

@implementation Club

// Simple club copy method
+ (Club *)clubWithClub:(Club *)club
{
    Club *newClub = [[Club alloc] init];
    newClub.name = club.name;
    newClub.type = club.type;
    newClub.loftNumber = club.loftNumber;
    newClub.length = club.length;
    newClub.manufacturedLieAngle = club.manufacturedLieAngle;
    newClub.manufacturedLoftAngle = club.manufacturedLoftAngle;
    newClub.centerFaceOffsetX = club.centerFaceOffsetX;
    newClub.centerFaceOffsetZ = club.centerFaceOffsetZ;
    newClub.leadingEdgeOffsetY = club.leadingEdgeOffsetY;
    return newClub;
}
@end

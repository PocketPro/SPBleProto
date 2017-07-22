//
//  Club.h
//  SkyProKit
//
//  Created by Gord Parke on 8/14/13.
//  Copyright (c) 2013 Gord Parke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkyProKit.h"

@interface Club : NSObject <PPClubForCalibrationProtocol>
 
// Should be set at creation
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * type;       // Of type PPCalibrationClubType
@property (nonatomic, strong) NSNumber * loftNumber; // 3 for 3 iron, 4 for 4 wood, 10 for PW, etc.
@property (nonatomic, strong) NSNumber * length;
@property (nonatomic, strong) NSNumber * manufacturedLoftAngle;
@property (nonatomic, strong) NSNumber * manufacturedLieAngle;
@property (nonatomic, strong) NSNumber * centerFaceOffsetX;
@property (nonatomic, strong) NSNumber * leadingEdgeOffsetY;
@property (nonatomic, strong) NSNumber * centerFaceOffsetZ;

// For PPCalibrationController use only
@property (nonatomic, strong) NSNumber * calibrationMean;
@property (nonatomic, strong) NSNumber * calibrationVariance;
@property (nonatomic, strong) NSNumber * calibrationCount;

// Returns an autoreleased copy of the club
+ (Club *)clubWithClub:(Club *)club;
@end

//
//  Satellite.h
//  SkyProKit
//
//  Created by Gord Parke on 8/14/13.
//  Copyright (c) 2013 Gord Parke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkyProKit.h"

@interface Satellite : NSObject <PPSatelliteProtocol>
@property (nonatomic, strong) NSNumber * versionMajor;
@property (nonatomic, strong) NSNumber * untransferredSwingCount;
@property (nonatomic, strong) NSNumber * versionMinor;
@property (nonatomic, strong) NSString * hardwareID;
@property (nonatomic, strong) NSNumber * isConnected;
@property (nonatomic, strong) NSNumber * batteryMillivolts;
@property (nonatomic, strong) NSNumber * batteryVeryLow;
@property (nonatomic, strong) NSNumber * chargerStatus;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSDate   * lastConnectionDate;
@property (nonatomic, strong) NSData   * lastGyroCalibrationData;
@property (nonatomic, strong) NSData   * lastAccelCalibrationData;
@property (nonatomic, strong) NSString * queuedRegistrationInfo;
@property (nonatomic, strong) NSString * registrationInfo;
@property (nonatomic, strong) NSData   * lastFaceNormalCalibration;
@property (nonatomic, strong) NSNumber * hasAskedForRegistration;
@property (nonatomic, strong) NSString * firmwareRevision;
	
// Should be transient
@property (nonatomic) BOOL batteryBelowPowerDownLevel;
@property (nonatomic, strong) NSDictionary * accelCalibrationUpdateDictionary;


@end

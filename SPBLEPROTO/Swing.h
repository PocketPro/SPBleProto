//
//  Swing.h
//  SkyProKit
//
//  Created by Gord Parke on 8/14/13.
//  Copyright (c) 2013 Gord Parke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkyProKit.h"

@class Club;
@class Satellite;

@interface Swing : NSObject <SP3DSwingProtocol>
@property (nonatomic, strong) NSData *rawSwingData;               /*< Contains the raw swing data transferred from the satellite */
@property (nonatomic, strong) Club *club;                         /*< The club used for this swing (we need its length, loft, etc.) */
@property (nonatomic, strong) Satellite *satellite;               /*< The satellite used for this swing (we need its version, etc.) */

@property (nonatomic, getter = isTransferring) BOOL transferring; /*< A flag to mark whether the data is currently being transferred */
@property (nonatomic, strong) NSDate *date;                       /*< The date the swing was taken */

/**
 The GolfswingKit handle for this swing, used to retrieve information from the GolfSwingKit
 about this swing. Accessing this property will automatically call -processSwingData if necessary.
 */
@property (nonatomic, readonly) void *handle;
@property (nonatomic, getter = isLeftHanded) BOOL leftHanded;


@property (nonatomic, readonly, getter = isValid) BOOL valid;     /*< True if the swing reconstruction was successful, false otherwise. */
@property (nonatomic, strong, readonly) NSError *error;           /*< Filled out if the swing recontruction fails. Nil if successful. */

/**
 Proceses rawSwingData with the GolfSwingKit and modifies handle property accordingly.  If this 
 method fails, handle is set to nil and valid to NO.
 @return YES on success, otherwise NO
 */
- (BOOL)processSwingData;


/*** Storage necessary to conform to SP3DSwingProtocol ***/
@property (nonatomic, strong) NSArray *timeSnapPoints;
@end

//
//  AppDelegate.m
//  SPBLEPROTO
//
//  Created by Gord Parke on 6/27/16.
//  Copyright © 2016 Gord Parke. All rights reserved.
//

#import "AppDelegate.h"
#import "SkyProKit.h"

#import "Satellite.h"
#import "Club.h"
#import "Swing.h"

@interface AppDelegate () <SatelliteManagerDelegate, SatelliteManagerDataSource, SatelliteManagerTransferDataSource, SatelliteManagerClubCalibrationCoordinator, PPCalibrationControllerDataSource, PPCalibrationControllerDelegate>

@property (nonatomic, strong) NSArray *clubs;
@property (nonatomic, weak) Club *currentClub;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Create & configure Satellite Manager
    PPSatelliteManager *manager = [PPSatelliteManager sharedManager];
    [manager setDelegate:self];
    [manager setDataSource:self];
    [manager setTransferDataSource:self];
    [manager setClubCalibrationCoordinator:self];
    [manager setSensorCalibrationCoordinator:[SPSensorCalibrator sharedCalibrator]];
    
    // Optionally add a simulated device (or two)...
     [manager addSimulatedSession];
    
    // Start the manager listening for connected devices to manage
    [manager startListening];
    
    // Specify that we will be using OpenGL ES 2.0
    [[EAGLContextManager sharedManager] setCurrentAPI:kEAGLRenderingAPIOpenGLES2];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "ppg.SPBLEPROTO" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SPBLEPROTO" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SPBLEPROTO.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Satellite Manager Delegate
// The SatelliteManagerDelegate recieves messages from the SatelliteManager that notify it of various events.  These events can include a connecting sensor, a new swing taken, a change in battery level, etc.  The methods below show all the various events that can be received; they are optional in the SAtelliteManagerDelegate, but we've listed them all out in the SampleApp for demonstration purposes.

// Many of these events require user interaction. For example, if a sensor connects that has not been calibration, a typical SkyProKit app presents an alert dialog to the user asking him to calibrate his club. To reduce the amount of development effort, we have implemented default handlers for most, if not all, events in a singleton called PPEventNotificationManager. Usage of this class is shown in the methods below.  We recommend you start out by following this pattern; if you want to make UI customizations in the future, you can replace the message to PPEventNotificationManager with custom code.

- (void)satelliteManagerAddedConnectedSession:(PPSatelliteSession *)session
{
    [[PPEventNotificationManager sharedManager] satelliteManagerAddedConnectedSession:session];
}

- (void)satelliteManagerRemovedConnectedSession:(PPSatelliteSession *)session
{
    [[PPEventNotificationManager sharedManager] satelliteManagerRemovedConnectedSession:session];
}

- (void)satelliteManagerCurrentSessionDidChangeTo:(PPSatelliteSession *)newSession from:(PPSatelliteSession *)oldSession
{
    [[PPEventNotificationManager sharedManager] satelliteManagerCurrentSessionDidChangeTo:newSession from:oldSession];
}

- (void)satelliteManagerNoClubCalibrationForNewlyConnectedSatellite:(id <PPSatelliteProtocol>)satellite
{
    [[PPEventNotificationManager sharedManager] satelliteManagerNoClubCalibrationForNewlyConnectedSatellite:satellite];
}

- (void)satelliteManagerClubCalibrationStartedForSatellite:(id <PPSatelliteProtocol>)satellite
{
    [[PPEventNotificationManager sharedManager] satelliteManagerClubCalibrationStartedForSatellite:satellite];
}

- (void)satelliteManagerClubCalibrationFailedWithError:(NSError *)error forSatellite:(id <PPSatelliteProtocol>)satellite
{
    [[PPEventNotificationManager sharedManager] satelliteManagerClubCalibrationFailedWithError:error forSatellite:satellite];
}

- (void)satelliteManagerClubCalibrationSuceededForSatellite:(id <PPSatelliteProtocol>)satellite
{
    [[PPEventNotificationManager sharedManager] satelliteManagerClubCalibrationSuceededForSatellite:satellite];
}

- (void)satelliteManagerOffClubDetectedForSatellite:(id <PPSatelliteProtocol>)satellite;
{
    [[PPEventNotificationManager sharedManager] satelliteManagerOffClubDetectedForSatellite:satellite];
}

- (void)satelliteManagerBatteryUpdate:(NSNumber *)batteryFraction forSatellite:(id<PPSatelliteProtocol>)satellite
{
    [[PPEventNotificationManager sharedManager] satelliteManagerBatteryUpdate:batteryFraction forSatellite:satellite];
}

- (void)satelliteManagerSwingCountUpdate:(NSUInteger)count forSatellite:(id<PPSatelliteProtocol>)satellite
{
    [[PPEventNotificationManager sharedManager] satelliteManagerSwingCountUpdate:count forSatellite:satellite withCurrentClub:self.currentClub];
}

- (void)satelliteManagerError:(NSError *)error ForSatellite:(id<PPSatelliteProtocol>)satellite
{
    [[PPEventNotificationManager sharedManager] satelliteManagerError:error ForSatellite:satellite];
}


#pragma mark Satellite Manager Data Source
- (id <PPSatelliteProtocol>)satelliteForHardwareID:(NSString *)esn
{
    // The Satellite Manager wants a data object to represent a connected satellite
    
    // Since we're not worried about persisting satellites to the filesystem
    // in the sample app, just create and return a new session object. (If we
    // were persisting satellites, we would search for the satellite with this
    // hardware ID, and create a new one if it wasn't found.)
    return [[Satellite alloc] init];
}

#pragma mark Satellite Manager Club Calibration Coordinator
- (id <PPSatelliteClubCalibrationController>)loadClubCalibrationController
{
    // In this method we provide the Satellite Manager with a club calibration controller.
    // This class should handle the calibration of the device on the club:
    // collecting the IMU data, performing the mathematical calculations, and instructing
    // the user through the process.  The Satellite Manager will configure the object returned
    // from this method and respond with a request for us to present it.
    
    // A club calibration controller class comes pre-packaged with the SkyProKit, which is
    // composed of a UINavigationController and set of child view controllers.  It's recommended
    // that you use this class, and optionally customize the appearance via the storyboard.  (If
    // you do decide to customize the appearance, our suggestion is to copy the
    // PPCalibrationStoryboard.storyboard file into your own project's directory, rename it, and
    // then modify it directly - rather than attempt to build a new one from scratch.
    NSString *storyboardName = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"PPCalibrationStoryboard_iPad" : @"PPCalibrationStoryboard";
    UIStoryboard *calibrationControllerStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    PPCalibrationController *calibrationController = [calibrationControllerStoryboard instantiateInitialViewController];
    
    // Set ourselves as the calibration data source. This is required so that the PPCalibrationController
    // can retrieve a set of the clubs included in your app, as well as provide editing information.
    [calibrationController setDataSource:self];
    
    // Set ourselves as the calibration delegate.  This protocol contains some optional methods. In this case,
    // we want to be notified when the calibration compeletes.
    [calibrationController setCalibrationDelegate:self];
    
    // Call this here to skip automatic calibration and just directly to manual alignment
    //    [calibrationController setAutomaticCalibrationDisabled:YES];
    
    return calibrationController;
}

- (void)presentCalibrationController:(id<PPSatelliteClubCalibrationController>)calibrationViewController animated:(BOOL)flag completion:(void (^)(void))completion
{
    // The Satellite Manager wants the calibration controller supplied in 'loadClubCalibrationController:'
    // to be presented to the user.
    
    // In this sample app, we display it modally from the root view controller.
    PPCalibrationController *cvc = (PPCalibrationController *)calibrationViewController;
    [self.window.rootViewController presentViewController:cvc animated:YES completion:nil];
}

- (void)dismissCalibrationController:(id<PPSatelliteClubCalibrationController>)calibrationViewController animated:(BOOL)flag completion:(void (^)(void))completion
{
    // The Satellite Manager wants us to dismiss the view controller presented in presentCalibrationController: animated: completion:
    PPCalibrationController *cvc = (PPCalibrationController *)calibrationViewController;
    [cvc dismissViewControllerAnimated:YES completion:nil];
}

- (void)simulateClubCalibration
{
    // If a simulated sensor is being used for debugging purposes, this method will be called if the user taps "calibrate"
    static Club  *_simulatedClub;
    _simulatedClub = [[self defaultClubs] lastObject]; // We need a strong reference because currentClub is weak.
    self.currentClub = _simulatedClub;
}

#pragma mark Satellite Manager Transfer Data Source
- (id)satelliteManagerNewSwingForTransfer
{
    // The Satellite Manager wants a swing data object to represent a transfer.
    
    // You can set various properties on the swing here, such as the current club or a currently transferring flag.
    Swing *newSwing = [[Swing alloc] init];
    newSwing.transferring = YES;
    return [[Swing alloc] init];
}

- (void)satelliteManagerTransferDiscardSwing:(id)swing
{
    // A notification from the Satellite Manager that a swing returned by 'satelliteManagerNewSwingForTransfer:'
    // should be discarded after a failed transfer
    
    // If, for example, you're using core data to save swings you may want to remove it from the context here.  In this
    // sample app, however, we just provide an empty implementation and let ARC take care of the swing.
}

- (void)satelliteManagerTransferFinalizeSwing:(id)newlyTransferredSwing withData:(NSData *)data
{
    // A notification from the satellite manager that a swing is finished transferring with 'data' as the result.
    
    // Verify we have a current club
    if (!self.currentClub){
        [NSException raise:NSInternalInconsistencyException format:@"Swing taken with no current club. Has the club been calibrated yet?"];
    }
    
    // Verify that our club matches the raw data (we use the SkyProKit's PPClubHelper class to do so).  This checks to see if the current club has the same loft/lie/etc as the club for which the sensor was last calibrated.
    if (![PPClubHelper isClub:self.currentClub validForSwingData:data])
    {
        // In a production app we could loop through all possible clubs and use
        // this method to search for the correct one, but in this sample app we
        // just return the error.
        [NSException raise:NSInternalInconsistencyException format:@"Invalid club for swing. Please try recalibrating your club."];
    }
    
    
    // Update the swing's properties
    Swing *swing = newlyTransferredSwing;
    swing.club = self.currentClub;
    swing.rawSwingData = data;
    swing.satellite = [[[PPSatelliteManager sharedManager] currentSession] satellite];
    swing.transferring = NO;
    
    
    // Process our new swing
    if (NO == [swing processSwingData]){
        // An error ocurred reconstructing the swing.  Find out what it was
        NSError *error = swing.error; // Filled out by 'processSwingData'
        
        // Here we handle this error using a UIAlertView.  This is _not_ a good way to handle these error in a production
        // app. For example, alert views will not automaticaly be dismissed when a new swing comes in. This is a problem
        // becuase a user could take an invalid swing and then a valid swing without looking at the app between shots. Then,
        // when he does look, the alert view will seem to apply to the last swing, even though it was valid. Similarly, alert
        // views are not dismissed when a device disconnects. A better method of handling the error is to display the error
        // direclty in whatever portion of the UI is dedicated to displaying a particular swing (see the SkyPro consumer app
        // for more details).
        [[[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        return;
    }
    
    
    // We can now query the GolfSwingKit using the handle produced by calling -processSwingData.  Do that now to extract
    // the swing date:
    GSUInt32 swingDateSeconds;
    if (GSGetSwingTimestampInSeconds(swing.handle, &swingDateSeconds) == GSSuccess){
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)swingDateSeconds];
        
        /** This timestamp may have two representations:
         the number of seconds from the first instant of 1 January 1970, GMT, or the number of seconds since the boot time
         of the device.  This division arises from the device's lack of an absolute time clock - until the iPhone notifies
         it of the current absolute time, it can only keep relative time from boot.  A simple way to identify which of the
         two representations is currently being used by the timestamp is to compare it to the the timestamp 1312947367. If
         it is later than this time (Aug 9/2011), it is an asolute timestamp, if it is less, it is a relative timestamp.
         */
        swing.date = ([date timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:1312947367]] > 0 ? date : [NSDate date]);
    } else {
        // Couldn't retreive swing date.  Just set it to the current date here
        swing.date = [NSDate date];
    }
}

#pragma mark - PPCalibrationController Data Source
- (NSArray *)faceNormalCalibrationController:(id)controller possibleClubsWithType:(PPCalibrationClubType)type
{
    // The calibration controller wants all possible clubs of a specified calibration type (iron, wood, putter).  It will compare
    // this to its calibration data to find the most likely club, as well as present them as an option to the user.
    
    // In this sample app, our clubs are stored in the "clubs" array - so we just need to filter that array for 'type'
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type == %d", type];
    NSArray *filteredArray = [self.clubs filteredArrayUsingPredicate:typePredicate];
    return filteredArray;
}

- (id <PPClubForCalibrationProtocol>)faceNormalCalibrationController:(id)controller editableCopyOfClub:(id<PPClubForCalibrationProtocol>)club
{
    // The calibration controller wants a copy of a club for editing.  This copy should start with all the same parameters as the original,
    // and modifying it should not affect the original.
    
    // Our sample app's club model has a simple copy function
    return [Club clubWithClub:club];
}

- (void)faceNormalCalibrationController:(id)controller setDefaultParametersOnEditableClub:(id<PPClubForCalibrationProtocol>)club
{
    // This method should restore the DEFAULT parameters of a club given it's type and loft number (as opposed the parameters from the
    // reference club it was originally based off of).  This is to allow a user to reset to default even if they edited the club and
    // forgot what the original numbers were.
    
    // We can re-use the PPClubHelper class that we used to set the properties of the clubs when we first created them.
    [PPClubHelper populateDefaultClubProperties:@[club]];
}

- (void)faceNormalCalibrationController:(id)controller discardEditableClubCopy:(id<PPClubForCalibrationProtocol>)club
{
    // Editing was cancelled.  Discard the modified club copy.
    
    // Since we don't persist data in this simple app, we can just leave this as an empty impelementation and let ARC take care
    // of the club object.
}

- (id <PPClubForCalibrationProtocol>) faceNormalCalibrationController:(id)controller saveEditableCopy:(id<PPClubForCalibrationProtocol>)editedClub ofReferenceClub:(id<PPClubForCalibrationProtocol>)referenceClub
{
    // Editing was saved.  Replace the old reference club with the new editable copy, and return the saved copy.
    // The saved copy is returned because the it may not be the same object in memory as the original editable club
    // (for example, this can happen with child contexts in Core Data)
    
    // In this sample app, that means modifying our clubs property
    NSMutableArray *newClubArray = [NSMutableArray arrayWithArray:self.clubs];
    NSUInteger referenceClubIndex = [newClubArray indexOfObject:referenceClub];
    [newClubArray replaceObjectAtIndex:referenceClubIndex withObject:editedClub];
    self.clubs = [NSArray arrayWithArray:newClubArray];
    return editedClub;
}

#pragma mark - PPCalibrationController Delegate
- (void)faceNormalCalibrationController:(id)controller completedWithSelectedClub:(id <PPClubForCalibrationProtocol>)club clipToBodyMatrix:(Float32 *)mClipTobody
{
    // This method is a notification that calibration is complete, and provides the selected club along with the club coordinate transformation results.
    
    // The results are handled internally, and can usually be ignored, but in this sample app we want to set our current club.
    self.currentClub = club;
}



#pragma mark - Club Creation
- (NSArray *)defaultClubs
{
    // In this method we create clubs by setting the type (wood, iron, putter) and loft number ('3' in 3 wood),
    // and then using the PPClubHelper class to set the default parameters (lie, lenth, loft, etc.)
    NSMutableArray *newClubArray = [NSMutableArray arrayWithCapacity:15];
    
    // Create irons
    for (int i = 1; i < 14; ++i){
        Club *club = [[Club alloc] init];
        club.type = @(PPCalibrationClubTypeIron);
        club.loftNumber = @(i);
        
        // Set name
        switch (i) {
            case 10: club.name = @"Pitching Wedge";
                break;
                
            case 11: club.name = @"Gap Wedge";
                break;
                
            case 12: club.name = @"Sand Wedge";
                break;
                
            case 13:  club.name = @"Lob Wedge";
                break;
                
            default:  club.name = [NSString stringWithFormat:@"%d Iron", i];
                break;
        }
        
        // Add iron to array
        [newClubArray addObject:club];
    }
    
    // Create woods
    for (int i = 1; i <= 7; i+=2){
        Club *club = [[Club alloc] init];
        club.type = @(PPCalibrationClubTypeWood);
        club.loftNumber = @(i);
        
        // Set name
        switch (i) {
            case 1: club.name = @"Driver";
                break;
                
            default:  club.name = [NSString stringWithFormat:@"%d Wood", i];
                break;
        }
        
        // Add wood to array
        [newClubArray addObject:club];
    }
    
    
    // Create putter
    {
        Club *club = [[Club alloc] init];
        club.type = @(PPCalibrationClubTypePutter);
        club.loftNumber = @(1);
        club.name = @"Putter";
        
        // Add putter to array
        [newClubArray addObject:club];
    }
    
    // Now use the PPClubHelper class to set the default parameters of these clubs
    [PPClubHelper populateDefaultClubProperties:newClubArray];
    
    return newClubArray;
}


@end

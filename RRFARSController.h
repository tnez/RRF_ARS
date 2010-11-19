////////////////////////////////////////////////////////////
//  RRFARSController.h
//  RRFARS
//  --------------------------------------------------------
//  Author: Travis Nesland
//  Created: 11/8/10
//  Copyright 2010, Residential Research Facility,
//  University of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////
#import <Cocoa/Cocoa.h>
#import <TKUtility/TKUtility.h>

@interface RRFARSController : NSObject <TKComponentBundleLoading> {

  // PROTOCOL MEMBERS //////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////    
  NSDictionary                                                *definition;
  id                                                          delegate;
  NSString                                                    *errorLog;
  IBOutlet NSView                                             *view;

  // ADDITIONAL MEMBERS ////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////
  NSArray                                                     *adjectives;
  TKQuestionSet                                               *questions;
  TKQuestion                                                  *currentQuestion;
  TKTime                                                      questionStartTime;
  IBOutlet NSMatrix                                           *radioButtons;
  NSInteger                                                   selectionIdx;
}

// PROTOCOL PROPERTIES ///////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
@property (assign)            NSDictionary                    *definition;
@property (assign)            id <TKComponentBundleLoading>   delegate;
@property (nonatomic, retain) NSString                        *errorLog;
@property (assign)            IBOutlet NSView                 *view;

// ADDITIONAL PROPERTIES /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
@property (nonatomic, retain) TKQuestion                      *currentQuestion;
@property (assign)            IBOutlet NSMatrix               *radioButtons;
@property (assign)            NSInteger                       selectionIdx;

#pragma mark REQUIRED PROTOCOL METHODS

/**
   Start the component - will receive this message from the component controller
*/
- (void)begin;

/**
   Return a string representation of the data directory
*/
- (NSString *)dataDirectory;

/**
   Return a string object representing all current errors in log form
*/
- (NSString *)errorLog;

/**
   Perform any and all error checking required by the component - return YES if
   passed
*/
- (BOOL)isClearedToBegin;

/**
   Returns the file name containing the raw data that will be appended to the
   data file
*/
- (NSString *)rawDataFile;

/**
   Perform actions required to recover from crash using the given raw data
   passed as string
*/
- (void)recover;

/**
   Accept assignment for the component definition
*/
- (void)setDefinition: (NSDictionary *)aDictionary;

/**
   Accept assignment for the component delegate - The component controller will
   assign itself as the delegate
   Note: The new delegate must adopt the TKComponentBundleDelegate protocol
*/
- (void)setDelegate: (id <TKComponentBundleDelegate> )aDelegate;

/**
   Perform any and all initialization required by component - load any nib files
   and perform all required initialization
*/
- (void)setup;

/**
   Return YES if component should perform recovery actions
*/
- (BOOL)shouldRecover;

/**
   Return the name for the current task
*/
- (NSString *)taskName;

/**
   Perform any and all finalization required by component
*/
- (void)tearDown;

/**
   Return the main view that should be presented to the subject
*/
- (NSView *)mainView;

#pragma mark OPTIONAL PROTOCOL METHODS
// UNCOMMENT ANY OF THE FOLLOWING METHODS IF THEIR BEHAVIOR IS DESIRED //
/////////////////////////////////////////////////////////////////////////

/**
   Run header if something other than default is required
*/
//- (NSString *)runHeader;

/**
   Session header if something other than default is required
*/
//- (NSString *)sessionHeader;

/**
   Summary data if desired
*/
//- (NSString *)summary;

#pragma mark ADDITIONAL METHODS
// PLACE ANY NON-PROTOCOL METHODS HERE
/////////////////////////////////////////

/**
   Add the error to an ongoing error log
*/
- (void)registerError: (NSString *)theError;

/**
   Log the response of the subject
*/
- (void)logSubjectResponse: (NSInteger)response;

/**
   Present the next question to the subject
*/
- (void)nextQuestion;

/**
   Handle the subject responses
*/
- (IBAction)subjectDidRespond: (id)sender;

/**
   Adjectives
*/
- (NSString *)adjective: (NSUInteger)idx;

#pragma mark Preference Keys
// HERE YOU DEFINE KEY REFERENCES FOR ANY PREFERENCE VALUES
// ex: extern NSString * const RRFARSNameOfPreferenceKey;
///////////////////////////////////////////////////////////
extern NSString * const RRFARSTaskNameKey;
extern NSString * const RRFARSDataDirectoryKey;
extern NSString * const RRFARSQuestionFileKey;
extern NSString * const RRFARSQuestionAccessMethodKey;
extern NSString * const RRFARSRatingsStartAtZeroKey;
extern NSString * const RRFARSAdjective0Key;
extern NSString * const RRFARSAdjective1Key;
extern NSString * const RRFARSAdjective2Key;
extern NSString * const RRFARSAdjective3Key;
extern NSString * const RRFARSAdjective4Key;

#pragma mark Internal Strings
// HERE YOU DEFINE KEYS FOR CONSTANT STRINGS
////////////////////////////////////////////
extern NSString * const RRFARSMainNibNameKey;

#pragma mark Enumerated Values
// HERE YOU CAN DEFINE ENUMERATED VALUES
// ex:
// enum {
//  RRFARSSomeDescriptor          = 0,
//  RRFARSSomeOtherDescriptor     = 1,
//  RRFARSAnotherDescriptor       = 2
// }; typedef NSInteger RRFARSBlanketDescriptor;

@end

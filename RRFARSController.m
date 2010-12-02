////////////////////////////////////////////////////////////
//  RRFARSController.m
//  RRFARS
//  --------------------------------------------------------
//  Author: Travis Nesland
//  Created: 11/8/10
//  Copyright 2010, Residential Research Facility,
//  University of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////
#import "RRFARSController.h"

// definitions to manage keys
/////////////////////////////
#define QUESTION_FILE [[definition valueForKey:RRFARSQuestionFileKey] stringByStandardizingPath]
#define QUESTION_ACCESS_MODE [[definition valueForKey:RRFARSQuestionAccessMethodKey] unsignedIntegerValue]
#define RATINGS_SHOULD_START_AT_ZERO [[definition valueForKey:RRFARSRatingsStartAtZeroKey] boolValue]
#define ADJECTIVE_0 [definition valueForKey:RRFARSAdjective0Key]
#define ADJECTIVE_1 [definition valueForKey:RRFARSAdjective1Key]
#define ADJECTIVE_2 [definition valueForKey:RRFARSAdjective2Key]
#define ADJECTIVE_3 [definition valueForKey:RRFARSAdjective3Key]
#define ADJECTIVE_4 [definition valueForKey:RRFARSAdjective4Key]

// helper definitions
/////////////////////
#define TKLogError(fmt, ...) [self registerError:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]
#define TKLogToTemp(fmt, ...) [delegate logStringToDefaultTempFile:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]
#define CURRENT_QUESTION_IS_INVERTED [[[currentQuestion additionalFields] objectAtIndex:0] isEqualToString:@"-1"]

@implementation RRFARSController

// add any member that has a property
@synthesize delegate,definition,errorLog,view,currentQuestion,selectionIdx,
            radioButtons;

#pragma mark HOUSEKEEPING METHODS
/**
 Give back any memory that may have been allocated by this bundle
 */
- (void)dealloc {
    [errorLog release];
    // any additional release calls go here
    // ------------------------------------
    [questions release];
    [currentQuestion release];
    [super dealloc];
}

#pragma mark REQUIRED PROTOCOL METHODS

/**
 Start the component - will receive this message from the component controller
 */
- (void)begin {
  // load the next question
  [self nextQuestion];
}

/**
 Return a string representation of the data directory
 */
- (NSString *)dataDirectory {
    return [[definition valueForKey:RRFARSDataDirectoryKey]
            stringByStandardizingPath];
}

/**
 Return a string object representing all current errors in log form
 */
- (NSString *)errorLog {
    return errorLog;
}

/**
 Perform any and all error checking required by the component - return YES if
 passed
 */
- (BOOL)isClearedToBegin {
  // we are cleared to begin if the error log is empty
  return ((errorLog == nil) || [errorLog isEqualToString:@""]);
}

/**
 Returns the file name containing the raw data that will be appended to the data
 file
 */
- (NSString *)rawDataFile {
    return [delegate defaultTempFile]; // this is the default implementation
}

/**
 Perform actions required to recover from crash using the given raw data passed
 as string
 */
- (void)recover {
    // if no recovery is needed, nothing need be done here
}

/**
 Accept assignment for the component definition
 */
- (void)setDefinition: (NSDictionary *)aDictionary {
    definition = aDictionary;
}

/**
 Accept assignment for the component delegate - The component controller will
 assign itself as the delegate
 Note: The new delegate must adopt the TKComponentBundleDelegate protocol
 */
- (void)setDelegate: (id <TKComponentBundleDelegate> )aDelegate {
    delegate = aDelegate;
}

/**
 Perform any and all initialization required by component - load any nib files
 and perform all required initialization
 */
- (void)setup {

    // CLEAR ERROR LOG
    //////////////////
    [self setErrorLog:@""];
    
    // --- WHAT NEEDS TO BE INITIALIZED BEFORE THIS COMPONENT CAN OPERATE? ---
    ///////////////////////////////////////////////////////////////////////////
    //// ADJECTIVES:
    // create the adjective list
    adjectives = [[NSArray alloc] initWithObjects:
                                        ADJECTIVE_0,
                                        ADJECTIVE_1,
                                        ADJECTIVE_2,
                                        ADJECTIVE_3,
                                        ADJECTIVE_4, nil];

    // if there are any blank adjectives...
    if([adjectives count]!=5) {
      TKLogError(@"Invalid adjectives exist");
    }
    // set selection idx to our gaurd value
    selectionIdx = -1;

    ///// QUESTIONS:
    // read the question file
    questions = [[TKQuestionSet alloc]
                 initFromFile:QUESTION_FILE
                 usingAccessMethod:QUESTION_ACCESS_MODE];
    // log error if there was a problem loading the questions
    if(!questions) {
      // log the issue
      TKLogError(@"Could not load questions from: %@",QUESTION_FILE);
    }
    // check that we aren't trying to use random w/ replacement because we do
    // not yet support this
    if([questions accessMethod] == TKQuestionSetRandomWithRepeat) {
      TKLogError(@"We do not yet support Random Selection With Replacement");
    }
    
    //// NIB:
    if([NSBundle loadNibNamed:RRFARSMainNibNameKey owner:self]) {
        // SETUP THE INTERFACE VALUES
        /////////////////////////////
        // for this particular bundle - everything will be done w/ bindings
    } else { // NIB DID NOT LOAD
      TKLogError(@"Could not load NIB file");
    }
}

/**
 Return YES if component should perform recovery actions
 */
- (BOOL)shouldRecover {
    return NO;  // this is the default; change if needed
}

/**
 Perform any and all finalization required by component
 */
- (void)tearDown {
    // any finalization should be done here:
    // - remove any temporary data files
    // ......
    // - remove the default temp file
    [[NSFileManager defaultManager] removeItemAtPath:
     [[delegate tempDirectory] stringByAppendingPathComponent:
      [delegate defaultTempFile]] error:nil];
}

/**
 Return the name of the current task
 */
- (NSString *)taskName {
    return [definition valueForKey:RRFARSTaskNameKey];
}

/**
 Return the main view that should be presented to the subject
 */
- (NSView *)mainView {
    return view;
}

#pragma mark OPTIONAL PROTOCOL METHODS
/** Uncomment and implement the following methods if desired */
/**
 Run header if something other than default is required
 */
//- (NSString *)runHeader {
//
//}
/**
 Session header if something other than default is required
 */
//- (NSString *)sessionHeader {
//
//}
/**
 Summary data if desired
 */
- (NSString *)summary {
    // provide simple headers for data
    return @"Q_ID:\tRESP:\tTIME:\tQ_TEXT:\n----\t----\t----\t------\n";
}
        
#pragma mark ADDITIONAL METHODS
/** Add additional methods required for operation */
- (void)registerError: (NSString *)theError {
    // append the new error to the error log
    [self setErrorLog:[[errorLog stringByAppendingString:theError]
                       stringByAppendingString:@"\n"]];
}
/** 
    Present the next question to the subject
*/
- (void)nextQuestion {
  // if there is another question left to ask
  if(![questions isEmpty]) {
    // reset the selection
    [self setSelectionIdx:-1];
    // get the next question from the question set
    [self setCurrentQuestion:[questions nextQuestion]];
    // reset latency timer
    questionStartTime = current_time_marker();
    NSLog(@"Question Started: %d.%d",questionStartTime.seconds,
          questionStartTime.microseconds);
  } else { // no more questions
    // we're done
    [delegate componentDidFinish:self];
  }
}

/**
   Log the response of the subject
*/
- (void)logSubjectResponse: (NSInteger)response {
  // get the latency value
  TKTime now = current_time_marker();
  NSLog(@"Question Ended: %d.%d", now.seconds, now.microseconds);
  TKTime latency = time_since(questionStartTime);
  NSLog(@"Latency Reported: %d.%d",latency.seconds,latency.microseconds);
  // if the current question is inverted...
  if(CURRENT_QUESTION_IS_INVERTED) {
    // take the top less the response
    response = 4 - response;
  }
  // offset the value if scale does not start at zero
  if(!RATINGS_SHOULD_START_AT_ZERO) {
    // offset by 1 (only mode until further notice)
    response+=1;
  }
  // log the data
  TKLogToTemp(@"%@\t%d\t%d\t%@",
              [currentQuestion uid],                            // question id
              response,                                         // response
              time_as_milliseconds(latency),                    // latency
              [currentQuestion text]);                          // question text
}

/**
   Handle the subject response
*/
- (IBAction)subjectDidRespond: (id)sender {
  // if the subject has made a selection...
  if(selectionIdx >= 0) {
    NSLog(@"Response: %d",selectionIdx);
    // log the response
    [self logSubjectResponse:selectionIdx];
    // go to the next question
    [self nextQuestion];
  }
  // else no selection was made -- do nothing
}

/**
   Return the adjective represented by the index
*/
- (NSString *)adjective: (NSUInteger)idx {
  // make sure we have a valid idx
  if(0 <= idx <= 4) {
    // return the adjective
    return [adjectives objectAtIndex:idx];
  }
  // otherwise return nil (invalid)
  return nil;
}

#pragma mark Preference Keys
// HERE YOU DEFINE KEY REFERENCES FOR ANY PREFERENCE VALUES
// ex: NSString * const RRFARSNameOfPreferenceKey = @"RRFARSNameOfPreference"
NSString * const RRFARSTaskNameKey = @"RRFARSTaskName";
NSString * const RRFARSDataDirectoryKey = @"RRFARSDataDirectory";
NSString * const RRFARSQuestionFileKey = @"RRFARSQuestionFile";
NSString * const RRFARSQuestionAccessMethodKey = @"RRFARSQuestionAccessMethod";
NSString * const RRFARSRatingsStartAtZeroKey = @"RRFARSRatingsStartAtZero";
NSString * const RRFARSAdjective0Key = @"RRFARSAdjective0";
NSString * const RRFARSAdjective1Key = @"RRFARSAdjective1";
NSString * const RRFARSAdjective2Key = @"RRFARSAdjective2";
NSString * const RRFARSAdjective3Key = @"RRFARSAdjective3";
NSString * const RRFARSAdjective4Key = @"RRFARSAdjective4";

#pragma mark Internal Strings
// HERE YOU DEFINE KEYS FOR CONSTANT STRINGS //
///////////////////////////////////////////////
NSString * const RRFARSMainNibNameKey = @"RRFARSMainNib";
        
@end

//
//  PLVInAppClient.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 08.10.14.
//  Copyright (c) 2014 Payleven. All rights reserved.
//


#import "SingletonHelper.h"
#import "PLVInAppClient.h"
#import "PLVInAppAPIClient.h"
#import "PLVInAppClientTypes.h"
#import "PLVInAppSDKConstants.h"
#import "PLVInAppErrors.h"
#import "PLVPaymentInstrumentValidator.h"
#import "PLVInAppClientTypes+Serialization.h"
#import "DevicePlatform.h"
#import "PLVEventLoggingClient.h"
#import "PLVEventLogger.h"
#import "PLVEvent.h"
#import "OrderedDictionary.h"
#import "PLVCardBrandManager.h"

#define kUserTokenKey @"userToken"
#define kRequestErrorKey @"requestError"
#define kRequestErrorCodeKey @"requestErrorCode"

#define kPaymentInstrumentTypeKey @"paymentInstrumentType"
#define kPaymentInstrumentsKey @"paymentInstruments"

#define kTimeStampKey @"timestamp"
#define kResponseTimeKey @"responseTime"

#define kPaymentInstrumentIdentifierKey @"paymentInstrumentIdentifier"
#define kUseCaseKey @"usecase"
#define kEmailKey @"email"

@interface PLVInAppClient ()

@property (strong) NSString* apiKey;
@property (strong) NSString* bundleID;
@property (strong) NSError* lastError;

/** Serial operation queue. */
@property (nonatomic, strong) NSOperationQueue *queue;

/** loging and cardBrand queue. */
@property (nonatomic, strong) NSOperationQueue *loggingQueue;


/** API client. */
@property (nonatomic, strong) PLVInAppAPIClient *inAppAPIClient;
/** Our event logger */
@property (nonatomic, strong) PLVEventLogger* eventLogger;

@end


@implementation PLVInAppClient

SYNTHESIZE_SINGLETON_FOR_CLASS(PLVInAppClient)

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
        
        SDLog(@"PLVInAppClient created with BundleID: %@",_bundleID);
        
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        _queue.name = NSStringFromClass([self class]);
        _inAppAPIClient = [[PLVInAppAPIClient alloc] initWithQueue:_queue];
        
        
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        _queue.name = NSStringFromClass([self class]);
        
        
        PLVEventLoggingClient *eventLoggingClient = [[PLVEventLoggingClient alloc] initWithQueue:_queue  andDelegate:_inAppAPIClient];
        _eventLogger = [[PLVEventLogger alloc] initWithQueue:_queue
                                          eventLoggingClient:eventLoggingClient
                                                timeInterval:10.0];
        
        
        _loggingQueue = [[NSOperationQueue alloc] init];
        _loggingQueue.maxConcurrentOperationCount = 2;
        _loggingQueue.name = @"loggingQueue";
        
        [[PLVCardBrandManager sharedInstance] setUpWithQueue:_loggingQueue];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.eventLogger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeInitInAPPClient parameters:Nil]];
            
        });
    }
    return self;
}

-(void)dealloc {
    
    [self.eventLogger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeCloseInAPPClient parameters:Nil]];
}

- (void) registerWithAPIKey:(NSString*)apiKey {
    
    assert(apiKey);
    
    [self.inAppAPIClient registerWithAPIKey:apiKey andBundleID:self.bundleID];
    
    self.apiKey = apiKey;
}

/**
 *  registerWithAPIKey:andSpecificBaseServiceURL:
 *
 *  @param apiKey your API Key, and register specific baseServiceURL
 */

- (void) registerWithAPIKey:(NSString*)apiKey andSpecificBaseServiceURL:(NSString*)serviceURLString {
    
    assert(apiKey);
    
    [self.inAppAPIClient registerWithAPIKey:apiKey andBundleID:self.bundleID];
    
    [self.inAppAPIClient setSpecificBaseServiceURL:serviceURLString];
    
    self.apiKey = apiKey;
}


- (void) createUserToken:(NSString*)emailAddress withPaymentInstrument:(PLVPaymentInstrument*)payInstrument useCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self validatePaymentInstrument:payInstrument onCreation:TRUE withCompletion:completionHandler]) { return; }
    
    __block PLVEventLogger* logger = self.eventLogger;
    
    __block NSString* timeStamp = [self.inAppAPIClient getTimeStampAsString];
    
    __block double startTime = [self.inAppAPIClient getTimeStamp];
    
    [self getUserToken:emailAddress withCompletion:^(NSDictionary* response, NSError* error) {
    
        NSDictionary* logParams = [NSDictionary dictionaryWithObjectsAndKeys:emailAddress,kEmailKey,timeStamp,kTimeStampKey,[self getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey,Nil];
        
        if ([response objectForKey:kUserTokenKey] && error == noErr) {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeCreateUserTokenSuccess parameters:logParams]];
            
            [self addPaymentInstrument:payInstrument forUserToken:[response objectForKey:kUserTokenKey] withUseCase:useCase andCompletion:Nil];
            
        } else {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeCreateUserTokenFail parameters:logParams]];
        }
        
        if (completionHandler != Nil) {
            completionHandler(response,error);
        }
        
    }];
}

/**
 *  getUsertoken
 *
 *  @param emailAddress    email Address to get the userToken for
 *  @param completionBlock completionBlock
 */

- (void) getUserToken:(NSString*)emailAddress withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self checkEmailAddress:emailAddress andCompletion:completionHandler]) { return; }
    
    [self.inAppAPIClient userTokenForEmail:emailAddress withCompletion:completionHandler];
}

- (void) addPaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(PLVInAppUserToken*)userToken withUseCase:(NSString*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self checkUserToken:userToken withPI:payInstrument onCreation:YES andCompletion:completionHandler]) { return; }
    
    NSString* useCaseChecked = [self checkUseCase:useCase];
    
    __block PLVEventLogger* logger = self.eventLogger;
    
    __block NSString* timeStamp = [self.inAppAPIClient getTimeStampAsString];
    
    __block double startTime = [self.inAppAPIClient getTimeStamp];
    
    __block PLVInAppClient* selfBlock = self;
    
    [self.inAppAPIClient addPaymentInstrument:payInstrument forUserToken:userToken withUseCase:useCaseChecked andCompletion:^(NSDictionary* response, NSError* error) {
        
        if (error == noErr) {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeAddPaymentInstrumentSuccess parameters:[NSDictionary dictionaryWithObjectsAndKeys:payInstrument.type, kPaymentInstrumentTypeKey, useCase, kUseCaseKey,timeStamp,kTimeStampKey,[selfBlock getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey,Nil]]];

        } else {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeAddPaymentInstrumentFail parameters:[NSDictionary dictionaryWithObjectsAndKeys:userToken, kUserTokenKey, error.localizedDescription, kRequestErrorKey, [NSNumber numberWithLong:error.code], kRequestErrorCodeKey, timeStamp,kTimeStampKey,[selfBlock getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey,Nil]]];
        }

    }];
    
    if (completionHandler != Nil) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // Fake Response for addPaymentInstrument
            
            NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:@"OK",@"status",@"200",@"code", nil];
            
            completionHandler(result,Nil);
        });
        
    }
}

- (void) getPaymentInstrumentsList:(PLVInAppUserToken*)userToken withUseCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self checkUserToken:userToken andCompletion:completionHandler]) { return; }
    
    NSString* useCaseChecked = [self checkUseCase:useCase];
    
    __block PLVEventLogger* logger = self.eventLogger;
    
    __block NSString* timeStamp = [self.inAppAPIClient getTimeStampAsString];
    
    __block double startTime = [self.inAppAPIClient getTimeStamp];
    
    __block PLVInAppClient* selfBlock = self;
    
    [self.inAppAPIClient listPaymentInstrumentsForUserToken:userToken withUseCase:useCaseChecked andCompletion:^(NSDictionary* response, NSError* error) {
        
        if (error == noErr) {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeListPaymentInstrumentsSuccess parameters:[NSDictionary dictionaryWithObjectsAndKeys:userToken, kUserTokenKey, useCase, kUseCaseKey,timeStamp,kTimeStampKey,[selfBlock getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey, Nil]]];
            
        } else {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeListPaymentInstrumentsFail parameters:[NSDictionary dictionaryWithObjectsAndKeys:userToken, kUserTokenKey, error.localizedDescription, kRequestErrorKey, [NSNumber numberWithLong:error.code], kRequestErrorCodeKey,timeStamp,kTimeStampKey,[selfBlock getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey, Nil]]];
        }
        
        if (completionHandler != Nil) {
            completionHandler(response,error);
        }
        
    }];
}

- (void) setPaymentInstrumentsOrder:(NSOrderedSet*)piOrderedSet forUserToken:(PLVInAppUserToken*)userToken  withUseCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    NSString* useCaseChecked = [self checkUseCase:useCase];
    
    // run validation check
    if (![self checkUserToken:userToken withPIAsOrderedSet:piOrderedSet andCompletion:completionHandler]) { return; }
    
    __block PLVEventLogger* logger = self.eventLogger;
    
    __block NSString* timeStamp = [self.inAppAPIClient getTimeStampAsString];
    
    __block double startTime = [self.inAppAPIClient getTimeStamp];
    
    __block PLVInAppClient* selfBlock = self;
    
    [self.inAppAPIClient setPaymentInstrumentsOrder:piOrderedSet forUserToken:userToken withUseCase:useCaseChecked andCompletion:^(NSDictionary* response, NSError* error) {
        
        if (error == noErr) {
            
            NSMutableArray* orderedPIArray = [NSMutableArray new];
            
            [piOrderedSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                
                PLVPaymentInstrument* baseType = (PLVPaymentInstrument*) obj;
                
                if ([baseType isKindOfClass:[PLVPaymentInstrument class]]) {
                    
                    OrderedDictionary* newOrderedItem = [OrderedDictionary new];
                    
                    NSString* piID = [NSString stringWithString:baseType.identifier];
                    
                    if (piID != Nil) {
                        
                        [newOrderedItem setObject:piID forKey:@"identifier"];
                        [newOrderedItem setObject:[NSString stringWithFormat:@"%lu",(unsigned long)idx] forKey:@"sortIndex"];
                        [orderedPIArray addObject:newOrderedItem];
                    }
                }
                
            }];
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeSetPaymentInstrumentsOrderSuccess parameters:[NSDictionary dictionaryWithObjectsAndKeys:userToken, kUserTokenKey, useCase, kUseCaseKey, orderedPIArray,kPaymentInstrumentsKey, timeStamp,kTimeStampKey,[selfBlock getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey,Nil]]];
            
        } else {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeSetPaymentInstrumentsOrderFail parameters:[NSDictionary dictionaryWithObjectsAndKeys:userToken, kUserTokenKey, error.localizedDescription, kRequestErrorKey, [NSNumber numberWithLong:error.code], kRequestErrorCodeKey, timeStamp,kTimeStampKey,[selfBlock getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey,Nil]]];
        }
        
        if (completionHandler != Nil) {
            completionHandler(response,error);
        }
        
    }];
}

- (void) disablePaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(PLVInAppUserToken*)userToken andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self checkUserToken:userToken withPI:payInstrument onCreation:NO andCompletion:completionHandler]) { return; }
    
    __block PLVEventLogger* logger = self.eventLogger;
    
    __block NSString* timeStamp = [self.inAppAPIClient getTimeStampAsString];
    
    __block double startTime = [self.inAppAPIClient getTimeStamp];
    
    __block PLVInAppClient* selfBlock = self;
    
    [self.inAppAPIClient disablePaymentInstrument:payInstrument forUserToken:userToken withCompletion:^(NSDictionary* response, NSError* error) {
        
        if (error == noErr) {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeDisablePaymentInstrumentSuccess parameters:[NSDictionary dictionaryWithObjectsAndKeys:userToken, kUserTokenKey, payInstrument.type, kPaymentInstrumentTypeKey, payInstrument.identifier, kPaymentInstrumentIdentifierKey,timeStamp,kTimeStampKey,[selfBlock getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey,Nil]]];
            
        } else {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeDisablePaymentInstrumentFail parameters:[NSDictionary dictionaryWithObjectsAndKeys:userToken, kUserTokenKey, error.localizedDescription, kRequestErrorKey, [NSNumber numberWithLong:error.code], kRequestErrorCodeKey, timeStamp,kTimeStampKey,[selfBlock getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey,Nil]]];
        }
        
        if (completionHandler != Nil) {
            completionHandler(response,error);
        }
        
    }];
}


- (void) removePaymentInstrument:(PLVPaymentInstrument*)payInstrument fromUseCase:(NSString*)useCase forUserToken:(NSString*)userToken  andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self checkUserToken:userToken withPI:payInstrument onCreation:NO andCompletion:completionHandler]) { return; }
    
    NSString* useCaseChecked = [self checkUseCase:useCase];
    
    __block PLVEventLogger* logger = self.eventLogger;
    
    __block NSString* timeStamp = [self.inAppAPIClient getTimeStampAsString];
    
    __block double startTime = [self.inAppAPIClient getTimeStamp];
    
    __block PLVInAppClient* selfBlock = self;
    
    [self.inAppAPIClient removePaymentInstrument:payInstrument fromUseCase:useCaseChecked forUserToken:userToken withCompletion:^(NSDictionary* response, NSError* error) {
        
        if (error == noErr) {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeRemovePaymentInstrumentSuccess parameters:[NSDictionary dictionaryWithObjectsAndKeys:userToken, kUserTokenKey, useCase, kUseCaseKey, payInstrument.type, kPaymentInstrumentTypeKey, payInstrument.identifier, kPaymentInstrumentIdentifierKey,timeStamp,kTimeStampKey,[selfBlock getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey,Nil]]];
            
        } else {
            
            [logger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeRemovePaymentInstrumentFail parameters:[NSDictionary dictionaryWithObjectsAndKeys:userToken, kUserTokenKey, error.localizedDescription, kRequestErrorKey, [NSNumber numberWithLong:error.code], kRequestErrorCodeKey,timeStamp,kTimeStampKey,[selfBlock getDeltaTimeStringFromStartTimeStamp:startTime],kResponseTimeKey, Nil]]];
        }
        
        if (completionHandler != Nil) {
            completionHandler(response,error);
        }
        
    }];
}

/**
 *  checkUseType
 *
 *  @param useType the useType Value to check
 *
 *  @return TRUE for Valid UseType, FAlse for wrong value
 */

- (NSString*) checkUseCase:(PLVInAppUseCase*)useCase {
    
    if ( useCase != Nil) {
        return useCase;
    }
    
    return @"DEFAULT";
}
/**
 *  checkUserToken withPIAsOrderedSet
 *
 *  Before runing BE communication
 *  Checks for valid API Key and completion Handler
 *  @param piOrderedSet      piOrderedSet to check
 *  @param completionHandler completionHandler to check
 *  @param userToken         userToken to check
 *
 *  @return TRUE for passed Checks, FALSE for failed Checks
 */

- (BOOL) checkUserToken:(NSString*)userToken withPIAsOrderedSet:(NSOrderedSet*)piOrderedSet andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    if([self checkUserToken:userToken andCompletion:completionHandler]) {
        
        if (piOrderedSet != Nil) {
            
            if ([piOrderedSet isKindOfClass:[NSOrderedSet class]]) {
                
                if(piOrderedSet.count > 0) {
                    
                    BOOL allValid = TRUE;
                    
                    for (id item in piOrderedSet) {
                        if (![item isKindOfClass:[PLVPaymentInstrument class]]) {
                            allValid = FALSE;
                        }
                    }
                    
                    self.lastError = Nil;
                    return allValid;
                }
            }
        }
        
        NSError* error = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_MISSING_PAYMENTINSTRUMENTS_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_MISSING_PAYMENTINSTRUMENTS_MESSAGE forKey:NSLocalizedDescriptionKey]];
        self.lastError = error;
        
        completionHandler(nil,error);
    }
    
    return FALSE;
}

/**
 *  checkUserToken withPIAsArray
 *
 *  Before runing BE communication
 *  Checks for valid API Key and completion Handler
 *  @param piArray           piArray to check*
 *  @param completionHandler completionHandler to check
 *  @param userToken         userToken to check
 *
 *  @return TRUE for passed Checks, FALSE for failed Checks
 */

- (BOOL) checkUserToken:(NSString*)userToken withPI:(PLVPaymentInstrument*)paymentInstrument onCreation:(BOOL)validateOnCreation andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    if([self checkUserToken:userToken andCompletion:completionHandler]) {
        
        if ((paymentInstrument != Nil) && [paymentInstrument isKindOfClass:[PLVPaymentInstrument class]]) {
            
                if([self validatePaymentInstrument:paymentInstrument onCreation:validateOnCreation withCompletion:completionHandler]) {
                    return TRUE;
                }
            
            } else {
                
            // Nil PaymentInstrument
        
            NSError* error = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_MISSING_PAYMENTINSTRUMENTS_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_MISSING_PAYMENTINSTRUMENTS_MESSAGE forKey:NSLocalizedDescriptionKey]];
            self.lastError = error;
            
            completionHandler(nil,error);
        }
    }
    
    return FALSE;
}


/**
 *  checkUserToken
 *
 *  Before runing BE communication
 *  Checks for valid API Key and completion Handler
 *
 *  @param completionHandler completionHandler to check
 *  @param emailAddress      email address
 *
 *  @return TRUE for passed Checks, FALSE for failed Checks
 */

- (BOOL) checkUserToken:(NSString*)userToken andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    if ([self checkAPIKeyWithCompletion:completionHandler]) {
        
        if (userToken != Nil) {
            
            if ([userToken isKindOfClass:[NSString class]]) {
                
                if(userToken.length > 0) {
                    self.lastError = Nil;
                    return TRUE;
                }
            }
        }
        
        NSError* error = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_MISSING_USERTOKEN_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_MISSING_USERTOKEN_MESSAGE forKey:NSLocalizedDescriptionKey]];
        self.lastError = error;
        
        completionHandler(nil,error);
        
    }
    
    return FALSE;

}



/**
 *  checkEmailAddress
 *
 *  Before runing BE communication
 *  Checks for email address, API Key and compeltion handler
 *
 *  @param completionHandler completionHandler to check
 *  @param emailAddress      email address
 *
 *  @return TRUE for passed Checks, FALSE for failed Checks
 */

- (BOOL) validatePaymentInstrument:(PLVPaymentInstrument*)pi onCreation:(BOOL)validateOnCreation withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // PI should already tested for class and Nil before
    
    PLVPaymentInstrumentValidator* validator = [PLVPaymentInstrumentValidator validatorForPaymentInstrument:pi];
    
    if (validator == Nil) {
        
        NSError* error = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_PAYMENTINSTRUMENT_VALIDATION_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_PAYMENTINSTRUMENT_VALIDATION_MESSAGE forKey:NSLocalizedDescriptionKey]];
        
        completionHandler(nil,error);
        
        return FALSE;
    }
    
    
    NSArray* validationErrors;
    
    if (validateOnCreation) {
        validationErrors = [validator validateOnCreation];
    } else {
        validationErrors = [validator validateOnUpdate];
    }
    
    if (validationErrors != Nil && validationErrors.count > 0) {

        self.lastError = [validationErrors firstObject];
        
        // validation Errors
        
        NSMutableString* errorMessage = [NSMutableString new];
        
        for (NSError* error in validationErrors) {
            [errorMessage appendString:error.localizedDescription];
            [errorMessage appendString:@"\n"];
        }
        
        NSError* error = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_PAYMENTINSTRUMENT_VALIDATION_CODE userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
        
        completionHandler(nil,error);
        
        return FALSE;
    }

    return TRUE;
}


/**
 *  checkEmailAddress
 *
 *  Before runing BE communication
 *  Checks for email address, API Key and compeltion handler
 *
 *  @param completionHandler completionHandler to check
 *  @param emailAddress      email address
 *
 *  @return TRUE for passed Checks, FALSE for failed Checks
 */

- (BOOL) checkEmailAddress:(NSString*)emailAddress andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    if ([self checkAPIKeyWithCompletion:completionHandler]) {
        
        if (emailAddress != Nil) {
            
            if ([emailAddress isKindOfClass:[NSString class]]) {
                
                if(emailAddress.length > 0) {
                    
                    if ([self stringIsValidEmail:emailAddress]) {
                        self.lastError = Nil;
                        return TRUE;
                    } else {
                        
                        NSError* error = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_INVALID_EMAILADDRESS_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_INVALID_EMAILADDRESS_MESSAGE forKey:NSLocalizedDescriptionKey]];
                        self.lastError = error;
                        
                        completionHandler(nil,error);
                    }

                }
            }
        }
        
        NSError* error = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_MISSING_EMAILADDRESS_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_MISSING_EMAILADDRESS_MESSAGE forKey:NSLocalizedDescriptionKey]];
        self.lastError = error;
        
        completionHandler(nil,error);
        
    }

    return FALSE;
}



/**
 *  checkAPIKeyWithCompletion
 *
 *  Before runing BE communication
 *  Checks for valid API Key and completion Handler
 *
 *  @param completionHandler completionHandler to check
 *
 *  @return TRUE for passed Checks, FALSE for failed Checks
 */

- (BOOL) checkAPIKeyWithCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    if (self.apiKey == Nil) {
        
        NSError* error = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_MISSING_API_KEY_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_MISSING_API_KEY_MESSAGE forKey:NSLocalizedDescriptionKey]];
        self.lastError = error;
        
        if (completionHandler != Nil) {
            completionHandler(nil,error);
        }
        
        return FALSE;
    }
    
    if (completionHandler == Nil) {
        
        NSError* error = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_MISSING_CALLBACK_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_MISSING_CALLBACK_MESSAGE forKey:NSLocalizedDescriptionKey]];
        self.lastError = error;
        
        return FALSE;
    }
    
    self.lastError = Nil;
    
    return TRUE;
}


-(BOOL) stringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(NSString*) getDeltaTimeStringFromStartTimeStamp:(double)startTime {
    
    double now = [[NSDate date] timeIntervalSinceReferenceDate] - startTime;
    
    return [NSString stringWithFormat:@"%0.02lfs",now];
    
}
@end

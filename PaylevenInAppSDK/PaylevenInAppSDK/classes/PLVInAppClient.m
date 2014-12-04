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
#import "PLVInAppClientTypes+Validation.h"
#import "PLVInAppClientTypes+Serialization.h"
#import "DevicePlatform.h"
#import "PLVEventLoggingClient.h"
#import "PLVEventLogger.h"
#import "PLVEvent.h"

#define kUserTokenKey @"userToken"

@interface PLVInAppClient ()

@property (strong) NSString* apiKey;
@property (strong) NSString* bundleID;
@property (strong) NSError* lastError;


/** Serial operation queue. */
@property (nonatomic, strong) NSOperationQueue *queue;

/** API client. */
@property (nonatomic, strong) PLVInAppAPIClient *inAppAPIClient;

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
        
        PLVEventLoggingClient *eventLoggingClient = [[PLVEventLoggingClient alloc] initWithQueue:_queue  andDelegate:_inAppAPIClient];
        _eventLogger = [[PLVEventLogger alloc] initWithQueue:_queue
                                          eventLoggingClient:eventLoggingClient
                                                timeInterval:10.0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.eventLogger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeInitInAPPClient parameters:Nil]];
            
        });
        
        
    }
    return self;
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
    
    [self getUserToken:emailAddress withCompletion:^(NSDictionary* response, NSError* error) {
    
        if ([response objectForKey:kUserTokenKey] && error == noErr) {
            
            [self.eventLogger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeCreateUserTokenSuccess parameters:[NSDictionary dictionaryWithObject:emailAddress forKey:@"email"]]];
            
            [self addPaymentInstrument:payInstrument forUserToken:[response objectForKey:kUserTokenKey] withUseCase:useCase andCompletion:^(NSDictionary* response, NSError* error) {
                
            }];
        } else {
            
            [self.eventLogger logEvent:[PLVEvent eventForNowWithType:PLVEventTypeCreateUserTokenFail parameters:[NSDictionary dictionaryWithObject:emailAddress forKey:@"email"]]];
        }
        
        if (completionHandler != Nil) {
            completionHandler(response,error);
        }
        
    }];
}

- (void) getUserToken:(NSString*)emailAddress withCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self checkEmailAddress:emailAddress andCompletion:completionHandler]) { return; }
    
    [self.inAppAPIClient userTokenForEmail:emailAddress withCompletion:completionHandler];
}

- (void) addPaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(PLVInAppUserToken*)userToken withUseCase:(NSString*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self checkUserToken:userToken withPI:payInstrument onCreation:YES andCompletion:completionHandler]) { return; }
    
    NSString* useCaseChecked = [self checkUseCase:useCase];
    
    [self.inAppAPIClient addPaymentInstrument:payInstrument forUserToken:userToken withUseCase:useCaseChecked andCompletion:completionHandler];
}

- (void) getPaymentInstrumentsList:(PLVInAppUserToken*)userToken withUseCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self checkUserToken:userToken andCompletion:completionHandler]) { return; }
    
    NSString* useCaseChecked = [self checkUseCase:useCase];
    
    [self.inAppAPIClient listPaymentInstrumentsForUserToken:userToken withUseCase:useCaseChecked andCompletion:completionHandler];
}

- (void) setPaymentInstrumentsOrder:(NSOrderedSet*)piOrderedSet forUserToken:(PLVInAppUserToken*)userToken  withUseCase:(PLVInAppUseCase*)useCase andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    NSString* useCaseChecked = [self checkUseCase:useCase];
    
    // run validation check
    if (![self checkUserToken:userToken withPIAsOrderedSet:piOrderedSet andCompletion:completionHandler]) { return; }
    
    [self.inAppAPIClient setPaymentInstrumentsOrder:piOrderedSet forUserToken:userToken withUseCase:useCaseChecked andCompletion:completionHandler];
}

- (void) disablePaymentInstrument:(PLVPaymentInstrument*)payInstrument forUserToken:(PLVInAppUserToken*)userToken andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self checkUserToken:userToken withPI:payInstrument onCreation:NO andCompletion:completionHandler]) { return; }
    
    [self.inAppAPIClient disablePaymentInstrument:payInstrument forUserToken:userToken withCompletion:completionHandler];
}


- (void) removePaymentInstrument:(PLVPaymentInstrument*)payInstrument fromUseCase:(NSString*)useCase forUserToken:(NSString*)userToken  andCompletion:(PLVInAppAPIClientCompletionHandler)completionHandler {
    
    // run validation check
    if (![self checkUserToken:userToken withPI:payInstrument onCreation:NO andCompletion:completionHandler]) { return; }
    
    NSString* useCaseChecked = [self checkUseCase:useCase];
    
    [self.inAppAPIClient removePaymentInstrument:payInstrument fromUseCase:useCaseChecked forUserToken:userToken withCompletion:completionHandler];
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
    
    NSError* validationError;
    
    if (validateOnCreation) {
        validationError = [pi validateOnCreation];
    } else {
        validationError = [pi validateOnUpdate];
    }
    
    if (validationError != Nil) {

        self.lastError = validationError;
        
        completionHandler(nil,validationError);
        
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

@end

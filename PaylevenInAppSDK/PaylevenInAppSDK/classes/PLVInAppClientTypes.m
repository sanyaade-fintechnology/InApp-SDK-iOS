//
//  PLVInAppClientTypes.m
//  PaylevenInAppSDK
//
//  Created by ploenne on 30.10.14.
//  Copyright (c) 2014 payleven. All rights reserved.
//

#define     PLVPITypeUnknown    @"PLVPITypeUnknown"

#import "PLVInAppClientTypes.h"
#import "PLVInAppSDKConstants.h"
#import "PLVPaymentInstrumentValidator.h"
#import "PLVInAppErrors.h"

typedef NSString PLVPIType;

typedef enum : NSUInteger {
    PLVPICCTypeUnknown = 0,
    PLVPICCTypeVISA,
    PLVPICCTypeVISA_ELECTRON,
    PLVPICCTypeVPAY,
    PLVPICCTypeAMEX,
    PLVPICCTypeDINERS,
    PLVPICCTypeOTHER
} PLVPICCType;


@interface PLVPaymentInstrument()

@property (readwrite) NSString* sortIndex;
@property (readwrite) NSString* identifier;
@property (readwrite) NSString* type;

@end


@interface PLVPayInstrumentCC ()

- (id)initWithPan:(NSString*)pan expiryMonth:(NSInteger)expiryMonth expiryYear:(NSInteger)expiryYear cvv:(NSString*)cvv andCardHolder:(NSString*)cardHolder;

@end


@implementation PLVPayInstrumentCC

+ (BOOL) validatePan:(NSString*)pan withError:(NSError **)error{
    
    PLVPayInstrumentCCValidator* validator = [[PLVPayInstrumentCCValidator alloc] init];
    
    NSError* panError = [validator validatePAN:pan];
    
    if (error != Nil) {
        *error = panError;
    }
    
    return (panError == Nil);
}


+ (BOOL) validateExpiryMonth:(NSInteger)month andYear:(NSInteger)year withError:(NSError **)error {
    
    PLVPayInstrumentCCValidator* validator = [[PLVPayInstrumentCCValidator alloc] init];
    
    NSError* dateError = [validator validateExpiryMonth:month andYear:year];
    
    if (error != Nil) {
        *error = dateError;
    }
    
    return (dateError == Nil);
}

+ (BOOL) validateCVV:(NSString*)cvv withError:(NSError **)error {
    
    PLVPayInstrumentCCValidator* validator = [[PLVPayInstrumentCCValidator alloc] init];
    
    NSError* cvvError = [validator validateCVV:cvv];
    
    if (error != Nil) {
        *error = cvvError;
    }
    
    return (cvvError == Nil);
}

+ (BOOL) validateCardHolder:(NSString*)cardHolder withError:(NSError **)error {
    
    PLVPayInstrumentCCValidator* validator = [[PLVPayInstrumentCCValidator alloc] init];
    
    NSError* cardHolderError = [validator validateCardHolder:cardHolder];
    
    if (error != Nil) {
        *error = cardHolderError;
    }
    
    return (cardHolderError == Nil);
}


- (id)initWithPan:(NSString*)pan expiryMonth:(NSInteger)expiryMonth expiryYear:(NSInteger)expiryYear cvv:(NSString*)cvv andCardHolder:(NSString*)cardHolder
{
    self = [super init];
    
    if (self) {
        self.type = PLVPITypeCC;
        
        NSArray* panParts = [pan componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _pan = [panParts componentsJoinedByString:@""];
        
        _expiryYear = expiryYear;
        _expiryMonth = expiryMonth;
        _cvv = cvv;
        _cardBrand = @"";
        _cardHolder = [cardHolder uppercaseString];
    }

    return self;
}

@end


@interface PLVPayInstrumentDD ()

- (instancetype)initWithAccountNo:(NSString*)accountNo andRoutingNo:(NSString*)routingNo;

@end

@implementation PLVPayInstrumentDD

+ (BOOL) validateAccountNo:(NSString*)accountNo withError:(NSError **)error {
    
    PLVPayInstrumentDDValidator* validator = [[PLVPayInstrumentDDValidator alloc] init];
    
    NSError* accountError = [validator validateAccountNo:accountNo];
    
    if (error != Nil) {
        *error = accountError;
    }
    
    return (accountError == Nil);
}

+ (BOOL) validateRoutingNo:(NSString*)routningNo withError:(NSError **)error {
    
    PLVPayInstrumentDDValidator* validator = [[PLVPayInstrumentDDValidator alloc] init];
    
    NSError* routingError = [validator validateRoutingNo:routningNo];
    
    if (error != Nil) {
        *error = routingError;
    }
    
    return (routingError == Nil);
}


- (instancetype)initWithAccountNo:(NSString*)accountNo andRoutingNo:(NSString*)routingNo
{
    self = [super init];
    
    if (self) {
        self.type = PLVPITypeDD;
        
        NSArray* accountNoParts = [accountNo componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _accountNo = [accountNoParts componentsJoinedByString:@""];
    
        NSArray* routingNoParts = [routingNo componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _routingNo = [routingNoParts componentsJoinedByString:@""];
        
    }
    return self;
}

@end

@interface PLVPayInstrumentSEPA ()

- (instancetype)initWithIBAN:(NSString*)iban andBIC:(NSString*)bic;

@end


@implementation PLVPayInstrumentSEPA


+ (BOOL) validateIBAN:(NSString*)iban withError:(NSError **)error {
    
    PLVPayInstrumentSEPAValidator* validator = [[PLVPayInstrumentSEPAValidator alloc] init];
    
    NSError* ibanError = [validator validateIBAN:iban];
    
    if (error != Nil) {
        *error = ibanError;
    }
    
    return (ibanError == Nil);
    
}
+ (BOOL) validateBIC:(NSString*)bic withError:(NSError **)error {
    
    PLVPayInstrumentSEPAValidator* validator = [[PLVPayInstrumentSEPAValidator alloc] init];
    
    NSError* bicError = [validator validateBIC:bic];
    
    if (error != Nil) {
        *error = bicError;
    }
    
    return (bicError == Nil);
}



- (instancetype)initWithIBAN:(NSString*)iban andBIC:(NSString*)bic
{
    self = [super init];
    if (self) {
        self.type = PLVPITypeSEPA;
        
        NSArray* parts = [iban componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* tempIban = [parts componentsJoinedByString:@""];
        
        _iban = [tempIban uppercaseString];
        
        parts = [bic componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* tempBic = [parts componentsJoinedByString:@""];
        
        _bic = [tempBic uppercaseString];
    }
    
    return self;
}

@end

@interface PLVPayInstrumentPAYPAL ()

- (instancetype)initWithToken:(NSString*)token;

@end

@implementation PLVPayInstrumentPAYPAL

+ (BOOL) validateAuthToken:(NSString*)authToken withError:(NSError **)error {
    
    PLVPayInstrumentPAYPALValidator* validator = [[PLVPayInstrumentPAYPALValidator alloc] init];
    
    NSError* tokenError = [validator validateAuthToken:authToken];
    
    if (error != Nil) {
        *error = tokenError;
    }
    
    return (tokenError == Nil);
}


- (instancetype)initWithToken:(NSString*)token
{
    self = [super init];
    if (self) {
        self.type = PLVPITypePAYPAL;
        _authToken = token;
    }
    return self;
}

@end

@implementation PLVPaymentInstrument

@synthesize type = _type;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = PLVPICCTypeUnknown;
        _identifier = @"";
    }
    return self;
}

- (BOOL)validatePaymentInstrumentWithError:(NSError **)outError {
    
    PLVPaymentInstrumentValidator* validator = [PLVPaymentInstrumentValidator validatorForPaymentInstrument:self];
    
    if (validator == Nil) {
        
        *outError = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_PAYMENTINSTRUMENT_VALIDATION_CODE userInfo:[NSDictionary dictionaryWithObject:ERROR_PAYMENTINSTRUMENT_VALIDATION_MESSAGE forKey:NSLocalizedDescriptionKey]];
        
        return FALSE;
    }
    
    NSArray* validationErrors = [validator validateOnCreation];
    
    if (validationErrors.count == 0) {
        return TRUE;
    } else if (outError != 0) {
    
        NSMutableString* errorMessage = [NSMutableString new];
        
        for (NSError* error in validationErrors) {
            
            if (error.localizedDescription != Nil) {
                [errorMessage appendString:error.localizedDescription];
                [errorMessage appendString:@"\n"];
            }
        }
        
        *outError = [NSError errorWithDomain:PLVAPIClientErrorDomain code:ERROR_PAYMENTINSTRUMENT_VALIDATION_CODE userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
    }
    
    return FALSE;
}

+ (id)createCreditCardPayInstrumentWithPan:(NSString*)pan expiryMonth:(NSInteger)expiryMonth expiryYear:(NSInteger)expiryYear cvv:(NSString*)cvv andCardHolder:(NSString*)cardHolder
{
    PLVPayInstrumentCC* cc = [[PLVPayInstrumentCC alloc] initWithPan:pan expiryMonth:expiryMonth expiryYear:expiryYear cvv:cvv andCardHolder:cardHolder];
    
    return cc;
}

+ (id)createDebitPayInstrumentWithAccountNo:(NSString*)accountNo andRoutingNo:(NSString*)routingNo {
    
    PLVPayInstrumentDD* dd = [[PLVPayInstrumentDD alloc] initWithAccountNo:accountNo andRoutingNo:routingNo];
    
    return dd;
}

+ (id)createSEPAPayInstrumentWithIBAN:(NSString*)iban andBIC:(NSString*)bic {
    
    PLVPayInstrumentSEPA* sepa = [[PLVPayInstrumentSEPA alloc] initWithIBAN:iban andBIC:bic];
    
    return sepa;
}

+ (id) createPAYPALPayInstrumentWithToken:(NSString*)token {
    
    PLVPayInstrumentPAYPAL* payPal = [[PLVPayInstrumentPAYPAL alloc] initWithToken:token];

    return payPal;
}

@end


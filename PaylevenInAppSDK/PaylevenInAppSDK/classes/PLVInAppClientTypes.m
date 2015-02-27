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
#import "OrderedDictionary.h"

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

+ (instancetype) serializeWithDict:(NSDictionary*)dict;

- (NSMutableDictionary*) piDictDescription;

@end


@interface PLVCreditCardPaymentInstrument ()

- (id)initWithPan:(NSString*)pan expiryMonth:(NSInteger)expiryMonth expiryYear:(NSInteger)expiryYear cvv:(NSString*)cvv andCardHolder:(NSString*)cardHolder;

@end


@implementation PLVCreditCardPaymentInstrument

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

- (NSDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    if (self.cvv != Nil) {
        [content setObject:self.cvv forKey:ccCVVKey];
    }
    
    if (self.expiryMonth != 0) {
        [content setObject:[NSNumber numberWithInteger:self.expiryMonth] forKey:ccExpiryMonthKey];
    }
    
    if (self.expiryYear != 0) {
        [content setObject:[NSNumber numberWithInteger:self.expiryYear] forKey:ccExpiryYearKey];
    }
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    if (self.cardHolder != Nil) {
        [content setObject:self.cardHolder forKey:ccCardHolder];
    }
    
    if (self.pan != Nil) {
        [content setObject:self.pan forKey:ccPanKey];
    }
    
    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
}


@end


@interface PLVDebitCardPaymentInstrument ()

- (instancetype)initWithAccountNo:(NSString*)accountNo andRoutingNo:(NSString*)routingNo;

@end

@implementation PLVDebitCardPaymentInstrument

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

- (NSDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    
    if (self.accountNo != Nil) {
        [content setObject:self.accountNo forKey:ddAccountNoKey];
    }
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    if (self.routingNo != Nil) {
        [content setObject:self.routingNo forKey:ddRoutingNoKey];
    }
    
    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
}


@end

@interface PLVSEPAPaymentInstrument ()

- (instancetype)initWithIBAN:(NSString*)iban andBIC:(NSString*)bic;

@end


@implementation PLVSEPAPaymentInstrument


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

- (NSDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    if (self.bic != Nil) {
        [content setObject:self.bic forKey:sepaBICNumberKey];
    }
    
    if (self.iban != Nil) {
        [content setObject:self.iban forKey:sepaIBANNumberKey];
    }
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
}


@end

@interface PLVPAYPALPaymentInstrument ()

- (instancetype)initWithToken:(NSString*)token;

@end

@implementation PLVPAYPALPaymentInstrument

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

- (NSDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    if (self.authToken != Nil) {
        [content setObject:self.authToken forKey:paypalAuthTokenKey];
    }
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    if (self.type != Nil) {
        [content setObject:self.type forKey:piTypeKey];
    }
    
    return content;
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

+ (instancetype) serializeWithDict:(NSDictionary*)dict {
    
    if ([dict objectForKey:piTypeKey]) {
        
        NSString* piType = [dict objectForKey:piTypeKey];
        
        PLVPaymentInstrument* newPI;
        
        if ([piType isEqualToString:PLVPITypeCC]) {
            newPI = [[PLVCreditCardPaymentInstrument alloc] init];
        } else if ([piType isEqualToString:PLVPITypeDD]) {
            newPI = [[PLVDebitCardPaymentInstrument alloc] init];
        } else if ([piType isEqualToString:PLVPITypeSEPA]) {
            newPI = [[PLVSEPAPaymentInstrument alloc] init];
        } else if ([piType isEqualToString:PLVPITypePAYPAL]) {
            newPI = [[PLVPAYPALPaymentInstrument alloc] init];
        }
        
        SDLog(@"Serialze with Dict:%@",dict);
        
        [newPI initValuesWithDict:dict];
        
        return newPI;
    }
    
    return Nil;
    
}

- (NSMutableDictionary*) piDictDescription {
    
    OrderedDictionary* content = [OrderedDictionary new];
    
    if (self.identifier != Nil) {
        [content setObject:self.identifier forKey:piIdentifierTypeKey];
    }
    
    [content setObject:self.type forKey:piTypeKey];
    
    return content;
    
}

- (void) initValuesWithDict:(NSDictionary*)contentDict {
    
    [self setValuesForKeysWithDictionary:contentDict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    SDLog(@"Serialze %@: try to set undefinedKey:%@",[[self class] description],key);
    
}


+ (id)createCreditCardPaymentInstrumentWithPan:(NSString*)pan expiryMonth:(NSInteger)expiryMonth expiryYear:(NSInteger)expiryYear cvv:(NSString*)cvv andCardHolder:(NSString*)cardHolder
{
    PLVCreditCardPaymentInstrument* cc = [[PLVCreditCardPaymentInstrument alloc] initWithPan:pan expiryMonth:expiryMonth expiryYear:expiryYear cvv:cvv andCardHolder:cardHolder];
    
    return cc;
}

+ (id)createDebitCardPaymentInstrumentWithAccountNo:(NSString*)accountNo andRoutingNo:(NSString*)routingNo {
    
    PLVDebitCardPaymentInstrument* dd = [[PLVDebitCardPaymentInstrument alloc] initWithAccountNo:accountNo andRoutingNo:routingNo];
    
    return dd;
}

+ (id)createSEPAPaymentInstrumentWithIBAN:(NSString*)iban andBIC:(NSString*)bic {
    
    PLVSEPAPaymentInstrument* sepa = [[PLVSEPAPaymentInstrument alloc] initWithIBAN:iban andBIC:bic];
    
    return sepa;
}

+ (id) createPAYPALPaymentInstrumentWithToken:(NSString*)token {
    
    PLVPAYPALPaymentInstrument* payPal = [[PLVPAYPALPaymentInstrument alloc] initWithToken:token];

    return payPal;
}

@end


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
#import "PLVInAppClientTypes+Validation.h"
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

- (id)initWithPan:(NSString*)pan expiryMonth:(NSString*)expiryMonth expiryYear:(NSString*)expiryYear cvv:(NSString*)cvv andCardHolder:(NSString*)cardHolder;

@end


@implementation PLVPayInstrumentCC

- (id)initWithPan:(NSString*)pan expiryMonth:(NSString*)expiryMonth expiryYear:(NSString*)expiryYear cvv:(NSString*)cvv andCardHolder:(NSString*)cardHolder
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
        _cardHolder = cardHolder;
    }

    return self;
}

@end


@interface PLVPayInstrumentDD ()

- (instancetype)initWithAccountNo:(NSString*)accountNo andRoutingNo:(NSString*)routingNo;

@end

@implementation PLVPayInstrumentDD

- (instancetype)initWithAccountNo:(NSString*)accountNo andRoutingNo:(NSString*)routingNo
{
    self = [super init];
    if (self) {
        self.type = PLVPITypeDD;
        
        NSArray* accountNoParts = [self.accountNo componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _accountNo = [accountNoParts componentsJoinedByString:@""];
    
        NSArray* routingNoParts = [self.routingNo componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _routingNo = [routingNoParts componentsJoinedByString:@""];
        
    }
    return self;
}

@end

@interface PLVPayInstrumentSEPA ()

- (instancetype)initWithIBAN:(NSString*)iban andBIC:(NSString*)bic;

@end


@implementation PLVPayInstrumentSEPA

- (instancetype)initWithIBAN:(NSString*)iban andBIC:(NSString*)bic
{
    self = [super init];
    if (self) {
        self.type = PLVPITypeSEPA;
        
        NSArray* parts = [iban componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* tempIban = [parts componentsJoinedByString:@""];
        
        _iban = [tempIban uppercaseString];
        
        parts = [bic componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _bic = [parts componentsJoinedByString:@""];
        
    }
    
    return self;
}

@end

@interface PLVPayInstrumentPAYPAL ()

- (instancetype)initWithToken:(NSString*)token;

@end

@implementation PLVPayInstrumentPAYPAL

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

- (NSArray*) validate {
    return [self validateOnCreation];
}

- (BOOL)validatePayInstrumentReturningError:(NSError **)outError {
    
    NSArray* validationErrors = [self validate];
    
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

+ (id)createCCWithPan:(NSString*)pan expiryMonth:(NSString*)expiryMonth expiryYear:(NSString*)expiryYear cvv:(NSString*)cvv andCardHolder:(NSString*)cardHolder
{
    PLVPayInstrumentCC* cc = [[PLVPayInstrumentCC alloc] initWithPan:pan expiryMonth:expiryMonth expiryYear:expiryYear cvv:cvv andCardHolder:cardHolder];
    
    return cc;
}

+ (id)createDDWithAccountNo:(NSString*)accountNo andRoutingNo:(NSString*)routingNo {
    
    PLVPayInstrumentDD* dd = [[PLVPayInstrumentDD alloc] initWithAccountNo:accountNo andRoutingNo:routingNo];
    
    return dd;
}

+ (id)createSEPAWithIBAN:(NSString*)iban andBIC:(NSString*)bic {
    
    PLVPayInstrumentSEPA* sepa = [[PLVPayInstrumentSEPA alloc] initWithIBAN:iban andBIC:bic];
    
    return sepa;
}

+ (id) createPAYPALWithToken:(NSString*)token {
    
    PLVPayInstrumentPAYPAL* payPal = [[PLVPayInstrumentPAYPAL alloc] initWithToken:token];

    return payPal;
}

@end


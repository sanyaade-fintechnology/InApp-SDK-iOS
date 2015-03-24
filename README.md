[![CocoaPods](https://img.shields.io/badge/Platform-iOS-yellow.svg?style=flat-square)]()
[![CocoaPods](https://img.shields.io/badge/Requires-iOS%207+-blue.svg?style=flat-square)]()
[![CocoaPods](https://img.shields.io/github/tag/Payleven/InApp-SDK-iOS.svg?style=flat-square)]()
[![CocoaPods](https://img.shields.io/badge/Made%20in-Berlin-red.svg?style=flat-square)]()
[![CocoaPods](https://img.shields.io/badge/Licence-MIT-brightgreen.svg?style=flat-square)]()

# payleven InApp SDK

This project provides an iOS SDK that allows creating user tokens and payment instruments, retrieving and sorting payment instruments, based on the user token. Learn more about the InApp API on the [payleven website](https://payleven.com/).

### Prerequisites

1. Register with [payleven](http://payleven.com) in order to get personal merchant credentials
2. In order to receive an API key, please contact us by sending an email to developer@payleven.com

### Installation

##### CocoaPods

	...available very soon.

##### Manual Set-Up

1. Drag *PaylevenInAppSDK.framework* into your Xcode project.

2. Open the *Build Settings* of your target and add `-ObjC` flag to Other Linker Flags.

3. Import PaylevenSDK into your files:

        #import <PaylevenInAppSDK/PLVInAppSDK.h>

#### Code    

##### Authenticate your app
Use the unique API key to authenticate your app

	 [[PLVInAppClient sharedInstance] registerWithAPIKey:@”anAPIKey”];
	
##### Add a payment instrument
Create an object of `PLVPaymentInstrument` class (a `PLVCreditCardPaymentInstrument`, `PLVDebitCardPaymentInstrument`, `PLVSEPAPaymentInstrument` or `PLVPAYPALPaymentInstrument`). 
If it's the first time you are trying to add a payment instrument for your user, you need to create a user token, based on the user's email address.
	
	PLVPayInstrumentDD* tempDebitPi = [PLVPaymentInstrument createDebitPayInstrumentWithAccountNo:@"123123" 
												                                      andRoutingNo:@"123123"];
	
	//Create User Token							
	[[PLVInAppClient sharedInstance] createUserToken:@"anEmailAdress@p11.de"
                               withPaymentInstrument:pi
                                             useCase:@"Business"
	                                   andCompletion:^(NSDictionary * response, NSError * error) {
	                                   	    if (response) {
	                                               NSString * userTokenString = [response objectForKey:@"userToken"];
	                                               //Success, this token should now be forwarded to your Backend...
	                                           }
	    
	}];
	
	//Or simply add Payment Instrument to existing User Token
	[[PLVInAppClient sharedInstance] addPaymentInstrument:tempDebitPi 
											  forUserToken:@"A User Token" 
											   withUseCase:@"A Use Case" 
											 andCompletion:^(NSDictionary* result, NSError* error) {
											    if (error) {
											       //Error occured, see error.localizedDescription
											    } else {
												   //Success
												}
	 }];

##### Get the payment instruments for a user token
Use the user token to retrieve the payment instruments associated to it and to a specific use case.
The list of payment instruments is sorted based on the order in which the payment instruments will be selected when making a payment.

	[[PLVInAppClient sharedInstance] getPaymentInstrumentsList:@"A User Token" withUseCase:@"A Use Case" andCompletion:^(NSDictionary* result, NSError* error){
		if(error){
			//Error occured, see error.localizedDescription
	    } else {
			if ([result objectForKey:@"paymentInstruments"]) {
		       	NSArray* piListArray = [result objectForKey:@"paymentInstruments"];
				self.piArray = piListArray;
		    } else {
				//No Payment Instruments found
		    }
	    }
	}];

##### Set payment instruments order for a use case
To update the order in which the payment instruments will be used when making a payment, call `setPaymentInstrumentsOrder` with the ordered list of payment instruments, the user token and the use case to which they belong.

	NSOrderedSet* ordedSet = [[NSOrderedSet alloc] initWithArray:self.piArray];
	    
	[[PLVInAppClient sharedInstance] setPaymentInstrumentsOrder:ordedSet forUserToken:@"A User Token" withUseCase:@"A Use Case" andCompletion:^(NSDictionary* result, NSError* error){
      
	        if (error) {
	            //Error occured, see error.localizedDescription
	        } else if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
	            //Success
	        }
	}];

##### Remove payment instrument for a use case
Remove a payment instrument, belonging to a specific user token, from a use case. After this, the payment instrument cannot be used to make payments for that use case.

	[[PLVInAppClient sharedInstance] removePaymentInstrument:pi fromUseCase:@"A Use Case" forUserToken:@"A User Token" andCompletion:^(NSDictionary* result, NSError* error){
	            
	        if (error) {
	            //Error occured, see error.localizedDescription
	        } else if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
	            //Success
	        }            
	}];

##### Disable payment instrument
Disable a payment instrument, belonging to a specific user token. The payment instrument will be removed from all use cases. 

	[[PLVInAppClient sharedInstance] disablePaymentInstrument:pi forUserToken:@"A User Token" andCompletion:^(NSDictionary* result, NSError* error){
	            
	        if (error) {
	            //Error occured, see error.localizedDescription
	        } else if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
	            //Success
	        } 
	}];

#### Documentation
[API Reference](http://payleven.github.io/InApp-SDK-iOS/AppleDoc/)
# payleven InApp SDK 1.0.0

(EDIT!! @KONRAD)
This project provides an iOS API to communicate with the payleven Chip & PIN card reader in order to accept debit and credit card payments. Learn more about the Chip & PIN card reader and payment options on one of payleven's regional [websites](https://payleven.com/).

### Prerequisites
1. Register with [payleven](http://payleven.com) in order to get personal merchant credentials and a card reader.
2. Get API key on payleven [developer portal](https://payleven.de/developers/).

### Installation

##### CocoaPods

##### Manual Set-Up

1. Drag *PaylevenInAppSDK.framework* into your Xcode project.

2. Open the *Build Settings* of your target and add `-ObjC` flag to Other Linker Flags.

3. Import PaylevenSDK into your files:

        #import <PaylevenInAppSDK/PLVInAppSDK.h>

#### Code    

##### Setup API-Key
Set up PLVClient in order to register your unique API key

	 [[PLVInAppClient sharedInstance] registerWithAPIKey:@”aaaAnAPIKeyaaaaa”];

### Create Payment Instrument (PI)
<p align="center"><img src="/Customer_PI_Add.gif" height="400" alt="Sublime's custom image"/></p>

Any payment request via In-App SDK requires a unique user token provided by payleven. To create and retrieve a user token you must provide one first payment instrument (PI) (e.g Credit Card) together with the email address of your client. For this reason create payment instrument (PI) by using PLVPaymentInstrument’s class Methods (e.g. CreateSEPAPayINstuments….)

	PLVPayInstrumentDD  * tempDebitPi = [PLVPaymentInstrument createDebitPayInstrumentWithAccountNo:@"123123" andRoutingNo:@"123123"]; 

##### Create User Token

    [[PLVInAppClient sharedInstance] createUserToken:@"anEmailAdress@p11.de"
                               withPaymentInstrument:pi
                                             useCase:@"Business"
                                       andCompletion:^(NSDictionary * response, NSError * error) {
                                           if (response) {
                                               NSString * userTokenString = [response objectForKey:@"userToken"];
                                               //do something
                                           }
    
    }];


##### Validate Payment Instrument (PI)

	NSError * validationError;
	if ([pi validatePaymentInstrumentWithError:&validationError]){
		//do stuff
	}



#### Documentation
[API Reference](https://github.com/payleven/mpos-android/javadoc)
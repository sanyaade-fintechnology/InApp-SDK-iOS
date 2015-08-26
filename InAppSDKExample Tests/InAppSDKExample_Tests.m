//
//  InAppSDKExample_Tests.m
//  InAppSDKExample Tests
//
//  Created by Johannes Rupieper on 24/08/15.
//  Copyright (c) 2015 payleven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PaylevenInAppSDK/PLVInAppSDK.h>

static int timeoutTolerance = 10;

@interface InAppSDKExample_Tests : XCTestCase <NSURLSessionTaskDelegate>
{
    /* instance level asynchronous delegate method was called expectation
     needs to be visible to _both_ the test and delegate method */
    
}

@end

@implementation InAppSDKExample_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// 1. Add payment and check if the call parse without error   --> done
// 2. Send a short CVV. The validation must throw an error.   --> done
// 3. Send an invalid API token. The SDK must return an error.   --> done
// 4. Add multiple PI's in a row.  --> done
// 5. Connection lost        markus
// 8. List all PI's    --> done
// 9. Remove PI
// 10. Sort PI
// 11. Random PAN length   --> done
// 12. Character and numbers mixed    --> done
// 13. Random expiry dates     --> done
// 14. Cardholder name wiht 10 whitespaces, zero character, zero string, some unicode smilies   -->done
// 15. Unicode check NSString *s = @"\U0001F31E";       -->done


@end

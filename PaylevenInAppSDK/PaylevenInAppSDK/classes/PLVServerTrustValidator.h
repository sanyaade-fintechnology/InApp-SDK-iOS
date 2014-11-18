//
//  PLVServerTrustValidator.h
//  PaylevenSDK
//
//  Created by Alexei Kuznetsov on 09.10.14.
//  Copyright (c) 2014 payleven Holding GmbH. All rights reserved.
//

@import Foundation;

/** A class that validates server trust. */
@interface PLVServerTrustValidator : NSObject

/**
 * Validates the server trust using public key from the certificate.
 *
 * @discussion
 * First server trust is evaluated normally where the certificate chain is validated. Then the public key of the leaf
 * certificate in the chain is checked to be the same as the public key in the specified certificate. This provides
 * public key pinning.
 *
 * @param serverTrust
 * Server trust to evaluate.
 *
 * @param certificateData
 * Data of the DER-encoded certificate, which public key must be compared with the public key in the leaf certificate
 * found in @c serverTrust.
 *
 * @return
 * A Boolean value indicating if the validation was successful.
 */
- (BOOL)validateServerTrust:(SecTrustRef)serverTrust withPublicKeyFromCertificate:(NSData *)certificateData;

@end

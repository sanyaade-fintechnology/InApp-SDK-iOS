//
//  SingletonHelper.h
//  PaylevenInAppPayment
//
//  Created by ploenne on 08.10.14.
//  Copyright (c) 2014 Payleven. All rights reserved.
//

#ifndef PaylevenInAppPayment_singletonHelper_h
#define PaylevenInAppPayment_singletonHelper_h

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *sharedInstance = nil; \
\
+ (instancetype) sharedInstance \
{ \
@synchronized(self) \
{ \
if (sharedInstance == nil) \
{ \
sharedInstance = [[self alloc] init]; \
} \
} \
\
return sharedInstance; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
@synchronized(self) \
{ \
if (sharedInstance == nil) \
{ \
sharedInstance = [super allocWithZone:zone]; \
return sharedInstance; \
} \
} \
\
return nil; \
}


#endif


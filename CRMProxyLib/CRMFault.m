//
//  CRMFault.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/26/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import "CRMFault.h"

@implementation CRMFault
@synthesize errorCode = _errorCode;
@synthesize errorDetails = _errorDetails;
@synthesize message = _message;

- (NSString *) description
{
    return [NSString stringWithFormat:@"Fault:\n\tErrorCode: %@\n\tMessage: %@", self.errorCode, self.message];
}
@end

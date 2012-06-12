//
//  CRMFault.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/26/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRMFault : NSObject
@property (nonatomic, strong) NSString *errorCode;
@property (nonatomic, strong) NSArray *errorDetails;
@property (nonatomic, strong) NSString *message;
@end

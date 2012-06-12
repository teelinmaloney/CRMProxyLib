//
//  CRMSecurityToken.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/16/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRMSecurityToken : NSObject
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *expiresAt;
@property (nonatomic, strong) NSString *tokenXml;
// Ifd properties -->
@property (nonatomic, strong) NSString *requestedAttachedReference;
@property (nonatomic, strong) NSString *securityTokenReference;
@property (nonatomic, strong) NSString *binarySecret;
@end
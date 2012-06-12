//
//  CRMSecurityToken.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/16/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import "CRMSecurityToken.h"

@implementation CRMSecurityToken

@synthesize createdAt = _createdAt;
@synthesize expiresAt = _expiresAt;
@synthesize tokenXml = _tokenXml;

@synthesize binarySecret = _binarySecret;
@synthesize requestedAttachedReference = _requestedAttachedReference;
@synthesize securityTokenReference = _securityTokenReference;

@end
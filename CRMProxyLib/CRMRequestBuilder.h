//
//  CRMRequestBuilder.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/25/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRMEntity.h"
#import "CRMSecurityToken.h"

@interface CRMRequestBuilder : NSObject
@property (nonatomic, strong) NSString* organizationServiceUrl;
@property (nonatomic, strong) NSString* secureTokenServiceUrl;
- (NSString *)buildAuthRequestForUserName:(NSString *)userName andPassword:(NSString *)password;
- (NSString *)buildCreateRequest:(id<CRMEntity>)model withSecurityToken:(CRMSecurityToken *)token;
- (NSString *)buildUpdateRequest:(id<CRMEntity>)model withSecurityToken:(CRMSecurityToken *)token;
- (NSString *)buildDeleteRequest:(id<CRMEntity>)model withSecurityToken:(CRMSecurityToken *)token;
- (NSString *)buildFetchRequest:(NSString *)fetchXml withSecurityToken:(CRMSecurityToken *)token;
- (NSString *)buildRetrieveRequest:(NSString *)entityName entityId:(NSString *)entityId withSecurityToken:(CRMSecurityToken *)token;
- (NSString *)buildRetrieveRequest:(NSString *)entityName entityId:(NSString *)entityId attributes:(NSArray *)attributes 
                 withSecurityToken:(CRMSecurityToken *)token;
- (NSString *)buildExecuteRequest:(NSString *)requestXml withSecurityToken:(CRMSecurityToken *)token;
@end

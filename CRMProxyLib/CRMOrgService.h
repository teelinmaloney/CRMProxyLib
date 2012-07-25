//
//  CRMOrgService.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/15/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRMEntity.h"

@interface CRMOrgService : NSObject

@property (nonatomic, strong) NSString* organizationServiceUrl;
@property (nonatomic, strong) NSString* secureTokenServiceUrl;
@property (nonatomic, strong) NSString* org;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* password;

- (id) initWithOrganizationServiceUrl:(NSString *)orgUrl andSecureTokenServiceUrl:(NSString *)stsUrl;

- (id) execute: (NSString *) requestXml;

- (NSString *) create: (id<CRMEntity>)model;
- (void) update: (id<CRMEntity>)model;
- (void) delete: (NSString *)entityId;

- (id) retrieve: (NSString *)modelName
     entityName: (NSString *)entityName 
       entityId: (NSString *)entityId
     attributes: (NSArray *)attributes;

- (NSArray *) retrieveMultiple: (NSString *)fetchXml ofClassName:(NSString *)className;

@end

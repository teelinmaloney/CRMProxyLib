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

@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* org;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* password;

- (id) initWithUrl: (NSString *)url 
      organization: (NSString *)org;

- (id) execute: (NSString *) requestXml;

- (NSString *) create: (id<CRMEntity>)model;
- (void) update: (id<CRMEntity>)model;
- (void) delete: (NSString *)entityId;

- (id) retrieve: (NSString *)modelName
     entityName: (NSString *)entityName 
       entityId: (NSString *)entityId
     attributes: (NSArray *)attributes;

- (NSArray *) retrieveMultiple: (NSString *)fetchXml;

@end

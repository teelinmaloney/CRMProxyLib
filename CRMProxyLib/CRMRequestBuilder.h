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
- (NSString *) buildCreateRequest:(id<CRMEntity>)model;
- (NSString *) buildUpdateRequest:(id<CRMEntity>)model;
- (NSString *) buildDeleteRequest:(NSString *)guid;
- (NSString *) buildFetchRequest:(NSString *)fetchXml;
@end

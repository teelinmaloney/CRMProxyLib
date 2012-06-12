//
//  CRMQueryBuilder.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 6/4/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRMCondition.h"

#pragma mark CRMLinkEntity

@interface CRMLinkEntity : NSObject

+(NSString *) linkToEntity:(NSString *)toEntityName toAttribute:(NSString *)toAttributeName fromAttribute:(NSString *)fromAttributeName 
                 condition:(CRMCondition *)condition;

+(NSString *) linkToEntity:(NSString *)toEntityName toAttribute:(NSString *)toAttributeName fromAttribute:(NSString *)fromAttributeName 
                 condition:(CRMCondition *)condition
                linkEntity:(CRMLinkEntity *)linkEntity;
@end

#pragma mark CRMQueryBuilder

@interface CRMQueryBuilder : NSObject

@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic) BOOL allAttributes;
@property (nonatomic, strong) NSMutableArray *linkEntities;
@property (nonatomic, strong) NSMutableArray *conditions;

-(id)initWithEntityName:(NSString *)entityName;
-(NSString *)toFetchXml;

@end

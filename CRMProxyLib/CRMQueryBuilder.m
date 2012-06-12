//
//  CRMQueryBuilder.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 6/4/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import "CRMQueryBuilder.h"

@implementation CRMQueryBuilder

@synthesize entityName = _entityName;
@synthesize attributes = _attributes;
@synthesize allAttributes = _allAttributes;
@synthesize conditions = _conditions;
@synthesize linkEntities = _linkEntities;


-(id)init
{
    return [self initWithEntityName:nil];
}

-(id)initWithEntityName:(NSString *)entityName
{
    self = [super init];
    if (self) {
        _entityName = entityName;
        _attributes = [[NSMutableArray alloc]init];
        _conditions = [[NSMutableArray alloc]init];
        _linkEntities = [[NSMutableArray alloc]init];
    }
    return self;
}

-(NSString *)toFetchXml
{
    NSMutableString *fetchXml = [[NSMutableString alloc]initWithString:@"<fetch>"];

    [fetchXml appendFormat:@"<entity name='%@'></entity>", _entityName];
    
    if (_allAttributes == YES) {
        [fetchXml appendString:@"<all-attributes />"];
    }
    else if ([_attributes count] > 0) {
        for (NSString *attr in _attributes) {
            [fetchXml appendFormat:@"<attribute name='%@' />", attr];
        }
    }
    
    if ([_conditions count] > 0) {
        [fetchXml appendString:@"<filter type='and'>"];
        for (CRMCondition* condition in _conditions) {
#pragma TODO handle different operators/values
            [fetchXml appendFormat:@"<condition attribute='%@' operator='%@' value='%@' />",
             condition.attributeName, 
             [condition getConditionOperatorString], 
             condition.value];
        }
        [fetchXml appendString:@"</filter>"];
    }
    
    [fetchXml appendString:@"</fetch>"];
    
    return fetchXml;
}

@end

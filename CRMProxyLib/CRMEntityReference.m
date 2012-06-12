//
//  CRMEntityReference.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/6/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import "CRMEntityReference.h"

@implementation CRMEntityReference
@synthesize id = _id;
@synthesize name = _name;
@synthesize logicalName = _logicalName;

-(id)initWithEntityName:(NSString *)entityName andId:(NSString *)guid
{
    self = [super init];
    if (self) {
        _logicalName = entityName;
        _id = guid;
    }
    return self;
}

@end

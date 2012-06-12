//
//  CRMRequestBuilder.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/25/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import "CRMRequestBuilder.h"
#import "CRMEntityMapper.h"

@interface CRMRequestBuilder() {
@private
    CRMEntityMapper *entityMapper_;
}
@end

@implementation CRMRequestBuilder

-(id) init
{
    self = [super init];
    if (self) {
        entityMapper_ = [[CRMEntityMapper alloc]init];
    }
    return self;
}

- (NSString *) buildCreateRequest:(id<CRMEntity>)model
{
    return [NSString stringWithFormat:@""
            "<Create xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'>"
            "%@"
            "</Create>", [entityMapper_ toXml:model]];
}

- (NSString *) buildUpdateRequest:(id<CRMEntity>)model
{
    return [NSString stringWithFormat: @""
            "<Update xmlns='http://schemas.microsoft.com/xrm/2011/Contracts/Services'>"
            "%@"
            "</Update>", [entityMapper_ toXml:model]];
}

- (NSString *) buildDeleteRequest:(NSString *)guid
{
    return @"Not Implemented";
}

- (NSString *) buildFetchRequest:(NSString *)fetchXml
{
    return @"Not Implemented";
}

@end
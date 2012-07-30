//
//  CRMEntityMapper.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/24/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRMEntity.h"
#import "GDataXMLNode.h"

@interface CRMEntityMapper : NSObject
@property (nonatomic, strong) NSString *className;

+ (NSString *)toXml:(id<CRMEntity>)model;

- (id)initWithClassName:(NSString *)className;
- (id<CRMEntity>)fromEntityXml:(GDataXMLNode *)entityXml;
- (id<CRMEntity>)fromFetchResultXml:(GDataXMLNode *)fetchResultXml;

@end

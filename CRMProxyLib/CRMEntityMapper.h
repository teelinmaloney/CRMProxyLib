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

@property (nonatomic, strong) NSString *entityName;

+(NSString *)toXml:(id<CRMEntity>)model;

-(id)initWithEntityName:(NSString *)entityName;
-(id<CRMEntity>)fromFetchResultXml:(GDataXMLNode *)fetchResultXml;

@end

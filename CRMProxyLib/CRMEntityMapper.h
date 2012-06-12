//
//  CRMEntityMapper.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/24/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRMEntity.h"

@interface CRMEntityMapper : NSObject

- (NSString *) toXml:(id<CRMEntity>)model;
- (id) fromXml:(NSString *)xml; 

@end

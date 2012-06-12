//
//  CRMEntity.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/6/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CRMEntity <NSObject>
@property (nonatomic, strong, readonly) NSString *entityName;
@property (nonatomic, strong, readonly) NSString *id;
@end

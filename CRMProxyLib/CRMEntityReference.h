//
//  CRMEntityReference.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/6/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSNumber OptionSet;

@interface Guid : NSString
@end

@interface CRMEntityReference : NSObject
@property (nonatomic, strong) NSString* id;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* logicalName;
-(id)initWithEntityName:(NSString *)entityName andId:(NSString *)guid;
@end

typedef CRMEntityReference CRMOwner;
typedef CRMEntityReference CRMCustomer;
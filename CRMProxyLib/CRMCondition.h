//
//  CRMCondition.h
//  CRMProxyLib
//
//  Created by Michael Maloney on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Active,
    Equal,
    EqualBusinessId,
    EqualUserId,
    GreaterThan,
    GreaterThanEqualTo,
    In,
    LessThan,
    LessThanEqualTo,
    NotActive,
    NotEqual,
    NotIn,
    NotNull,
    Null
} CRMConditionOperator;

@interface CRMCondition : NSObject

@property (nonatomic, strong) NSString *attributeName;
@property (nonatomic) CRMConditionOperator conditionOperator;
@property (nonatomic, strong) NSObject *value;

-(id)initWithAttribute:(NSString *)attributeName andConditionOperator:(CRMConditionOperator)conditionOperator;
-(id)initWithAttribute:(NSString *)attributeName andConditionOperator:(CRMConditionOperator)conditionOperator 
              andValue:(NSString *)value;

-(NSString *)getConditionOperatorString;

@end

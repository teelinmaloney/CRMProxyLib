//
//  CRMCondition.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CRMCondition.h"

@interface CRMCondition()
+(NSString *)getOperatorString:(CRMConditionOperator)operator;
@end

@implementation CRMCondition

@synthesize attributeName = _attributeName;
@synthesize conditionOperator = _conditionOperator;
@synthesize value = _value;

NSString* const kCRMConditionOperatorEqual = @"eq";
NSString* const kCRMConditionOperatorEqualBusinessId = @"eq-businessid";
NSString* const kCRMConditionOperatorEqualUserId = @"eq-userid";
NSString* const kCRMConditionOperatorGreaterThan = @"gt";
NSString* const kCRMConditionOperatorGreaterThanEqualTo = @"gt-eq";
NSString* const kCRMConditionOperatorIn = @"in";
NSString* const kCRMConditionOperatorLessThan = @"lt";
NSString* const kCRMConditionOperatorLessThanEqualTo = @"lt-eq";
NSString* const kCRMConditionOperatorNotEqual = @"ne";
NSString* const kCRMConditionOperatorNotIn = @"not-in";
NSString* const kCRMConditionOperatorNotNull = @"not-null";
NSString* const kCRMConditionOperatorNull = @"null";


-(id)initWithAttribute:(NSString *)attributeName andConditionOperator:(CRMConditionOperator)conditionOperator
{
    return nil;
}

-(id)initWithAttribute:(NSString *)attributeName andConditionOperator:(CRMConditionOperator)conditionOperator andValue:(NSString *)value
{
    self = [super init];
    if (self) {
        _attributeName = attributeName;
        _conditionOperator = conditionOperator;
        _value = value;
    }
    return self;
}

-(NSString *)getConditionOperatorString
{
    switch (_conditionOperator) {
        case Active:
        case Equal:
            return kCRMConditionOperatorEqual;
        case EqualBusinessId:
            return kCRMConditionOperatorEqualBusinessId;
        case EqualUserId:
            return kCRMConditionOperatorEqualUserId;
        case GreaterThan:
            return kCRMConditionOperatorGreaterThan;
        case GreaterThanEqualTo:
            return kCRMConditionOperatorGreaterThanEqualTo;
        case LessThan:
            return kCRMConditionOperatorLessThan;
        case LessThanEqualTo:
            return kCRMConditionOperatorLessThanEqualTo;
        case NotActive:
        case NotEqual:
            return kCRMConditionOperatorNotEqual;
        case NotIn:
            return kCRMConditionOperatorNotIn;
        case NotNull:
            return kCRMConditionOperatorNotNull;
        default:
            return @"";
    }
}

@end
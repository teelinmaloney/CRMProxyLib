//
//  CRMEntityMapper.m
//  CRMProxyLib
//
//  Created by Michael Maloney on 5/24/12.
//  Copyright (c) 2012 Sonoma Partners. All rights reserved.
//

#import <objc/runtime.h>
#import "CRMEntityMapper.h"
#import "CRMEntityReference.h"

@interface CRMEntityMapper() {
@private
    NSArray *excludeAttributes_;
}
- (NSString *)getAttributeXml:(id)model;
- (NSString *)getAttributeValueXml:(id)value;
@end

@implementation CRMEntityMapper

-(id) init
{
    self = [super init];
    if (self) {
        excludeAttributes_ = [NSArray arrayWithObjects:@"id", @"entityName", nil];
    }
    return self;
}

- (NSString *) toXml:(id<CRMEntity>)model
{
    // !Format must stay exactly as is, any variations may cause the request to fail!
    NSString *entityXml = @"<entity xmlns:a='http://schemas.microsoft.com/xrm/2011/Contracts' xmlns:i='http://www.w3.org/2001/XMLSchema-instance'>"
    "<a:Attributes xmlns:b='http://schemas.datacontract.org/2004/07/System.Collections.Generic'>"
    "%@"
    "</a:Attributes>"
    "<a:EntityState i:nil='true'/>"
    "<a:FormattedValues xmlns:b='http://schemas.datacontract.org/2004/07/System.Collections.Generic'/>"
    "<a:Id>%@</a:Id>"
    "<a:LogicalName>%@</a:LogicalName>"
    "<a:RelatedEntities xmlns:b='http://schemas.datacontract.org/2004/07/System.Collections.Generic'/>"
    "</entity>";
    
    NSString *guid = model.id;
    if (!guid) {
        guid = @"00000000-0000-0000-0000-000000000000";
    }
    
    return [NSString stringWithFormat:entityXml, [self getAttributeXml:model], guid, model.entityName];
}

- (id) fromXml:(NSString *)xml
{
    NSString *modelName = @""; // TODO: get from xml response
    
    id model = [[NSClassFromString(modelName) alloc]init];
    if (model == nil) {
        return nil;
    }
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
    for (NSString *key in attributes) {
        [model setValue:[attributes valueForKey:key] forKey:key];
    }
    
    return model;
}

#pragma mark Private Methods - ToXml Helpers

-(NSString *)getAttributeXml:(id)model
{
    NSMutableString *attributes = [[NSMutableString alloc]init];
    
    __unsafe_unretained Class type = [model class];
    unsigned int count;
    
    objc_property_t *props = class_copyPropertyList(type, &count);
    for (int i = 0; i < count; i++) {
        
        objc_property_t prop = props[i];
        
        const char* propertyName = property_getName(prop);
        
        NSString *propertyNameString = [NSString stringWithCString:propertyName encoding:NSASCIIStringEncoding];
        if ([excludeAttributes_ containsObject:propertyNameString]) {
            continue;
        }
        
        id value = [model valueForKey:propertyNameString];
        if (value != nil) {
            [attributes appendFormat:@"<a:KeyValuePairOfstringanyType><b:key>%@</b:key>%@</a:KeyValuePairOfstringanyType>", 
             propertyNameString, [self getAttributeValueXml:value]];
        }
    }
    free(props);
    
    return attributes;
}

-(NSString *)getAttributeValueXml:(id)value
{
    NSString *valueXml = @"<b:value i:type='c:%@' xmlns:c='http://www.w3.org/2001/XMLSchema'>%@</b:value>";
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:valueXml, @"string", value];
    } else if ([value isKindOfClass:[NSDate class]]) {
        return [NSString stringWithFormat:valueXml, @"dateTime", value];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        CFNumberType type = CFNumberGetType((CFNumberRef)value);
        if (strcmp([(NSNumber*)value objCType], @encode(BOOL)) == 0) {
            return [NSString stringWithFormat:valueXml, @"boolean", ((int)value)];
        }
        switch (type) {
            case kCFNumberSInt8Type:
            case kCFNumberSInt16Type:
            case kCFNumberSInt32Type:
            case kCFNumberSInt64Type:
            case kCFNumberShortType:
            case kCFNumberIntType:
                return [NSString stringWithFormat:valueXml, @"int", value];
                
            case kCFNumberFloatType:
            case kCFNumberFloat32Type:
            case kCFNumberFloat64Type:
            case kCFNumberDoubleType:
                return [NSString stringWithFormat:valueXml, @"decimal", value];
                
            default:
                return @"<b:value></b:value>";
        }
    } else if ([value isKindOfClass:[CRMEntityReference class]]) {
        return [NSString stringWithFormat:@""
                "<b:value i:type='a:EntityReference'>"
                "<a:Id>%@</a:Id>"
                "<a:LogicalName>%@</a:LogicalName>"
                "<a:Name i:nil='true'/>"
                "</b:value>", 
                ((CRMEntityReference*)value).id,
                ((CRMEntityReference*)value).logicalName];
    } else if ([value isKindOfClass:[Guid class]]) {
        return [NSString stringWithFormat:valueXml, @"guid", value];
    }
    
    return @"";
}

@end

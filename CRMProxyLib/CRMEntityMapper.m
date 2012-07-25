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
    
}

@property (nonatomic, strong) NSMutableDictionary *attributeMetadata;
+ (NSDictionary *)getAttributesForModelName:(NSString *)modelName;
+ (NSString *)getAttributeXml:(id<CRMEntity>)model;
+ (NSString *)getAttributeValueXml:(id)value;
@end

@implementation CRMEntityMapper

@synthesize entityName = _entityName;
@synthesize attributeMetadata = _attributeMetadata;

#pragma mark Class Methods

+(NSString *)toXml:(id<CRMEntity>)model
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

#pragma mark Instance Methods

-(id)init
{
    return [self initWithEntityName:nil];
}

-(id)initWithEntityName:(NSString *)entityName
{
    self = [super init];
    if (self) {
        [self setEntityName:entityName];
        [self setAttributeMetadata:[[CRMEntityMapper getAttributesForModelName:self.entityName]copy]];
    }
    return self;
}

-(id<CRMEntity>)fromFetchResultXml:(GDataXMLNode *)fetchResultNode
{
    id<CRMEntity> model = [[NSClassFromString(self.entityName)alloc]init];
    if (model == nil) {
        return nil;
    }
    
    // Get attributes and values from xml
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
    for (GDataXMLElement *attr in [fetchResultNode children]) {
        NSArray *elementAttributes = [attr attributes];
        if ([elementAttributes count] > 0) {
            
            // Entity Reference
            GDataXMLNode *name = [attr attributeForName:@"name"];
            GDataXMLNode *type = [attr attributeForName:@"type"];
            if (name != nil && type != nil) {
                CRMEntityReference *ref = [[CRMEntityReference alloc]init];
                [ref setId:[attr stringValue]];
                [ref setName:[name stringValue]];
                [ref setLogicalName:[type stringValue]];
                [attributes setValue:ref forKey:[attr name]];
                continue;
            }
            
            // DateTime
            GDataXMLNode *date = [attr attributeForName:@"date"];
            GDataXMLNode *time = [attr attributeForName:@"time"];
            if (date != nil && time != nil) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [attributes setValue:[formatter dateFromString:[attr stringValue]] forKey:[attr name]];
                continue;
            }
            
        } else {
            [attributes setValue:[attr stringValue] forKey:[attr name]];
        }
    }
    
    for (NSString *attr in [self.attributeMetadata allKeys]) {
        id value = [attributes valueForKey:attr];
        if (value) {
            [model setValue:value forKey:attr];
        }
    }
    
    NSLog(@"%@", [model id]);
    
    return model;
}

#pragma mark Private Class Methods

+(NSDictionary *)getAttributesForModelName:(NSString *)modelName
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
    NSArray *excludedAttributes = [[NSArray alloc]initWithObjects:@"id", @"entityName", nil];
    
    id<CRMEntity> model = [[NSClassFromString(modelName) alloc]init];
    if (model == nil) {
        return attributes;
    }
    
    __unsafe_unretained Class type = [model class];
    unsigned int count;
    
    objc_property_t *props = class_copyPropertyList(type, &count);
    for (int i = 0; i < count; i++) {
        
        objc_property_t prop = props[i];
        
        const char* propertyName = property_getName(prop);
        
        NSString *propertyNameString = [NSString stringWithCString:propertyName encoding:NSASCIIStringEncoding];
        if ([excludedAttributes containsObject:propertyNameString]) {
            continue;
        }
        
        [attributes setValue:[NSNull null] forKey:propertyNameString];
        
    }
    free(props);
    
    return attributes;
}

#pragma mark Private Class Methods - ToXml Helpers

+(NSString *)getAttributeXml:(id<CRMEntity>)model
{   
    NSDictionary *attributes = [CRMEntityMapper getAttributesForModelName:[model entityName]];
    NSMutableString *attributeXml = [[NSMutableString alloc]init];
    for (NSString* attr in [attributes allKeys]) {
        id value = [model valueForKey:attr];
        if (value != nil) {
            [attributeXml appendFormat:@"<a:KeyValuePairOfstringanyType><b:key>%@</b:key>%@</a:KeyValuePairOfstringanyType>", 
             attr, [self getAttributeValueXml:value]];
        }
    }
    return attributeXml;
}

+(NSString *)getAttributeValueXml:(id)value
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

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
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDictionary *namespaces;
@property (nonatomic, strong) NSMutableDictionary *attributeMetadata;
+ (NSDictionary *)getAttributesForClassName:(NSString *)className;
+ (NSString *)getAttributeXml:(id<CRMEntity>)model;
+ (NSString *)getAttributeValueXml:(id)value;
@end

@implementation CRMEntityMapper

@synthesize className = _className;
@synthesize dateFormatter = _dateFormatter;
@synthesize namespaces = _namespaces;
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
    "<a:Id>00000000-0000-0000-0000-000000000000</a:Id>"
    "<a:LogicalName>%@</a:LogicalName>"
    "<a:RelatedEntities xmlns:b='http://schemas.datacontract.org/2004/07/System.Collections.Generic'/>"
    "</entity>";
        
    return [NSString stringWithFormat:entityXml, [self getAttributeXml:model], [model entityName]];
}

#pragma mark Instance Methods

-(id)init
{
    return [self initWithClassName:nil];
}

-(id)initWithClassName:(NSString *)className
{
    self = [super init];
    if (self) {
        
        if ([className length] == 0) {
            NSLog(@"Warning: Initializing CRMEntityMapper without 'className'."); 
        }
        
        [self setClassName:className];
        [self setAttributeMetadata:[[CRMEntityMapper getAttributesForClassName:className]copy]];
        [self setDateFormatter:[[NSDateFormatter alloc]init]];
        [[self dateFormatter]setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        [self setNamespaces: [NSDictionary dictionaryWithObjectsAndKeys:
                              @"http://www.w3.org/2001/04/xmlenc#", @"xenc",
                              @"http://www.w3.org/2001/XMLSchema-instance", @"xsi",
                              @"http://schemas.microsoft.com/xrm/2011/Contracts", @"Contracts", 
                              @"http://schemas.microsoft.com/xrm/2011/Contracts/Services", @"Services",
                              @"http://schemas.microsoft.com/crm/2007/WebServices", @"ws",
                              @"http://schemas.datacontract.org/2004/07/System.Collections.Generic", @"c",
                              nil]];
        
    }
    return self;
}

- (id<CRMEntity>)fromFetchResultXml:(GDataXMLNode *)fetchResultNode
{
    id<CRMEntity> model = [[NSClassFromString([self className])alloc]init];
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

- (id<CRMEntity>)fromEntityXml:(GDataXMLNode *)entityXml
{
    id<CRMEntity> model = [[NSClassFromString([self className])alloc]init];
    if (model == nil) {
        return nil;
    }
    
    NSError *error;
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
    NSArray *keyValuePairs = [entityXml nodesForXPath:@"Contracts:Attributes/Contracts:KeyValuePairOfstringanyType" 
                                           namespaces:[self namespaces] 
                                                error:&error];
    if ([keyValuePairs count] > 0) {
        for (GDataXMLNode *attr in keyValuePairs) {
            
            NSString *key = [[[attr nodesForXPath:@"c:key" namespaces:[self namespaces] error:nil] objectAtIndex:0]stringValue];
            
            GDataXMLElement *value = [[attr nodesForXPath:@"c:value" namespaces:[self namespaces] error:nil] objectAtIndex:0];
            if (value) {
                GDataXMLNode *typeAttr = [value attributeForName:@"i:type"];
                if (typeAttr) {
                    NSString *type = [typeAttr stringValue];
                    
                    if ([type isEqualToString:@"b:EntityReference"]) {
                        
                        // It's possible that the child nodes aren't at the specified index
                        CRMEntityReference *ref = [[CRMEntityReference alloc]init];
                        [ref setId:[[value childAtIndex:0]stringValue]];
                        [ref setLogicalName:[[value childAtIndex:1]stringValue]];
                        [ref setName:[[value childAtIndex:2]stringValue]];
                        [attributes setValue:ref forKey:key];
                        continue;
                        
                    } else if ([type isEqualToString:@"b:OptionSetValue"]) {
                        
                        CRMOptionSet *val = [CRMOptionSet optionSetWithValue:[[[value childAtIndex:0]stringValue]intValue]];
                        [attributes setValue:val forKey:key]; continue;
                        
                    } else if ([type isEqualToString:@"d:int"]) {
                        
                        NSNumber *val = [NSNumber numberWithInt:[[value stringValue]intValue]];
                        [attributes setValue:val forKey:key]; continue;
                        
                    } else if ([type isEqualToString:@"d:double"] || [type isEqualToString:@"d:decimal"]) {
                        
                        NSNumber *val = [NSNumber numberWithDouble:[[value stringValue]doubleValue]];
                        [attributes setValue:val forKey:key]; continue;
                        
                    } else if ([type isEqualToString:@"d:boolean"]) {
                        
                        NSNumber *val = [NSNumber numberWithBool:[[value stringValue]boolValue]];
                        [attributes setValue:val forKey:key]; continue;
                        
                    } else if ([type isEqualToString:@"d:dateTime"]) {
                        
                        NSDate *date = [[self dateFormatter] dateFromString:[value stringValue]];
                        [attributes setValue:date forKey:key]; continue;
                        
                    } else {
                        [attributes setValue:[value stringValue] forKey:key]; continue; 
                    }
                } else {
                    [attributes setValue:[value stringValue] forKey:key]; continue;
                }
            }
            
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

+(NSDictionary *)getAttributesForClassName:(NSString *)className
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
    NSArray *excludedAttributes = [[NSArray alloc]initWithObjects:@"id", @"entityName", nil];
    
    id<CRMEntity> model = [[NSClassFromString(className) alloc]init];
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
    NSDictionary *attributes = [CRMEntityMapper getAttributesForClassName:NSStringFromClass([model class])];
    if ([attributes count] == 0) {
        NSLog(@"Warning: 0 attributes found for class '%@'.", NSStringFromClass([model class]));
        return nil;
    }
    
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
        NSRegularExpression *guidRegex = [[NSRegularExpression alloc]initWithPattern:@"^\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}$" options:0 error:nil];
        if ([[guidRegex matchesInString:value options:0 range:NSMakeRange(0, [value length])]count] > 0) {
            return [NSString stringWithFormat:@"<b:value i:type='c:guid' xmlns:c='http://schemas.microsoft.com/2003/10/Serialization/'>%@</b:value>", value];
        }
        return [NSString stringWithFormat:valueXml, @"string", value];
    } 
    
    if ([value isKindOfClass:[NSDate class]]) {
        return [NSString stringWithFormat:valueXml, @"dateTime", value];
    } 
    
    if ([value isKindOfClass:[NSNumber class]]) {
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
    } 
    
    if ([value isKindOfClass:[CRMEntityReference class]]) {
        return [NSString stringWithFormat:@""
                "<b:value i:type='a:EntityReference'>"
                "<a:Id>%@</a:Id>"
                "<a:LogicalName>%@</a:LogicalName>"
                "<a:Name i:nil='true'/>"
                "</b:value>", 
                [((CRMEntityReference*)value) id],
                [((CRMEntityReference*)value) logicalName]];
    }
    
    if ([value isKindOfClass:[CRMOptionSet class]]) {
        return [NSString stringWithFormat:@""
                "<b:value i:type='a:OptionSetValue'>"
                "<a:Value>%@</a:Value>"
                "</b:value>",
                [((CRMOptionSet*)value) value]];
    }
    
    return @"";
}

@end

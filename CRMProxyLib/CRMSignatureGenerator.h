//
//  CRMSignatureGenerator.h
//  SignatureGenerationPrototype
//
//  Created by Steven Oxley on 4/18/12.
//  Copyright (c) 2012 Sonoma Partners, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface CRMSignatureGenerator : NSObject

- (NSString *)hashTimestampXml:(NSData *)xmlBytes;
- (GDataXMLElement *)createTimestampNodeWithId:(NSString *)id atTime:(NSDate *)time;
- (GDataXMLElement *)createSignatureNodeWithId:(NSString *)id andReferenceData:(NSData *)referenceData andKeyData:(NSData *)keyData andKeyInfoReference:(NSString *)keyInfoReference;

@end

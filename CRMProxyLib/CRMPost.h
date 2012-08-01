
#import <Foundation/Foundation.h>
#import "CRMEntity.h"
#import "CRMEntityReference.h"

@interface CRMPost : NSObject <CRMEntity>
@property (nonatomic, strong) CRMEntityReference* createdby;
@property (nonatomic, strong) NSDate* createdon;
@property (nonatomic, strong) CRMEntityReference* createdonbehalfby;
@property (nonatomic, strong) CRMEntityReference* modifiedby;
@property (nonatomic, strong) NSDate* modifiedon;
@property (nonatomic, strong) CRMEntityReference* modifiedonbehalfby;
@property (nonatomic, strong) CRMEntityReference* organizationid;
@property (nonatomic, strong) Guid* postid;
@property (nonatomic, strong) CRMEntityReference* postregardingid;
@property (nonatomic, strong) CRMEntityReference* regardingobjectid;
@property (nonatomic, strong) NSObject* regardingobjectownerid;
@property (nonatomic, strong) CRMEntityReference* regardingobjectowningbusinessunit;
@property (nonatomic, strong) CRMOptionSet* source;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) NSNumber* timezoneruleversionnumber;
@property (nonatomic, strong) CRMOptionSet* type;
@property (nonatomic, strong) NSNumber* utcconversiontimezonecode;
@end

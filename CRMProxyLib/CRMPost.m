#import "CRMPost.h"

@implementation CRMPost
@synthesize createdby = _createdby;
@synthesize createdon = _createdon;
@synthesize createdonbehalfby = _createdonbehalfby;
@synthesize modifiedby = _modifiedby;
@synthesize modifiedon = _modifiedon;
@synthesize modifiedonbehalfby = _modifiedonbehalfby;
@synthesize organizationid = _organizationid;
@synthesize postid = _postid;
@synthesize postregardingid = _postregardingid;
@synthesize regardingobjectid = _regardingobjectid;
@synthesize regardingobjectownerid = _regardingobjectownerid;
@synthesize regardingobjectowningbusinessunit = _regardingobjectowningbusinessunit;
@synthesize source = _source;
@synthesize text = _text;
@synthesize timezoneruleversionnumber = _timezoneruleversionnumber;
@synthesize type = _type;
@synthesize utcconversiontimezonecode = _utcconversiontimezonecode;

-(NSString *)entityName
{
    return @"post";
}

-(NSString *)id
{
    return _postid;
}
@end

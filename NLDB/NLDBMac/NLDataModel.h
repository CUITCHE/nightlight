//
//  NLDataModel.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <tuple>
#import "constraints.h"
#import "NLSqlFunctionPackage.h"

using std::make_tuple;
using std::tuple;


NS_ASSUME_NONNULL_BEGIN

// Constraints Defines
// A property can be defined on rule which descriped: [(_primary_key|_foreign_key), (_default,_check,_null)]

@protocol _primary_key <NSObject>
@end

@protocol _foreign_key <NSObject>
@end

@protocol _null <NSObject>
@end

@protocol _check <NSObject>
@end

@protocol _default <NSObject>
@end

// Constraints Implementation
@protocol ForeignKey <_foreign_key>
+ (tuple<Class, NSString *>)confirmForeignKeyConnectToKey:(NSString *)propertyName;
@end

@protocol Check <_check>
+ (NSString *)confirmCheckConstraintsConnectToKey:(NSString *)propertyName;
@end

@protocol Default <_default>
+ (id)confirmDefaultConstraintsConnectToKey:(NSString *)propertyName;
@end


// Create Control
@protocol _ignore <NSObject>
@end


typedef NS_ENUM(NSUInteger, NLDBStringType) {
    NLDBStringTypeMutable = 1,
    NLDBStringTypeImmutable = 1 << 1,

    NLDBStringTypeChar = NLDBStringTypeImmutable,
    NLDBStringTypeVarchar = NLDBStringTypeMutable,
    NLDBStringTypeUnicodeChar = NLDBStringTypeChar | (1 << 2),
    NLDBStringTypeUnicodeVarchar = NLDBStringTypeVarchar | (1 << 3),

    NLDBStringTypePureText = 1 << 16
};

#ifndef NLDBTable
#define NLDBTable(table) @protocol __##table##__ <NSObject> @end
#endif

@protocol NLDataModel <ForeignKey, Check, Default>
@optional

/**
 To confirm string type which can be 'char','varchar','nchar','nvarchar' or 'text'.
 This is an optional method. Indicating 'text' type if this method is not be implemented.

 @param propertyName A property name of data model and its type is guaranteed to be is NSString or its subclass.
 @return A tuple which at 0 is string type and at 1 is string size. If tuple 0 position is NLDBStringTypePureText,
 the string size will be ignored.
 */
+ (tuple<NLDBStringType, NSUInteger>)confirmNSStringSizeConnectsToKey:(NSString *)propertyName;

/**
 To confirm a table name for this model. Subclass can override it. This is an optional method,
 you also choose to declare table name by protocol. See below for detail.

 @note Default implementation is return nil in NLDataModel. If return nil and no table name by protocol declare way, will trigger an exception.

 @return A table name
 */
+ (NSString *)confirmTableName;

/**
 To confirm concern type for NSNumber object. If this method is not be impletmented, will be deemed to double type.
 
 @param propertyName A property name of data model.
 @return A type-coding which you can get it by using \@encode(type). e.g. \@encode(float)
 */
+ (const char *)confirmNSNumberTypeConnectsToKey:(NSString *)propertyName;

@end

@interface NLDataModel : NSObject <NLDataModel>

@property (nonatomic, strong) NSNumber *rowid;

@end


/******************************************************** DEMO ********************************************************/
/*
 If a subclass of NSLDataModel follow a protocol like '__protocolName__', '__protocolName__' is a table name of the 
 subclass data model. And the table name can be wrote anywhere in protocol declare field.
 */

NLDBTable(demo)


@interface NLDBDataModelDemo : NLDataModel <__demo__>

@property (nonatomic, strong) NSString<_primary_key> *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger age;
@property (nonatomic, strong) NSNumber<_foreign_key, _check> *courseId;
@property (nonatomic, strong) NSString<_check> *gender;
@property (nonatomic, strong) NSString<_default> *way;
@property (nonatomic, strong) NSDate<_default> *startDateTime;
@property (nonatomic, strong) NSString<_null> *note;
@property (nonatomic) float speed;

@end

NS_ASSUME_NONNULL_END

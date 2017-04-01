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
// A property can be defined on rule which descriped: [(_primary_key|_foreign_key), (_default|_check|_null)]


/**
 Specifing after field property to indicate a PRIMARY KEY. This will trigger a method in which ForeignKey protocol will be
 invoked.
 */
@protocol _primary_key <NSObject>
@end

/**
 Specifing after field property to indicate a FOREIGN KEY. This will trigger a method in which ForeignKey protocol will be
 invoked.
 */
@protocol _foreign_key <NSObject>
@end


/**
 Specifing after field property to indicate that the field could be NULL.
 */
@protocol _null <NSObject>
@end

/**
 Specifing after field property to indecate that the field has a check statement. This will trigger a method in which 
 Check protocol will be invoked.
 */
@protocol _check <NSObject>
@end

/**
 Specifing after field property to indecate that the field has a default statement. This will trigger a method in which
 Default protocol will be invoked.
 */
@protocol _default <NSObject>
@end

/************************************** Constraints Implementation **************************************/

@protocol ForeignKey <_foreign_key>
@optional

/**
 To confirm foreign key(property name) which connects to. The NLDB will check the field of table class whether exists or
 not. If not, will trigger an exception.

 @param propertyName A property name of data model.
 @return A tuple contains outter table class and target field property name.
 */
+ (tuple<Class, NSString *>)confirmForeignKeyConnectToKey:(NSString *)propertyName;
@end

@protocol Check <_check>
@optional

/**
 To confirm check statement after field which connects to. You can use constraints class to genrate check statement, such
 as 
 @code
    return constraints().feild(@"gender").in(@[@"男", @"女"]);
 @endcode
 constraints is a C++ object and converts to NSString object automatly. So you can return constraints for NSString *

 @param propertyName A property name of data model.
 @return A check statement string.
 */
+ (NSString *)confirmCheckConstraintsConnectToKey:(NSString *)propertyName;
@end

@protocol Default <_default>
@optional

/**
 To confirm a defualt statement after field which connects to. The NLDB will check the method's return.

 @note Excepted NSString, NSNumber, NSData, NSDate. Their or subclasses objects. Especially, You could
 use NLSqlFunctionPackage to indicate a SQLite function like 'DATETIME()'.

 @param propertyName A property name of data model.
 @return A default value of the specified field.
 */
+ (id)confirmDefaultConstraintsConnectToKey:(NSString *)propertyName;
@end

/************************************** Create Control **************************************/

/**
 Specifing after field property to indicate that the field requests be ignore.
 */
@protocol _ignore <NSObject>
@end

@protocol Ignore <_ignore>
@optional

/**
 To confirm a property whether is ignored or not.

 @param propertyName A property name of data model.
 @return YES if requests ignore, otherwise is NO.
 */
+ (BOOL)confirmWhetherIgnoreProperty:(NSString *)propertyName;

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

/*
 If a subclass of NSLDataModel follow a protocol like '__protocolName__', '__protocolName__' is a table name of the
 subclass data model. And the table name can be wrote anywhere in protocol declare field.
 */

@protocol __table__ <NSObject>

@end

#ifndef NLDBTable
#define NLDBTable(table) @protocol __##table##__ <__table__> @end
#endif

@protocol NLDataModel <ForeignKey, Check, Default, Ignore>
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

@property (class, nonatomic, strong) NSDateFormatter *dateformatter;

@end


NS_ASSUME_NONNULL_END

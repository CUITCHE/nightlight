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
+ (condition)confirmCheckConstraintsConnectToKey:(NSString *)propertyName;
@end

@protocol Default <_default>
+ (id)confirmDefaultConstraintsConnectToKey:(NSString *)propertyName;
@end


// Create Control
@protocol _ignore <NSObject>
@end

@interface NLDataModel : NSObject

@property (nonatomic) NSNumber *rowid;


/**
 To confirm a table name for this model. Subclass can override it. This is an optional method, 
 you also choose declare table name by protocol. See below for detail.
 
 @note Default implementation is return nil.

 @return A table name
 */
+ (NSString *)confirmTableName;

@end

/**** DEMO ****/
/*
 If a subclass of NSLDataModel follow a protocol like '__protocolName__', '__protocolName__' is a table name of the 
 subclass data model. And the table name can be wrote anywhere in protocol declare field.
 */

#ifndef NLDBTable
#define NLDBTable(table) @protocol __##table##__ <NSObject> @end
#endif

NLDBTable(demo)


@interface NLDBDataModelDemo : NLDataModel <ForeignKey, Check, Default, __demo__>

@property (nonatomic, strong) NSString<_primary_key> *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger age;
@property (nonatomic, strong) NSNumber<_foreign_key, _check> *courseId;
@property (nonatomic, strong) NSString<_check> *gender;
@property (nonatomic, strong) NSString<_default> *way;
@property (nonatomic, strong) NSDate<_default> *startDateTime;
@property (nonatomic, strong) NSString<_null> *note;

@end

NS_ASSUME_NONNULL_END

//
//  NLDataModel+__InternalDataDefines.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NLDBHandler;

@interface NLDataModel (__InternalDataDefines)

@property (nonatomic, strong) NLDBHandler *databaseHanlder;
@property (nonatomic, strong) NSMutableDictionary *propertyDiffer;

@end

NS_ASSUME_NONNULL_END

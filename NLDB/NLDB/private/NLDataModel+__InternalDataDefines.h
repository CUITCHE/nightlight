//
//  NLDataModel+__InternalDataDefines.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel.h"

@class NLDBHandler;

@interface NLDataModel (__InternalDataDefines)

@property (nonatomic, strong) NLDBHandler *databaseHanlder;
@property (nonatomic, strong) NSMutableDictionary *propertyDiffer;

@end

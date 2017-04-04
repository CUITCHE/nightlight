//
//  NSArray+NLDataModelDML.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/3.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NLDBHandler;

@interface NSArray (NLDataModelDML)

- (BOOL)insert;
- (BOOL)insertCongenerModelWithDatabase:(NLDBHandler *)db;

@end

//
//  WordsToImageTests.m
//  WordsToImageTests
//
//  Created by hejunqiu on 2017/4/7.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WordsToImage.h"
#import <Base/String.hpp>

using namespace _cc;

@interface WordsToImageTests : XCTestCase

@end

@implementation WordsToImageTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    auto filepath = "/tmp/wi.bmp"_s;
    auto code_filepatch = "/usr/local/include/pcap-bpf.h"_s;
    WordsImageConvertor convertor(*code_filepatch);
    convertor.saveAs(*filepath);
}

@end

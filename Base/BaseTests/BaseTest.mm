//
//  BaseTest.m
//  BaseTest
//
//  Created by hejunqiu on 2017/3/9.
//  Copyright © 2017年 CHE. All rights reserved.
//

#include "BufferInternal.h"
#include <iostream>
#import <XCTest/XCTest.h>
#include <string>

using namespace _CC;
using namespace std;

@interface BaseTest : XCTestCase

@end

@implementation BaseTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConstructor {
    // default
    BufferInternal str;
    XCTAssertEqual(str.length(), 0);
    XCTAssertEqual(str.capacity(), sizeof(uinteger) * 2);
    XCTAssert(str.isEmpty());
    XCTAssertEqual(str.refcnt(), 1);

    // c-str
    BufferInternal str1("Hello World. Yo~~ yo");
    XCTAssertEqual(str1.length(), 20);
    XCTAssertEqual(str1.refcnt(), 1);

    // range
    string str2("435389fewfw23 da ee23r \fer 43=");
    BufferInternal str3(str2.begin(), str2.end());
    for (uinteger i=0; i<str2.length(); ++i) {
        XCTAssertEqual(str2.at(i), str3.at(i));
    }

    // fill
    BufferInternal str4('a', 10);
    for (auto c : str4) {
        XCTAssertEqual(c, 'a');
    }

    // move
    BufferInternal str5(std::move(str4));
    XCTAssertEqual(str4.refcnt(), 1);
    XCTAssertEqual(str5.length(), 10);
    XCTAssertThrows(str4.resize(10), @"Should throw exception");
}

- (void)testSize {
    BufferInternal str("dku32qr94u3u ferwr7493deawi3 302309we09831babfs03423");
    XCTAssertEqual(str.length(), 52);
    str.resize(60);
    XCTAssertEqual(str.length(), 60);
    for (int i=61; i<50+61; i++) {
        str.resize(i);
        XCTAssertEqual(str.length(), i);

    }
    const char *p1 = str.data();
    str.resize(41);
    XCTAssertEqual(str.length(), 41);
    XCTAssertEqual(p1, str.data());

    str.resize(0);
    XCTAssertEqual(str.begin(), str.end());
    XCTAssert(str.isEmpty(), @"Should be empty.");
}

- (void)testClear {
    BufferInternal str("fdsf 32r 34gtg rt\br\0ergre\0");
    auto p1 = str.data();
    str.clear();
    XCTAssertEqual(p1, str.data());
    str.resize(8345);
    str.clear();
    XCTAssertLessThan(str.capacity(), 8345);
}

- (void)testRandomAccess {
    BufferInternal str("2435cbjkef fweruh348y f34qhrio34hffnrewfhio34");
    XCTAssertEqual(str[6], 'j');
    XCTAssertThrows(str[100]);
    XCTAssertEqual(str.back(), '4');
    XCTAssertEqual(str.front(), '2');
}

- (void)testAppend {
    BufferInternal str("acdr34");
    BufferInternal temp("xxoXX");
    str.append(temp);
    XCTAssert(str == "acdr34xxoXX");

    str.append("23da");
    XCTAssert(str == "acdr34xxoXX23da");
    // fill
    str.append('-', 5);
    XCTAssert(str == "acdr34xxoXX23da-----");

    // push back
    str.push_back('x');
    XCTAssert(str == "acdr34xxoXX23da-----x");

    str.push_back('\0');
    str.push_back('A');
    cout << str << endl;
}

- (void)testAppendSubString {
    BufferInternal str("543e23efcew");
    BufferInternal temp("1234567890");
    str.append(temp, Range(2, 4));
    XCTAssert(str == "543e23efcew3456");

    XCTAssertThrows(str.append(temp, Range(0, temp.length() + 1)), @"Should throw an exception");
}

- (void)testInsert {
    BufferInternal str("1234567890");

    // first insert
    str.insert(0, BufferInternal("23"));
    XCTAssert(str == "231234567890");
    // last insert
    str.insert(str.length(), "111");
    XCTAssert(str == "231234567890111");
    // mid(2) insert
    str.insert(4, "00");
    XCTAssert(str == "23120034567890111");
    // mid(3) insert
    str.insert(5, "abc");
    XCTAssert(str == "23120abc034567890111");
    // fill insert
    str.clear();
    str.insert(0, 11, 'a');
    XCTAssert(str == "aaaaaaaaaaa");
    str.insert(1, 3, 'b');
    XCTAssert(str == "abbbaaaaaaaaaa");
    str.insert(str.length(), 3, 'c');
    XCTAssert(str == "abbbaaaaaaaaaaccc");
    // iterator insert
    str.insert(str.begin().base(), 't');
    XCTAssert(str == "tabbbaaaaaaaaaaccc");
    auto e = str.insert(str.end().base(), 't');
    XCTAssert(str == "tabbbaaaaaaaaaaccct");
    XCTAssertEqual(e, str.end() - 1);
}

- (void)testErase {
    BufferInternal str("1234567890");
    str.erase(Range(0,3));
    XCTAssert(str == "4567890");

    str.erase(Range(1, 2));
    XCTAssert(str == "47890");

    str.erase(str.begin().base() + 2);
    XCTAssert(str == "4790");
}

- (void)testReplace {
    BufferInternal _str("123xxx45678aa90");
    BufferInternal temp1("AAAAA");
    BufferInternal temp2("BBBBBB");
    BufferInternal str(_str);
    str.replace(Range(3, 3), temp1);
    XCTAssert(str == "123AAAAA45678aa90");

    str = _str;
    str.replace(Range(13, 2), temp2);
    XCTAssert(str == "123xxx45678aaBBBBBB");

    str = _str;
    str.replace(Range(10, 2), temp2);
    XCTAssert(str == "123xxx4567BBBBBBa90");
}

- (void)testPopBack {
    BufferInternal str("1232443655ddewf");
    auto len = str.length();
    auto c = str.pop_back();
    XCTAssert(c == 'f');
    XCTAssertEqual(len, str.length() + 1);
}

- (void)testUTF8String {
    BufferInternal str("12324354fewwe");
    XCTAssert(!strcmp(str.UTF8String(), "12324354fewwe"));
}

- (void)testCopy {
    BufferInternal str("12345678900");
    {
        char copy[5] = {0};
        XCTAssertEqual(str.copy(copy, Range(0, 2)), 2);
        XCTAssert(!strcmp(copy, "12"));
    }
    {
        char copy[5] = {0};
        XCTAssertEqual(str.copy(copy, Range(8, 7)), 3);
        XCTAssert(!strcmp(copy, "900"));
    }
}

- (void)testCompare {
    BufferInternal str("abcewru349lfcew");
    BufferInternal str2("abcewru349mfcew");
    XCTAssert(str.compare(str2) == ComparisonResult::Ascending);

    {
        BufferInternal str("abcewru349lfcew");
        BufferInternal str2("abcewru349Lfcew");
        XCTAssert(str.caseInsensitiveCompare(str2) == ComparisonResult::Same);
    }
}

@end

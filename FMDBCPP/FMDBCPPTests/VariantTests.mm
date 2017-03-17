//
//  VariantTests.m
//  FMDB-CPP
//
//  Created by hejunqiu on 2017/2/17.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "Variant.hpp"
#include "Date.hpp"

using namespace FMDB_CPP;
using namespace std;

@interface VariantTests : XCTestCase
{
    vector<Variant> _data;
}

@end

@implementation VariantTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _data.clear();
    _data.reserve(20);
    _data.emplace_back();
    _data.emplace_back(true);
    _data.emplace_back('x');
    _data.emplace_back((unsigned char)0xf0);
    _data.emplace_back(0x40000022);
    _data.emplace_back(0x80000023);
    _data.emplace_back(24.54f);
    _data.emplace_back(2.0);
    _data.emplace_back(0x35ll);
    _data.emplace_back(0xf320ull);
    _data.emplace_back("123");
    _data.emplace_back(string());
    _data.emplace_back(VariantData());
    _data.emplace_back(Date::dateWithTimeIntervalSinceReferenceDate(TimeInterval(2158304)));
    _data.emplace_back(VariantVector());
    _data.emplace_back(VariantMap());
    _data.emplace_back(VariantMapIntKey());
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConstructor_Type
{
    Variant v0(false);
    XCTAssertEqual(v0.getType(), Variant::Type::BOOLEAN, @"Wrong type.");

    Variant v1('x');
    XCTAssertEqual(v1.getType(), Variant::Type::CHAR, @"Wrong type.");

    Variant v2((unsigned char)0xF0);
    XCTAssertEqual(v2.getType(), Variant::Type::BYTE, @"Wrong type.");

    Variant v3(0x40000022);
    XCTAssertEqual(v3.getType(), Variant::Type::INTEGER, @"Wrong type.");

    Variant v4(0x80000023);
    XCTAssertEqual(v4.getType(), Variant::Type::UINTEGER, @"Wrong type.");

    Variant v5(24.54f);
    XCTAssertEqual(v5.getType(), Variant::Type::FLOAT, @"Wrong type.");

    Variant v6(2.0);
    XCTAssertEqual(v6.getType(), Variant::Type::DOUBLE, @"Wrong type.");

    Variant v7(0x35ll);
    XCTAssertEqual(v7.getType(), Variant::Type::LONGLONG, @"Wrong type.");

    Variant v8(0xf320ull);
    XCTAssertEqual(v8.getType(), Variant::Type::ULONGLONG, @"Wrong type.");

    Variant v9("");
    XCTAssertEqual(v9.getType(), Variant::Type::CSTRING, @"Wrong type.");

    Variant v10((VariantData()));
    XCTAssertEqual(v10.getType(), Variant::Type::DATA, @"Wrong type.");

    Variant v11((Date()));
    XCTAssertEqual(v11.getType(), Variant::Type::DATE, @"Wrong type.");

    Variant v12((string()));
    XCTAssertEqual(v12.getType(), Variant::Type::STRING, @"Wrong type.");

    Variant v13((VariantVector()));
    XCTAssertEqual(v13.getType(), Variant::Type::VARIANTVECTOR, @"Wrong type.");

    Variant v14((VariantMap()));
    XCTAssertEqual(v14.getType(), Variant::Type::VARIANTMAP, @"Wrong type.");

    Variant v15((VariantMapIntKey()));
    XCTAssertEqual(v15.getType(), Variant::Type::VARIANTMAPINTKEY, @"Wrong type.");

    Variant v16;
    XCTAssertEqual(v16.getType(), Variant::Type::NONE, @"Wrong type.");
}

- (void)test_none_convert
{
    auto &tmp = _data[0];
    // test convert string which can convert.
    XCTAssertEqual(tmp.toString(), "(null)", @"Should be '(null)'");
    XCTAssertEqual(string(tmp.toCString()), "(null)", @"Should be '(null)'");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_bool_convert
{
    auto &tmp = _data[1]; // true
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), 1, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), 1, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), 1, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), 1, @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), 1.f, @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), 1.0, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), 1ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), 1ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "true", @"Wrong convert.");
    XCTAssertEqual(tmp.toDate(), Date::dateWithTimeIntervalSince1970(TimeInterval(1)),
                   @"Wrong convert. tmp(%s) - test(%s)", tmp.toDate().description().c_str(), Date::dateWithTimeIntervalSince1970(TimeInterval(1)).description().c_str());

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_char_convert
{
    auto &tmp = _data[2]; // 'x'
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), 'x', @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), 'x', @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), 'x', @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), 'x', @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), 'x', @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), 'x', @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), 'x', @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), 'x', @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "x", @"Wrong convert.");
    XCTAssertEqual(tmp.toDate(), Date::dateWithTimeIntervalSince1970(TimeInterval('x')), @"Wrong convert.");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_byte_convert
{
    auto &tmp = _data[3]; // 0xf0
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), (char)0xf0, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), 0xf0, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), 0xf0, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), 0xf0, @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), 0xf0, @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), 0xf0, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), 0xf0, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), 0xf0, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), string(1, (char)0xf0), @"Wrong convert. tmp(%s) - test(%s)", tmp.toString().c_str(), string(1, (char)0xf0).c_str());
    XCTAssertEqual(tmp.toDate(), Date::dateWithTimeIntervalSince1970(TimeInterval(0xf0)), @"Wrong convert.");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_int_convert
{
    auto &tmp = _data[4]; // 0x40000022
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), (char)0x40000022, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), (unsigned char)0x40000022, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), 0x40000022, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), 0x40000022, @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), 0x40000022, @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), 0x40000022, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), 0x40000022, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), 0x40000022, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "1073741858", @"Wrong convert.");
    XCTAssertEqual(tmp.toDate(), Date::dateWithTimeIntervalSince1970(TimeInterval(0x40000022)), @"Wrong convert.");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_uint_convert
{
    auto &tmp = _data[5]; // 0x80000023
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), (char)0x80000023, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), (unsigned char)0x80000023, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), 0x80000023, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), 0x80000023, @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), 0x80000023, @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), 0x80000023, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), 0x80000023, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), 0x80000023, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "2147483683", @"Wrong convert.");
    XCTAssertEqual(tmp.toDate(), Date::dateWithTimeIntervalSince1970(TimeInterval(0x80000023)), @"Wrong convert.");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_float_convert
{
    auto &tmp = _data[6]; // 24.54f
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), (char)24.54f, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), (unsigned char)24.54f, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), (int)24.54f, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), (unsigned int)24.54f, @"Wrong convert.");
    XCTAssertLessThan(tmp.toFloat() - 24.54f, 0.0001, @"Wrong convert.");
    XCTAssertLessThan(tmp.toDouble() - 24.54f, 0.0001, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), (long long)24.54f, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), (unsigned long long)24.54f, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "24.54", @"Wrong convert.");
    XCTAssertEqual(tmp.toDate(), Date::dateWithTimeIntervalSince1970(TimeInterval(24.54f)), @"Wrong convert.");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_double_convert
{
    auto &tmp = _data[7]; // 2.0
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), (char)2.0, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), (unsigned char)2.0, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), (int)2.0, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), (unsigned int)2.0, @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), (float)2.0, @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), 2.0, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), (long long)2.0, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), (unsigned long long)2.0, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "2", @"Wrong convert. tmp(%s)", tmp.toString().c_str());
    XCTAssertEqual(tmp.toDate(), Date::dateWithTimeIntervalSince1970(TimeInterval(2.0)), @"Wrong convert.");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_longlong_convert
{
    auto &tmp = _data[8]; // 0x35ll
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), 0x35ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), 0x35ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), 0x35ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), 0x35ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), 0x35ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), 0x35ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), 0x35ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), 0x35ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "53", @"Wrong convert.");
    XCTAssertEqual(tmp.toDate(), Date::dateWithTimeIntervalSince1970(TimeInterval(0x35ll)), @"Wrong convert.");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_unsignedlonglong_convert
{
    auto &tmp = _data[9]; // 0xf320ull
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), (char)0xf320ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), (unsigned char)0xf320ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), 0xf320ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), 0xf320ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), 0xf320ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), 0xf320ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), 0xf320ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), 0xf320ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "62240", @"Wrong convert.");
    XCTAssertEqual(tmp.toDate(), Date::dateWithTimeIntervalSince1970(TimeInterval(0xf320ull)), @"Wrong convert.");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_cstring_convert
{
    auto &tmp = _data[10]; // "123"
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), 123, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), 123, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), 123, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), 123, @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), 123.f, @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), 123.0, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), 123ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), 123ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "123", @"Wrong convert.");
    auto d1 = tmp.toDate();
    auto d2 = Date::dateFromString("123");
    XCTAssertEqual(d1, d2, @"Wrong convert. tmp(%s) - test(%s)", d1.description().c_str(), d2.description().c_str());

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_string_convert
{
    auto &tmp = _data[11]; // ""
    // test convert string which can convert.
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), 0, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), 0, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), 0, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), 0, @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), 0, @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), 0, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), 0ll, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), 0ull, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "", @"Wrong convert.");
    XCTAssertEqual(tmp.toDate(), Date::dateFromString(""), @"Wrong convert.");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_date_convert
{
    auto &tmp = _data[13]; // dateWithTimeIntervalSinceReferenceDate(TimeInterval(2158304))
    // test convert string which can convert.
    double countDateSeconds = TimeIntervalSince1970.count() + 2158304;
    XCTAssertEqual(tmp.toBool(), true, @"Wrong convert.");
    XCTAssertEqual(tmp.toChar(), (char)countDateSeconds, @"Wrong convert.");
    XCTAssertEqual(tmp.toByte(), (unsigned char)countDateSeconds, @"Wrong convert.");
    XCTAssertEqual(tmp.toInt(), (int)countDateSeconds, @"Wrong convert.");
    XCTAssertEqual(tmp.toUInt(), (unsigned int)countDateSeconds, @"Wrong convert.");
    XCTAssertEqual(tmp.toFloat(), (float)countDateSeconds, @"Wrong convert.");
    XCTAssertEqual(tmp.toDouble(), (double)countDateSeconds, @"Wrong convert.");
    XCTAssertEqual(tmp.toLongLong(), (long long)countDateSeconds, @"Wrong convert.");
    XCTAssertEqual(tmp.toULongLong(), (unsigned long long)countDateSeconds, @"Wrong convert.");
    XCTAssertEqual(tmp.toString(), "Fri Jan 26 2001 07:31:44 +0800", @"Wrong convert. %s", tmp.toString().c_str());
    XCTAssertEqual(tmp.toDate(), Date::dateWithTimeIntervalSinceReferenceDate(TimeInterval(2158304)), @"Wrong convert.");

    // test convert or not.
    XCTAssertFalse(tmp.convert(Variant::Type::NONE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BOOLEAN), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::CHAR), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::BYTE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::INTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::UINTEGER), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::FLOAT), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DOUBLE), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::LONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::ULONGLONG), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::STRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::CSTRING), @"Should be converted.");
    XCTAssertFalse(tmp.convert(Variant::Type::DATA), @"Should not be converted.");
    XCTAssertTrue(tmp.convert(Variant::Type::DATE), @"Should not be converted.");
}

- (void)test_movement_constructor
{
    // test static c type string.
    Variant var1("123");
    Variant var2(std::move(var1));
    XCTAssert(var1.getType() == Variant::Type::NONE, @"Wrong type!");
    XCTAssertEqual(var2.toString(), "123", @"move failure.");

    Variant var3((VariantVector()));
    auto p3 = var3.toVariantVector().data();
    Variant var4(std::move(var3));
    XCTAssertEqual(p3, var4.toVariantVector().data(), @"move failure");
}
@end

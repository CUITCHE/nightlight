# NLDB

Mapping the data model to the SQL statement.



# Basic Use

Just create a model class inherits from NLDataModel.

```objective-c
NLDBTable(course)

@interface CHDBCourseDataModel : NLDataModel <__course__>

@property (nonatomic, strong) NSNumber<_primary_key> *id;

@property (nonatomic) NSInteger field0;

@end
```

- **A class corresponds to a table**. From above, 'course' which combines 2 underlines on left-right side(`__course__`) represents table name. You can also override method `+ (NSString *)confirmTableName;` to return table name. Both are good.
- You can specify a property with protocols, such as `_primary_key`, `_foreign_key`, etc to represent that a property is 'PRIMARY KEY', 'FOREIGN KEY', etc on database.

NLDataModel will generate a SQL statement:

```sql lite
CREATE TABLE course (id INTEGER PRIMARY KEY NOT NULL,field0 BIGINT NOT NULL)
```



## DDL

- Generating FMDatabase object. see [NLDataModel+DDL.h](./NLDB/category/NLDataModel+DDL.h) for more details.
- Waiting for adding.

## DML

- SELECT data and make it to be NLDataModel instance with condtion (see [NLCondition](./NLDB/sqlBuild/NLCondtion.h) for more details).
- UPDATE data with condition. All automatic increasement fields are ignored.
- INSERT data to database. All automatic increasement fields are ignored.

**note:** To execute DML operation, a NLDataModel object must create by contructor methods under [NLDataModel+DML.h](./NLDB/category/NLDataModel+DML.h).

# Supported Data Type of Property 

- All basic types, such as int ,float, long, etc.
- NSNumber, NSString(NSMutableString), NSData(NSMutableData), NSDate, NSDecimalNumber.

Especially, NSDecimalNumber is stored as blob.

# NLCondtion

Call NLCondtion's methods by chaining.

We suggest that use condition() to construct a NLCondtion object.

# Requirement

- [FMDB](https://github.com/ccgus/fmdb)
<img src="./banner.png" height=140 alt="banner image" />

# 🐘 forge-postgres

Are you a hackooor? Do you use Forge for stuff it's not meant for? Then this
plugin is for you! 

Presenting — forge-postgres. A postgres driver (?) for Forge scripts. 

This plugin lets you connect to a postgres db directly via Forge, execute
queries and read values into native types — all in beautiful, idiomatic Solidity.

## 📋 Requirements

- This plugin requires you to run your scripts with `ffi` turned on
- Postgres not included

## ⚙️ Installation

It's forge!

```console
$ forge install tudmotu/forge-postgres
```

## 📝 Usage

The API is somewhat similar to bindings from other languages such as Java JDBC
API. It supports placeholders and reading values into native types.

### Connections

First, create a connection object:
```solidity
import { Connection, Postgres } from 'forge-postgres/Postgres.sol';

Connection memory conn = Postgres.connect({
    user: 'postgres',
    passwd: 'password',
    host: '127.0.0.1:5432',
    database: 'postgres'
});
```

### Queries

A simple query can be executed directly with a string literal:

```solidity
import { Record } from 'forge-postgres/Postgres.sol';

conn.execute('create table abc (id decimal, name text)');
Record[] memory records = conn.execute('select * from abc');
```

### Statements

A parameterized query can be executed using a `Statement` object:

```solidity
import { Statement } from 'forge-postgres/Postgres.sol';

conn.execute('create table abc (id decimal, name text)');

Statement memory statement = conn.createStatement(
    'insert into abc (id, name) values ($1, $2)'
);

statement.addDecimalParam(6969);
statement.addTextParam('tudmotu');

conn.execute(statement);
```

You can also invoke `.prepare()` to see the generated query.

### Records

Queries return an array of `Record` elements. Each `Record` object represents a
row in the result set. You can read the values in each column using the `.readX`
methods. See the full API below.

```solidity
Record[] memory records = conn.execute('select id, name from abc');
string memory name = records[0].readString(1);
```

### Structs

You can even kinda read/write structs using the `bytea` type in postgres:

```solidity
struct Profile {
    uint[] friendIds;
    uint balance;
}

conn.execute('create table users (username text, profile bytea)');

Profile memory profile;
uint[] memory ids = new uint[](2);
ids[0] = 420;
ids[1] = 1337;
profile.friendIds = ids;
profile.balance = 10 ether;

bytes memory profileBytes = abi.encode(profile);

Statement memory statement = conn.createStatement(
    'insert into test2 (username, profile) values ($1, $2)'
);

statement.addTextParam('tudmotu');
statement.addByteaParam(profileBytes);
conn.execute(statement);

Record[] memory records = conn.execute('select * from users');

Profile memory dbProfile = abi.decode(
    records[0].readBytes(1),
    (Profile)
);
```

## 🌐 API

### Postgres
```solidity
function connect (
    string memory username,
    string memory passwd,
    string memory host,
    string memory database
) returns (Connection memory);
```

### Connection
```solidity
function execute (
    string memory query
) returns (Record[] memory);

function execute (
    Statement memory statement
) public returns (Record[] memory);

function createStatement (
    string memory query
) returns (Statement memory);
```

### Statement
```solidity
function addDecimalParam (uint value);
function addBigIntParam (uint64 value);
function addIntParam (uint32 value);
function addTextParam (string memory value);
function addByteaParam (bytes memory value);
function addBooleanParam (bool value);
function prepare ();
```

### Record
```solidity
function readString (uint columnIndex);
function readBytes (uint columnIndex);
function readAddress (uint columnIndex);
function readUint (uint columnIndex);
function readInt (uint columnIndex);
function readBytes32 (uint columnIndex);
function readBool (uint columnIndex);
```

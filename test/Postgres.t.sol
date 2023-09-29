// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {
    Postgres,
    Connection,
    DBType,
    Statement,
    Record
} from "../src/Postgres.sol";
import { Strings } from "../src/util/strings.sol";

contract PostgresTest is Test {
    struct Profile {
        uint[] friendIds;
        uint balance;
    }

    function setUp() public { }

    function connection() public pure returns (Connection memory) {
        return Postgres.connect(
            'postgres',
            'password',
            '127.0.0.1',
            'postgres'
        );
    }

    function testStatementWithDoubleDigitParamCount() public {
        Connection memory conn = connection();
        Statement memory statement = conn.createStatement('($1, $10)');
        for (uint i = 0; i < 10; i++) {
            statement.addParam(2 ** i);
        }
        assertEq(statement.prepare(), "('1', '512')");
    }

    function testReadAllTypes() public {
        Connection memory conn = connection();
        conn.execute('drop table if exists alltypes');
        conn.execute(string.concat(
            'create table alltypes \n',
            '(a text, b bytea, c text, d decimal, e int, f bytea, g boolean)'
        ));

        Statement memory statement = conn.createStatement(string.concat(
            'insert into alltypes (a, b, c, d, e, f, g) values \n',
            '($1, $2, $3, $4, $5, $6, $7)'
        ));

        statement.addTextParam('tudmotu');
        statement.addByteaParam(hex'01020304');
        statement.addTextParam(vm.toString(address(this)));
        statement.addDecimalParam(type(uint).max);
        statement.addIntParam(100000);
        statement.addByteaParam(abi.encodePacked("testing"));
        statement.addBooleanParam(true);

        conn.execute(statement);

        Record[] memory records = conn.execute('select * from alltypes');
        assertEq(records[0].readString(0), 'tudmotu');
        assertEq(records[0].readBytes(1), hex'01020304');
        assertEq(records[0].readAddress(2), address(this));
        assertEq(records[0].readUint(3), type(uint).max);
        assertEq(records[0].readInt(4), 100000);
        assertEq(records[0].readBytes32(5), "testing");
        assertEq(records[0].readBool(6), true);
    }

    function testInsertBytea() public {
        Connection memory conn = connection();
        conn.execute('drop table if exists test2');
        conn.execute('create table test2 (username text, profile bytea)');

        Profile memory profile;
        uint[] memory ids = new uint[](2);
        ids[0] = 0;
        ids[1] = 1;
        profile.friendIds = ids;
        profile.balance = 10 ether;

        bytes memory profileBytes = abi.encode(profile);

        Statement memory statement = conn.createStatement(
            'insert into test2 (username, profile) values ($1, $2)'
        );
        statement.addTextParam('tudmotu');
        statement.addByteaParam(profileBytes);
        conn.execute(statement);

        Record[] memory records = conn.execute('select * from test2');
        assertEq(records[0].readString(0), 'tudmotu');
        Profile memory dbProfile = abi.decode(
            records[0].readBytes(1),
            (Profile)
        );
        assertEq(dbProfile.balance, 10 ether);
        assertEq(dbProfile.friendIds[0], 0);
        assertEq(dbProfile.friendIds[1], 1);

        conn.execute('drop table test2');
    }

    function testInsertStringsInt() public {
        Connection memory conn = connection();
        conn.execute('drop table if exists test1');
        conn.execute('create table test1 (username text, followers int)');

        Statement memory statement = conn.createStatement(
            'insert into test1 (username, followers) values ($1, $2), ($3, $4)'
        );
        statement.addTextParam('test1');
        statement.addIntParam(520);
        statement.addTextParam('test2');
        statement.addIntParam(20);

        conn.execute(statement);

        Record[] memory records = conn.execute('select * from test1');
        assertEq(records[0].readString(0), 'test1');
        assertEq(records[0].readInt(1), 520);
        assertEq(records[1].readString(0), 'test2');
        assertEq(records[1].readInt(1), 20);

        conn.execute('drop table test1');
    }
}

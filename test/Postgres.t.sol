// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {
    Postgres,
    Connection,
    DBType,
    Statement,
    StatementLib
} from "../src/Postgres.sol";
import { Strings } from "../src/util/strings.sol";

contract PostgresTest is Test {
    struct Profile {
        uint[] friendIds;
        uint balance;
    }

    function setUp() public { }

    function conn() public pure returns (Connection memory connection) {
        connection = Postgres.connect(
            'postgres',
            'password',
            '127.0.0.1',
            'postgres'
        );
    }

    function testInsertBytea() public {
        conn().execute('drop table if exists test2');
        conn().execute('create table test2 (username text, profile bytea)');

        Profile memory profile;
        uint[] memory ids = new uint[](2);
        ids[0] = 0;
        ids[1] = 1;
        profile.friendIds = ids;
        profile.balance = 10 ether;

        bytes memory profileBytes = abi.encode(profile);

        Statement memory statement = StatementLib.from(
            'insert into test2 (username, profile) values ($1, $2)'
        );
        statement.addTextParam('tudmotu');
        statement.addByteaParam(profileBytes);
        conn().execute(statement);

        string[][] memory records = conn().execute('select * from test2');
        assertEq(records[0][0], 'tudmotu');
        Profile memory dbProfile = abi.decode(
            vm.parseBytes(Strings.beyond(records[0][1], '\\x')),
            (Profile)
        );
        assertEq(dbProfile.balance, 10 ether);
        assertEq(dbProfile.friendIds[0], 0);
        assertEq(dbProfile.friendIds[1], 1);

        conn().execute('drop table test2');
    }

    function testInsertStringsBigInt() public {
        conn().execute('drop table if exists test1');
        conn().execute('create table test1 (username text, followers bigint)');

        Statement memory statement = StatementLib.from(
            'insert into test1 (username, followers) values ($1, $2), ($3, $4)'
        );
        statement.addTextParam('test1');
        statement.addBigIntParam(uint(520));
        statement.addTextParam('test2');
        statement.addBigIntParam(uint(20));

        conn().execute(statement);

        string[][] memory records = conn().execute('select * from test1');
        assertEq(records[0][0], 'test1');
        assertEq(records[0][1], '520');
        assertEq(records[1][0], 'test2');
        assertEq(records[1][1], '20');

        conn().execute('drop table test1');
    }
}

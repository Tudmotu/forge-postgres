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

contract PostgresTest is Test {

    function setUp() public { }

    function conn() public pure returns (Connection memory connection) {
        connection = Postgres.connect(
            'postgres',
            'password',
            '127.0.0.1',
            'postgres'
        );
    }

    function testInsertAndRead() public {
        conn().execute('create table test (username text, followers bigint)');

        Statement memory statement = StatementLib.from(
            'insert into test (username, followers) values ($1, $2), ($3, $4)'
        );
        statement.addParam(DBType.TEXT, "test1");
        statement.addParam(DBType.BIGINT, vm.toString(uint(520)));
        statement.addParam(DBType.TEXT, "test2");
        statement.addParam(DBType.BIGINT, vm.toString(uint(20)));

        conn().execute(statement);

        string[][] memory records = conn().execute('select * from test');
        assertEq(records[0][0], "test1");
        assertEq(records[0][1], "520");
        assertEq(records[1][0], "test2");
        assertEq(records[1][1], "20");

        conn().execute('drop table test');
    }
}

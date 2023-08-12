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

    function testRead() public {
        conn().execute('drop table if exists test');
        conn().execute('create table test (username text, followers bigint)');
        Statement memory statement = StatementLib.from(
            'insert into test (username, followers) values ($1, $2)'
        );
        statement.addParam(DBType.TEXT, "the dude");
        statement.addParam(DBType.BIGINT, vm.toString(uint(520)));
        conn().execute(statement);

        bytes memory res = conn().execute('select * from test');
        console2.log(string(res));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {
    Connection
} from './Connection.sol';
import './DBType.sol';
import './Statement.sol';

library Postgres {
    function connect (
        string memory username,
        string memory passwd,
        string memory host,
        string memory database
    ) public pure returns (Connection memory conn) {
        conn = Connection(username, passwd, host, database);
    }
}

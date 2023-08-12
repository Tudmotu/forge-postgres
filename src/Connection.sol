// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Vm } from 'forge-std/Vm.sol';
import { console2 } from 'forge-std/Test.sol';
import { DBType } from './DBType.sol';
import { Statement, StatementLib } from './Statement.sol';

struct Connection {
    string username;
    string passwd;
    string host;
    string database;
}

library ConnectionLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function connURL (Connection memory self) internal pure returns (string memory url) {
        url = string.concat(
            "postgres://",
            self.username,
            ":",
            self.passwd,
            "@",
            self.host,
            "/",
            self.database
        );
    }

    function _execute (
        Connection memory self,
        Statement memory statement
    ) internal returns (bytes memory data) {
        string[] memory inputs = new string[](4);
        inputs[0] = 'psql';
        inputs[1] = self.connURL();
        inputs[2] = '-c';
        inputs[3] = statement.prepare();
        data = vm.ffi(inputs);
    }

    function execute (
        Connection memory self,
        string memory query
    ) public returns (bytes memory data) {
        data = self._execute(StatementLib.from(query));
    }

    function execute (
        Connection memory self,
        Statement memory statement
    ) public returns (bytes memory data) {
        data = self._execute(statement);
    }
}

using ConnectionLib for Connection global;

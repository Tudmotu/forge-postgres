// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Vm } from 'forge-std/Vm.sol';
import './strings.sol';

library Files {
    using Strings for string;

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function generate () internal returns (string memory filename) {
        string[] memory args = new string[](3);
        args[0] = 'python';
        args[1] = '-c';
        args[2] = 'import random; print(random.randint(0, 2**20))';
        string memory rand = vm.toString(vm.ffi(args)).beyond('0x');
        filename = string.concat(
            vm.projectRoot(), '/.forge/tmp/fp.', rand, '.sql'
        );
    }
}

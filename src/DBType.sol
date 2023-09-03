// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Strings } from './util/strings.sol';

enum DBType {
    BIGINT,
    INT,
    DECIMAL,
    TEXT,
    TIMESTAMP,
    DATETIME,
    BYTEA,
    BOOLEAN
}

library DBTypeLib {
    using Strings for string;

    function serialize (
        DBType self,
        string memory value
    ) internal pure returns (string memory strValue) {
        if (
            self == DBType.TEXT ||
            self == DBType.DECIMAL
        ) {
            strValue = string.concat("\'", value, "\'");
        }
        else if (self == DBType.BYTEA) {
            strValue = string.concat("'\\x", value.beyond("0x"), "'");
        }
        else {
            strValue = value;
        }
    }
}

using DBTypeLib for DBType global;

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Strings } from './util/strings.sol';

enum DBType {
    BIGINT,
    LONG,
    INT,
    TEXT,
    TIMESTAMP,
    DATETIME,
    BYTEA
}

library DBTypeLib {
    using Strings for string;

    function serialize (
        DBType self,
        string memory value
    ) internal pure returns (string memory strValue) {
        if (self == DBType.BIGINT) {
            strValue = value;
        }
        else if (self == DBType.LONG) {
            strValue = value;
        }
        else if (self == DBType.INT) {
            strValue = value;
        }
        else if (self == DBType.TEXT) {
            strValue = string.concat("\'", value, "\'");
        }
        else if (self == DBType.BYTEA) {
            strValue = string.concat("decode('", value.beyond("0x"), "', 'hex')");
        }
    }
}

using DBTypeLib for DBType global;

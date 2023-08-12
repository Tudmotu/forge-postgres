// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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
    }
}

using DBTypeLib for DBType global;

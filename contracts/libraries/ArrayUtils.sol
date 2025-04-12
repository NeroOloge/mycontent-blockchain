// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 < 0.9.0;

import "../Blogging.sol";

library ArrayUtils {
    function compareStrings(string memory _a, string memory _b) internal pure returns(bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    function findIndex(string[] memory list, string memory element) internal pure returns (int i) {
        for (uint idx = 0; idx < list.length; idx++) {
            if (compareStrings(list[idx], element)) return int(idx);
        }
        return -1;
    }

    function findIndex(Blogging.Post[] memory list, string memory element) internal pure returns (int i) {
        for (uint idx = 0; idx < list.length; idx++) {
            if (compareStrings(list[idx].cid, element)) return int(idx);
        }
        return -1;
    }

    function findIndex(address[] memory list, address element) internal pure returns (int i) {
        for (uint idx = 0; idx < list.length; idx++) {
            if (list[idx] == element) return int(idx);
        }
        return -1;
    }

    function findIndex(Blogging.Comment[] storage list, string memory element) internal view returns (int i) {
        for (uint idx = 0; idx < list.length; idx++) {
            if (compareStrings(list[idx].cid, element)) return int(idx);
        }
        return -1;
    }

    function removeElementByIndex(string[] storage list, int _index) internal returns (bool) {
        require(_index < int(list.length));
        require(_index >= 0, "Element doesn't exist");

        for (uint i = uint(_index); i < list.length - 1; i++) {
            list[i] = list[i + 1];
        }
        list.pop();

        return true;
    }

    function removeElementByIndex(address[] storage list, int _index) internal returns (bool) {
        require(_index < int(list.length));
        require(_index >= 0, "Element doesn't exist");

        for (uint i = uint(_index); i < list.length - 1; i++) {
            list[i] = list[i + 1];
        }
        list.pop();

        return true;
    }
    
    function removeElementByIndex(Blogging.Post[] storage list, int _index) internal returns (bool) {
        require(_index < int(list.length));
        require(_index >= 0, "Element doesn't exist");

        for (uint i = uint(_index); i < list.length - 1; i++) {
            list[i] = list[i + 1];
        }
        list.pop();

        return true;
    }

    function removeElementByIndex(Blogging.Comment[] storage list, int _index) internal returns (bool) {
        require(_index < int(list.length));
        require(_index >= 0, "Element doesn't exist");

        for (uint i = uint(_index); i < list.length - 1; i++) {
            list[i] = list[i + 1];
        }
        list.pop();

        return true;
    }
    
    function sliceArray(string[] memory array, uint256 start, uint256 end) internal pure returns (string[] memory) {
        string[] memory slicedArray = new string[](end - start);
        for (uint i = start; i < end; i++) {
            slicedArray[i] = array[start + i];
        }
        return slicedArray;
    }

    function sliceArray(Blogging.Post[] memory array, uint256 start, uint256 end) internal pure returns (Blogging.Post[] memory) {
        Blogging.Post[] memory slicedArray = new Blogging.Post[](end - start);
        for (uint i = start; i < end; i++) {
            slicedArray[i] = array[start + i];
        }
        return slicedArray;
    }

    function reverseArray(Blogging.Post[] memory array) internal pure returns (Blogging.Post[] memory) {
        Blogging.Post[] memory reversedArray = new Blogging.Post[](array.length);
        for (uint256 i = 0; i < array.length; i++) {
            reversedArray[array.length - 1 - i] = array[i];
        }
        return reversedArray;
    }

    function reverseArray(Blogging.Comment[] storage array) internal view returns (Blogging.Comment[] memory) {
        Blogging.Comment[] memory reversedArray = new Blogging.Comment[](array.length);
        for (uint256 i = 0; i < array.length; i++) {
            reversedArray[array.length - 1 - i] = array[i];
        }
        return reversedArray;
    }
}
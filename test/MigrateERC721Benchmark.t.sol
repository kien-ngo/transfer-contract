// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {MigrateERC721} from "../src/MigrateERC721.sol";

// Test imports
import {Wallet} from "../utils/Wallet.sol";
import "../utils/BaseTest.sol";

contract MigrateERC721BenchmarkTest is BaseTest {
    MigrateERC721 internal migrate;

    Wallet internal tokenOwner;

    address _recipient = getActor(uint160(0));

    uint256[] internal _contentsOne;
    uint256[] internal _contentsTwo;

    uint256 countOne;
    uint256 countTwo;

    function setUp() public override {
        super.setUp();

        migrate = MigrateERC721(getContract("MigrateERC721"));

        tokenOwner = getWallet();

        erc721.mint(address(tokenOwner), 1500);
        tokenOwner.setApprovalForAllERC721(
            address(erc721),
            address(migrate),
            true
        );

        countOne = 1000;
        countTwo = 200;

        for (uint256 i = 0; i < countOne; i++) {
            _contentsOne.push(i);
        }

        for (uint256 i = countOne; i < countOne + countTwo; i++) {
            _contentsTwo.push(i);
        }
    }

    /*///////////////////////////////////////////////////////////////
                        Benchmark: MigrateERC721
    //////////////////////////////////////////////////////////////*/

    function test_benchmark_migrateERC721_migrate() public {
        vm.pauseGasMetering();
        vm.prank(deployer);
        vm.resumeGasMetering();
        migrate.migrate(
            address(erc721),
            address(tokenOwner),
            _recipient,
            _contentsOne
        );
    }
}

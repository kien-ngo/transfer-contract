// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {MigrateERC721} from "../src/MigrateERC721.sol";

// Test imports
import {Wallet} from "../utils/Wallet.sol";
import "../utils/BaseTest.sol";

contract MigrateERC721Test is BaseTest {
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
                        Unit tests: stateless migrate
    //////////////////////////////////////////////////////////////*/

    function test_state_migrate() public {
        vm.prank(deployer);
        migrate.migrate(
            address(erc721),
            address(tokenOwner),
            _recipient,
            _contentsOne
        );

        for (uint256 i = 0; i < 1000; i++) {
            assertEq(erc721.ownerOf(i), _recipient);
        }
    }

    // function test_revert_migrate_notOwner() public {
    //     vm.prank(address(25));
    //     vm.expectRevert("Not authorized.");
    //     migrate.migrate(address(erc721), address(tokenOwner), _recipient, _contentsOne);
    // }

    function test_revert_migrate_notApproved() public {
        tokenOwner.setApprovalForAllERC721(
            address(erc721),
            address(migrate),
            false
        );

        vm.startPrank(deployer);
        vm.expectRevert("Not owner or approved");
        migrate.migrate(
            address(erc721),
            address(tokenOwner),
            _recipient,
            _contentsOne
        );
        vm.stopPrank();
    }
}

contract MigrateERC721GasTest is BaseTest {
    MigrateERC721 internal migrate;

    Wallet internal tokenOwner;

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

        vm.startPrank(address(tokenOwner));
    }

    /*///////////////////////////////////////////////////////////////
                        Unit tests: gas benchmarks, etc.
    //////////////////////////////////////////////////////////////*/

    function test_safeTransferFrom_toEOA() public {
        erc721.safeTransferFrom(address(tokenOwner), address(0x123), 0);
    }

    function test_safeTransferFrom_toContract() public {
        erc721.safeTransferFrom(address(tokenOwner), address(this), 0);
    }

    function test_safeTransferFrom_toEOA_gasOverride() public {
        console.log(gasleft());
        erc721.safeTransferFrom{gas: 100_000}(
            address(tokenOwner),
            address(0x123),
            0
        );
        console.log(gasleft());
    }

    function test_safeTransferFrom_toContract_gasOverride() public {
        console.log(gasleft());
        erc721.safeTransferFrom{gas: 100_000}(
            address(tokenOwner),
            address(this),
            0
        );
        console.log(gasleft());
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

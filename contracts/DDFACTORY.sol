// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/MinimalForwarderUpgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./DDERC721.sol";

contract DDFACTORY is
    Initializable,
    OwnableUpgradeable,
    ERC2771ContextUpgradeable
{
    struct GENERATED_CONTRACT {
        string contract_type;
        string contract_version;
        string contract_name;
        address contract_address;
        address contract_creator;
    }

    string public VERSION;
    address public IMPLEMENTATION;
    // address private immutable _trustedForwarder;

    address[] public GENERATED_CONTRACTS;
    mapping(address => GENERATED_CONTRACT[]) USER_CONTRACTS;

    event newContractCreated(GENERATED_CONTRACT newContract);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(MinimalForwarderUpgradeable trustedForwarder)
        ERC2771ContextUpgradeable(address(trustedForwarder))
    {
        _disableInitializers();
    }

    function initialize(string memory _version, address _implementation)
        public
        initializer
    {
        __Ownable_init();

        VERSION = _version;
        IMPLEMENTATION = _implementation;
    }

    function createDDERC721(
        string memory _name,
        string memory _symbol,
        string memory _customContractURI,
        address _proxy
    ) external payable {
        DDERC721 newDDERC721 = DDERC721(Clones.clone(IMPLEMENTATION));

        newDDERC721.initialize(
            _name,
            _symbol,
            _msgSender(),
            _customContractURI,
            _proxy
        );

        address caddress = address(newDDERC721);

        USER_CONTRACTS[_msgSender()].push(
            GENERATED_CONTRACT("ERC721", VERSION, _name, caddress, _msgSender())
        );
        GENERATED_CONTRACTS.push(caddress);

        emit newContractCreated(
            GENERATED_CONTRACT("ERC721", VERSION, _name, caddress, _msgSender())
        );
    }

    function setImplementation(address _newImplementation) public onlyOwner {
        IMPLEMENTATION = _newImplementation;
    }

    function getUserContracts(address owner_)
        public
        view
        returns (GENERATED_CONTRACT[] memory)
    {
        return USER_CONTRACTS[owner_];
    }

    function getContractCount() public view returns (uint256) {
        return GENERATED_CONTRACTS.length;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;

        AddressUpgradeable.sendValue(payable(owner()), balance);
    }

    function _msgSender()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return super._msgData();
    }
}

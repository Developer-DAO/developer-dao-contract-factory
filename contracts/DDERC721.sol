// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/MinimalForwarderUpgradeable.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract DDERC721 is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable,
    ERC2771ContextUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    CountersUpgradeable.Counter private _tokenIdCounter;

    string public customContractURI;
    address proxyRegistryAddress;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(MinimalForwarderUpgradeable trustedForwarder)
        ERC2771ContextUpgradeable(address(trustedForwarder))
    {
        _disableInitializers();
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        address _owner,
        string memory _customContractURI,
        address _proxyRegistryAddress
    ) public initializer {
        __ERC721_init(_name, _symbol);
        __ERC721URIStorage_init();
        __Pausable_init();
        __Ownable_init();
        __AccessControl_init();
        __ERC721Burnable_init();

        _transferOwnership(_owner);

        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(PAUSER_ROLE, _owner);
        _grantRole(MINTER_ROLE, _owner);

        customContractURI = _customContractURI;
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address to, string[] memory uris)
        public
        onlyRole(MINTER_ROLE)
    {
        uint256 count = uris.length;
        uint256 tokenId = _tokenIdCounter.current();

        for (uint256 i = 0; i < count; i++) {
            string memory metadataURL = uris[i];

            _tokenIdCounter.increment();
            _safeMint(to, tokenId);
            _setTokenURI(tokenId, metadataURL);
        }
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // URI HANDLING

    function setContractURI(string memory customContractURI_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        customContractURI = customContractURI_;
    }

    function contractURI() public view returns (string memory) {
        return customContractURI;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {
        // if OpenSea's ERC721 Proxy Address is detected, auto-return true
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);

        if (address(proxyRegistry.proxies(_owner)) == _operator) {
            return true;
        }

        // otherwise, use the default ERC721.isApprovedForAll()
        return super.isApprovedForAll(_owner, _operator);
    }

    // Emergency withdraw (in case someone sends ether or donations to the contract)
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;

        AddressUpgradeable.sendValue(payable(msg.sender), balance);
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

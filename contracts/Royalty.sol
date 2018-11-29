pragma solidity 0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
import './Managed.sol';
import './Cashier.sol';

contract Royalty is ERC721Token, Managed {

    DigitalAsset[] public digitalAssets;

    struct DigitalAsset {
        uint256 priceInEthers;

    }

    event DigitalAssetRegistered(
        address indexed owner,
        uint256 digitalAssetId,
        uint256 registeredAt,
        string uri
    );

    constructor(address _management)
        public
        ERC721Token('Royalty', 'ROYALTY')
        Managed(_management)
    {}

    function createDigitalAssets(
        uint256 _priceInEthers,
        string _uri,
        uint256 _dataGenerationTimestamp,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        payable
        requireNotContractSender()
    {
        require(
            msg.value == Management(management).assetRegistrationPrice(),
            ERROR_WRONG_AMOUNT
        );

        address recoveredAddress = verify(
            msg.sender,
            msg.value,
            _uri,
            _dataGenerationTimestamp,
            _v,
            _r,
            _s
        );
        require(
            hasPermission(recoveredAddress, CAN_SIGN_TRANSACTION),
            ERROR_ACCESS_DENIED
        );
        require(
            block.timestamp <= _dataGenerationTimestamp.add(
            Management(management).transactionDataExpirationPeriod()
        ),
            ERROR_NOT_AVAILABLE
        );
        uint256 digitalAssetId = createDigitalAssetInternal(
            msg.sender,
            _priceInEthers,
            _uri
        );

        emit DigitalAssetRegistered(
            msg.sender,
            digitalAssetId,
            block.timestamp,
            _uri
        );
    }

    function approve(address _to, uint256 _tokenId) public {
        _to = _to;
        _tokenId = _tokenId;
        require(false, ERROR_ACCESS_DENIED);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
    {
        _from = _from;
        _to = _to;
        _tokenId = _tokenId;
        require(false, ERROR_ACCESS_DENIED);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
    {
        _from = _from;
        _to = _to;
        _tokenId = _tokenId;
        require(false, ERROR_ACCESS_DENIED);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) public {
        _from = _from;
        _to = _to;
        _tokenId = _tokenId;
        _data = _data;
        require(false, ERROR_ACCESS_DENIED);
    }

    function getEtherPriceForAsset(uint256 _digitalAssetId)
        public
        view
        returns(uint256)
    {
        return digitalAssets[_digitalAssetId].priceInEthers;
    }

    function verify(
        address _owner,
        uint256 _amount,
        string _uri,
        uint256 _dataGenerationTimestamp,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        pure
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                _owner,
                _amount,
                _uri,
                _dataGenerationTimestamp
            )
        );

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        return ecrecover(
            keccak256(abi.encodePacked(prefix, hash)),
            _v,
            _r,
            _s
        );
    }

    function createDigitalAssetInternal(
        address _tokenOwner,
        uint256 _priceInEthers,
        string _uri
    )
        internal
        returns (uint256 digitalAssetId)
    {
        require(
            _tokenOwner != address(0) &&
            false == management.isContract(_tokenOwner),
            ERROR_ACCESS_DENIED
        );

        Cashier cashier = Cashier(management.contractRegistry(CONTRACT_CASHIER));
        cashier.forwardEthersToHolder.value(msg.value)();

        digitalAssetId = allTokens.length;
        _mint(_tokenOwner, digitalAssetId);
        _setTokenURI(digitalAssetId, _uri);
        digitalAssets.push(DigitalAsset(_priceInEthers));
    }
}
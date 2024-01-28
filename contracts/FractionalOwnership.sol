// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FractionalOwnership {
    // Struct to represent a real estate asset
    struct Asset {
        string name;
        string location;
        uint256 value;
        address owner;
        uint256 fractions;
    }

    // Mapping to store all assets by their ID
    mapping(uint256 => Asset) public assets;

    // Event to notify when a new asset is created
    event AssetCreated(uint256 assetId);

    // Modifier to check if the sender is the owner of an asset
    modifier onlyOwner(uint256 _assetId) {
        require(msg.sender == assets[_assetId].owner, "Only asset owner can call this function");
        _;
    }

    // Constructor to initialize sample assets for testing
    constructor() {
        createAsset("Sample Property 1", "Sample Location 1", 100 ether, 10);
        createAsset("Sample Property 2", "Sample Location 2", 150 ether, 15);
    }

    // Function to create a new asset
    function createAsset(
        string memory _name,
        string memory _location,
        uint256 _value,
        uint256 _fractions
    ) external {
        uint256 newAssetId = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        assets[newAssetId] = Asset({
            name: _name,
            location: _location,
            value: _value,
            owner: msg.sender,
            fractions: _fractions
        });
        emit AssetCreated(newAssetId);
    }

    // Function to buy a fraction of an asset
    function buyFraction(uint256 _assetId, uint256 _fractions) external payable {
        require(_fractions > 0 && _fractions <= assets[_assetId].fractions, "Invalid fraction amount");
        uint256 cost = (msg.value * _fractions) / assets[_assetId].fractions;
        require(msg.value >= cost, "Insufficient funds sent");
        assets[_assetId].owner.transfer(cost);
        assets[_assetId].fractions -= _fractions;
    }

    // Function to sell a fraction of an asset
    function sellFraction(uint256 _assetId, uint256 _fractions) external onlyOwner(_assetId) {
        require(_fractions > 0 && _fractions <= assets[_assetId].fractions, "Invalid fraction amount");
        uint256 value = (assets[_assetId].value * _fractions) / assets[_assetId].fractions;
        assets[_assetId].fractions -= _fractions;
        payable(msg.sender).transfer(value);
    }

    // Function to transfer a fraction of an asset to another address
    function transferFraction(uint256 _assetId, uint256 _fractions, address _to) external onlyOwner(_assetId) {
        require(_fractions > 0 && _fractions <= assets[_assetId].fractions, "Invalid fraction amount");
        assets[_assetId].fractions -= _fractions;
        assets[_assetId].owner = _to;
    }

    // Function to get details of an asset by its ID
    function getAsset(uint256 _assetId) external view returns (Asset memory) {
        return assets[_assetId];
    }

    // Function to get IDs of all assets
    function getAssets() external view returns (uint256[] memory) {
        uint256[] memory assetIds = new uint256[](assets.length);
        for (uint256 i = 0; i < assets.length; i++) {
            assetIds[i] = i;
        }
        return assetIds;
    }
}


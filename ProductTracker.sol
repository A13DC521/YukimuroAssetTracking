pragma solidity ^0.4.21;
 
contract AssetTracker {
    
    struct Asset {
        string producerName;
        string prunerName;
        string producingArea;
        string harvestDate;
        string shippingDate;
        string receptionDate;
        string issuanceDate;
        string inspectionDate1;
        string inspectionDate2;
        string inspectionDate3;
        bool pesticideUse;
        bool initialized;    
    }
    
    mapping(string => Asset) private assetStore;
    mapping(address => mapping(string => bool)) private walletStore;
    
    event AssetCreate(address account, string uuid, string producerName);
    event RejectCreate(address account, string uuid, string message);
    event AssetTransfer(address from, address to, string uuid);
    event RejectTransfer(address from, address to, string uuid, string message);
    
    function createAsset(string uuid, 
        string producerName,
        string prunerName,
        string producingArea,
        string harvestDate,
        string shippingDate,
        string receptionDate,
        string issuanceDate,
        string inspectionDate1,
        string inspectionDate2,
        string inspectionDate3,
        bool pesticideUse) public {
 
    if(assetStore[uuid].initialized) {
        emit RejectCreate(msg.sender, uuid, "Asset with this UUID already exists.");
        return;
      }
 
      assetStore[uuid] = Asset(producerName, prunerName, producingArea, harvestDate, shippingDate, receptionDate, issuanceDate, inspectionDate1, inspectionDate2, inspectionDate3, pesticideUse, true);

      walletStore[msg.sender][uuid] = true;
      emit AssetCreate(msg.sender, uuid, producerName);
    }
    
    function transferAsset(address to, string uuid) private{
 
    if(!assetStore[uuid].initialized) {
        emit RejectTransfer(msg.sender, to, uuid, "No asset with this UUID exists");
        return;
    }
 
    if(!walletStore[msg.sender][uuid]) {
        emit RejectTransfer(msg.sender, to, uuid, "Sender does not own this asset.");
        return;
    }
 
    walletStore[msg.sender][uuid] = false;
    walletStore[to][uuid] = true;
    emit AssetTransfer(msg.sender, to, uuid);
    }
    
    function getAssetByUUID1(string uuid) public constant returns (string, string, string, string, string) {
 
    return (assetStore[uuid].producerName, assetStore[uuid].prunerName, assetStore[uuid].producingArea, assetStore[uuid].harvestDate, assetStore[uuid].shippingDate);
 
    }
    
    function getAssetByUUID2(string uuid) public constant returns (string, string, string, string, string, bool) {
 
    return (assetStore[uuid].receptionDate, assetStore[uuid].issuanceDate, assetStore[uuid].inspectionDate1, assetStore[uuid].inspectionDate2, assetStore[uuid].inspectionDate3, assetStore[uuid].pesticideUse);
 
    }
    
    function isOwnerOf(address owner, string uuid) public constant returns (bool) {
 
    if(walletStore[owner][uuid]) {
        return true;
    }
 
    return false;
    }

}

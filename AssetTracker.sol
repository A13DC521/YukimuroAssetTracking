pragma solidity ^0.4.21;
 
contract AssetTracker {
    string id;
 
    function setId(string serial) public {
          id = serial;
    }
 
    function getId() public constant returns (string) {
          return id;
    }
    
    struct Asset {
    string name;
    string description;
    string manufacturer;
    bool initialized;    
    }
    
    mapping(string => Asset) private assetStore;
    mapping(address => mapping(string => bool)) private walletStore;
    
    event AssetCreate(address account, string uuid, string manufacturer);
    event RejectCreate(address account, string uuid, string message);
    event AssetTransfer(address from, address to, string uuid);
    event RejectTransfer(address from, address to, string uuid, string message);
    
    function createAsset(string name, string description, string uuid, string manufacturer) {
 
    if(assetStore[uuid].initialized) {
        RejectCreate(msg.sender, uuid, "Asset with this UUID already exists.");
        return;
      }
 
      assetStore[uuid] = Asset(name, description, manufacturer, true);

      walletStore[msg.sender][uuid] = true;
      AssetCreate(msg.sender, uuid, manufacturer);
    }
    
    function transferAsset(address to, string uuid) {
 
    if(!assetStore[uuid].initialized) {
        RejectTransfer(msg.sender, to, uuid, "No asset with this UUID exists");
        return;
    }
 
    if(!walletStore[msg.sender][uuid]) {
        RejectTransfer(msg.sender, to, uuid, "Sender does not own this asset.");
        return;
    }
 
    walletStore[msg.sender][uuid] = false;
    walletStore[to][uuid] = true;
    AssetTransfer(msg.sender, to, uuid);
    }
    
    function getAssetByUUID(string uuid) constant returns (string, string, string) {
 
    return (assetStore[uuid].name, assetStore[uuid].description, assetStore[uuid].manufacturer);
 
    }
    
    function isOwnerOf(address owner, string uuid) constant returns (bool) {
 
    if(walletStore[owner][uuid]) {
        return true;
    }
 
    return false;
    }

}

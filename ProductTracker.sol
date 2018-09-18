pragma solidity ^0.4.21;
 
contract ProductTracker {
    
    struct Producer {
        string signature;
        string fullName;
        string phoneNumber;
        string eMail;
        string uuid;
    }
    
    struct Product {
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
        string pesticideUse;
        bool initialized;    
    }
    
    Producer public registeredProducers;
    
    address[] public producersAccounts;
    
    mapping(address => Producer) public producers;
    mapping(string => Product) private productStore;
    mapping(address => mapping(string => bool)) private walletStore;
    
    event ProducerHistory(address indexed producer);
    event ProducerInfo(address producerAddress, string fullName, string phoneNumber, string eMail, string uuid);
    event ProductCreate(address account, string uuid, string producerName);
    event RejectCreate(address account, string uuid, string message);
    event ProductTransfer(address from, address to, string uuid);
    event RejectTransfer(address from, address to, string uuid, string message);
    event DigitalSignature(address addr);

    function addProducer(string _signature, string _fullName, string _phoneNumber, string _eMail, string _uuid) public {
        
        Producer storage producer = producers[msg.sender];

        for(uint i = 0; i < producersAccounts.length; i ++){
            if(msg.sender == producersAccounts[i]){
                producersAccounts[i] = producersAccounts[producersAccounts.length - 1];
                delete producersAccounts[i];
                delete producers[msg.sender];
                producersAccounts.length --;
            }
        }
        
        producer.signature = _signature;
        producer.fullName = _fullName;
        producer.phoneNumber = _phoneNumber;
        producer.eMail = _eMail;
        producer.uuid = _uuid;
        producersAccounts.push(msg.sender) - 1;
        
        emit ProducerHistory(msg.sender);
        emit ProducerInfo(msg.sender, _fullName, _phoneNumber, _eMail, _uuid);
    }
    
    function removeProducer(address _producerAddress) public {
        // Delete producer from struct and mapping
        for(uint i = 0; i < producersAccounts.length; i ++){
            if(_producerAddress == producersAccounts[i]){
                producersAccounts[i] = producersAccounts[producersAccounts.length - 1];
                delete producersAccounts[i];
                delete producers[_producerAddress];
                producersAccounts.length --;
            }
        }  
        emit ProducerHistory(_producerAddress);
    }
    
    function getAllProducers() view public returns(address[]) {
        return producersAccounts;
    }
    
    function getOneProducer(address _address) view public returns (string, string, string, string, string) {
        return (producers[_address].signature, producers[_address].fullName, producers[_address].phoneNumber, producers[_address].eMail, producers[_address].uuid);
    }
    
    function producersNumber() view public returns (uint) {
        return producersAccounts.length;
    }
    
    function createProduct(string uuid, 
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
        string pesticideUse) public {
 
    if(productStore[uuid].initialized) {
        emit RejectCreate(msg.sender, uuid, "A product with this UUID already exists.");
        return;
      }
 
      productStore[uuid] = Product(producerName, prunerName, producingArea, harvestDate, shippingDate, receptionDate, issuanceDate, inspectionDate1, inspectionDate2, inspectionDate3, pesticideUse, true);

      walletStore[msg.sender][uuid] = true;
      emit ProductCreate(msg.sender, uuid, producerName);
    }
    
    function transferProduct(address to, string uuid) public {
 
    if(!productStore[uuid].initialized) {
        emit RejectTransfer(msg.sender, to, uuid, "No product with this UUID exists");
        return;
    }
 
    if(!walletStore[msg.sender][uuid]) {
        emit RejectTransfer(msg.sender, to, uuid, "Sender does not own this product.");
        return;
    }
 
    walletStore[msg.sender][uuid] = false;
    walletStore[to][uuid] = true;
    emit ProductTransfer(msg.sender, to, uuid);
    }
    
    function getProductByUUID1(string uuid) public constant returns (string, string, string, string, string) {
 
    return (productStore[uuid].producerName, productStore[uuid].prunerName, productStore[uuid].producingArea, productStore[uuid].harvestDate, productStore[uuid].shippingDate);
 
    }
    
    function getProductByUUID2(string uuid) public constant returns (string, string, string, string, string, string) {
 
    return (productStore[uuid].receptionDate, productStore[uuid].issuanceDate, productStore[uuid].inspectionDate1, productStore[uuid].inspectionDate2, productStore[uuid].inspectionDate3, productStore[uuid].pesticideUse);
 
    }
    
    function isOwnerOf(address owner, string uuid) public constant returns (bool) {
 
        if(walletStore[owner][uuid]) {
            return true;
        }
 
        return false;
    }
    
    // Find out if the producer info is signed
    function isSigned(address _addr, bytes32 hash, uint8 v, bytes32 r, bytes32 s) constant returns(bool) {
        
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(prefix, hash);
        return ecrecover(prefixedHash, v, r, s) == (_addr);
    }

}

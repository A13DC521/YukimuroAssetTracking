pragma solidity ^0.4.21;
 
contract ProductTracker {
    
    struct Producer {
        string fullName;
        string phoneNumber;
        string eMail;
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
    event ProducerInfo(address producer, string fullName, string phoneNumber, string eMail);
    event ProductCreate(address account, string uuid, string producerName);
    event RejectCreate(address account, string uuid, string message);
    event ProductTransfer(address from, address to, string uuid);
    event RejectTransfer(address from, address to, string uuid, string message);
    event DigitalSignature(address addr);

    function addProducer(address _producer, string _fullName, string _phoneNumber, string _eMail) public {
        var producer = producers[_producer];
        uint index;
        for(uint i = 0; i < producersAccounts.length; i ++){
            if(_producer == producersAccounts[i]){
                index = i;
                
                producersAccounts[index] = producersAccounts[producersAccounts.length - 1];
                delete producersAccounts[index];
                delete producers[_producer];
                producersAccounts.length --;
            }
        }
        
        producer.fullName = _fullName;
        producer.phoneNumber = _phoneNumber;
        producer.eMail = _eMail;
        
        producersAccounts.push(_producer) - 1;
        emit ProducerHistory(_producer);
        emit ProducerInfo(_producer, _fullName, _phoneNumber, _eMail);
    }
    
    function removeProducer(address _producerAddress) public {
        uint index;
        for(uint i = 0; i < producersAccounts.length; i ++){
            if(_producerAddress == producersAccounts[i]){
                index = i;
            }
        }
        
        producersAccounts[index] = producersAccounts[producersAccounts.length - 1];
        delete producersAccounts[index];
        delete producers[_producerAddress];
        producersAccounts.length --;
        emit ProducerHistory(_producerAddress);
    }
    
    function getAllProducers() view public returns(address[]) {
        return producersAccounts;
    }
    
    function getOneProducer(address _address) view public returns (string, string, string) {
        return (producers[_address].fullName, producers[_address].phoneNumber, producers[_address].eMail);
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
    
    // Enable digital signature. Generate signature with JS
    function recoverAddress(bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public returns (address) {
        var lol = ecrecover(msgHash, v, r, s);
        emit DigitalSignature(lol);
        return ecrecover(msgHash, v, r, s);
    }
    
    function isSigned(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public returns (bool) {
        return ecrecover(msgHash, v, r, s) == _addr;
    }

}

pragma solidity ^0.8.0;


//[0xdfbe3e504ac4e35541bebad4d0e7574668e16fefa26cd4172f93e18b59ce9486,0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb,0x04a10bfd00977f54cc3450c9b25c9b3a502a089eba0097ba35fc33c4ea5fcb54],2,0x99cb2fb7f676790a4f453c6cc7e1ed262c4727e9,1
contract socialwallet {
    
    bytes32[] public guardianAddrHashes;
    address public owner;
    address public owner2;
    uint256 public lastOwnedTime;
    bool isCompromised = false;
    uint256 public nonce;
    uint public saveOwnerNonce = 9999999999;
    uint public chainId;
    mapping(bytes32 => bool) public isGuardian;
    mapping(bytes32 => address) public guardianVote2;
    address[] public previousOwners;
    int public votesOwner1;
    int public votesOwner2;
    uint public votesForOwner2Change;
    address agreedOwner2;
    uint public cantChangeOwner2;
    
    constructor(bytes32[] memory _guardianAddrHashes, uint256 _threshold, address _owner2, uint _chainId) {
        require(_threshold <= _guardianAddrHashes.length, "threshold too high");
        guardianAddrHashes = _guardianAddrHashes;

        for(uint i = 0; i < guardianAddrHashes.length; i++) {
            require(!isGuardian[guardianAddrHashes[i]], "duplicate guardian");
            isGuardian[guardianAddrHashes[i]] = true;
            guardianVote2[guardianAddrHashes[i]] = _owner2;

        }

        owner = msg.sender;
        owner2 = _owner2;
        lastOwnedTime = block.timestamp;
        chainId = _chainId;
        previousOwners[0] = _owner2;
    }

modifier onlyOwner {
        require(msg.sender == owner, "only owner");
        _;
    }

modifier onlyGuardian {
        require(isGuardian[keccak256(abi.encodePacked(msg.sender))], "only guardian");
        _;
    }


function voteForOwner2Change(address _newOwner2) public onlyGuardian {
    guardianVote2[keccak256(abi.encodePacked(msg.sender))] = _newOwner2;
    
}

function changeOwner2ByGuardianVote() public {
    agreedOwner2 = guardianVote2[guardianAddrHashes[0]];
    
    for(uint i = 0; i < guardianAddrHashes.length; i++) {
            if (guardianVote2[guardianAddrHashes[i]] == agreedOwner2){
                votesForOwner2Change = votesForOwner2Change + 1;
            }
              
        }
    if (votesForOwner2Change == guardianAddrHashes.length){

            for(uint i = 0; i < previousOwners.length; i++) {
            if (previousOwners[i] == agreedOwner2){
                cantChangeOwner2 = 1;
            }
            }
            
            if (cantChangeOwner2 == 0){
            owner2 = agreedOwner2; 
            previousOwners[previousOwners.length] = agreedOwner2;
            }
    }
    votesForOwner2Change = 0;
    cantChangeOwner2 = 0;

    
}


function saveOwner2(address _newOwner2) public onlyOwner {
   require(block.timestamp > lastOwnedTime + 10000);
   owner2 = _newOwner2;
     
}

function saveOwners(address _newOwner, address _newOwner2,bytes memory _signature) public onlyOwner {
   if (verify(owner2,saveOwnerNonce,chainId,_signature) == true){
   owner = _newOwner;
   owner2 = _newOwner2;
   saveOwnerNonce = saveOwnerNonce + 1;
   }
     
}




function receive() public payable{

}

function test() public returns (uint256) {
    return (guardianAddrHashes.length);
}


function submitTransaction2 (
        address _to, bytes memory data, uint256 _value, bytes memory _signature
    ) public payable onlyOwner { 
    if (verify(owner2,nonce,chainId,_signature) == true){
    
    lastOwnedTime = block.timestamp;
    
    nonce = nonce + 1;

    _to.call{value: _value}(data);
    
    }
    }

function getAccountHash(
        address _address
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_address));
    }




/* Signature Verification

How to Sign and Verify
# Signing
1. Create message to sign
2. Hash the message
3. Sign the hash (off chain, keep your private key secret)

# Verify
1. Recreate hash from the original message
2. Recover signer from signature and hash
3. Compare recovered signer to claimed signer
*/

    /* 1. Unlock MetaMask account
    ethereum.enable()
    */

    /* 2. Get message hash to sign
    getMessageHash(
        0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C,
        123,
        "coffee and donuts",
        1
    )

    hash = "0xcf36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd"
    */
    function getMessageHash(
        uint _nonce,
        uint _chainId
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_nonce,_chainId));
    }

    /* 3. Sign message hash
    # using browser
    account = "copy paste account of signer here"
    ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log)

    # using web3
    web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

    Signature will be different for different accounts
    0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    /* 4. Verify signature
    signer = 0xB273216C05A8c0D4F0a4Dd0d7Bae1D2EfFE636dd
    to = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
    amount = 123
    message = "coffee and donuts"
    nonce = 1
    signature =
        0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */
    function verify(
        address _signer,
        uint _nonce,
        uint _chainId,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_nonce,_chainId);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

}

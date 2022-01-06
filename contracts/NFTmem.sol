// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

// for hardhat
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTmem {
    using SafeMath for uint256;
    address payable owner;

    struct influencer{
        uint id;
        address ad;
        string name;
        string gmail;
        address collectionAddress;
    }

    struct person
    {
        uint id;
        address ad;
        string name;
        string gmail;
        address[5][] collectionsOwned;
        // mapping( address=> bool[5] ) collectionsOwned;
    }

    mapping (address=> person) people;
    uint peopleCount;
    mapping (address=> influencer) influencers;
    address[] influencerArray;
    mapping (address => bool) isInfluencer;
    // onlyOwner
    function addInfulencer(address _ad, uint256 _id, string memory _name, string memory _gmail) public  {
        influencerArray.push(_ad);
        isInfluencer[_ad] = true;
        influencers[_ad].id = _id;
        influencers[_ad].gmail = _gmail;
        influencers[_ad].ad = _ad;
        influencers[_ad].name = _name;
    }

    modifier onlyInfluencer(address _ad) {
        require(isInfluencer[_ad] == true, "Not an influencer");
        _;
    }

    function addUser(string memory _name ,string memory _gmail) public {
        people[msg.sender].name=_name;
        people[msg.sender].gmail=_gmail;
        people[msg.sender].id=peopleCount;
        people[msg.sender].ad=msg.sender;
        peopleCount++;
    }

    
    function getUser(address _ad) public view returns(person memory){
        return people[_ad];
    }
    

// onlyInfluencer
    function deployCollection(address account,string memory uri) public  returns(address){
        // modifier - for registered influncer 
        influencers[account].collectionAddress = address( new NFT(uri));
        return influencers[account].collectionAddress;
    }

    function mint(address influencerAddress, uint id) public {
      address CollectionAddress =  getCollectionAddress(influencerAddress);
    NFT(CollectionAddress).mint(msg.sender,id,1,"");
    uint l = people[msg.sender].collectionsOwned[id].length;
    // todo
    // people[msg.sender].collectionsOwned[id][l] = CollectionAddress;

    }
    
    function getCollectionAddress(address influencerAddress) public view returns(address){
        return address(NFT(influencers[influencerAddress].collectionAddress));
    }

    function getIronBalance(address a) public view returns(uint){
      return NFT(influencers[a].collectionAddress).getBalance(a,4);
    }
    
    function getSilverBalance(address a) public view returns(uint){
      return NFT(influencers[a].collectionAddress).getBalance(a,3);
    }
    function getGoldBalance(address a) public view returns(uint){
      return NFT(influencers[a].collectionAddress).getBalance(a,2);
    }
}

contract NFT is ERC1155{

uint256  PLATINUM=0;
uint256  DIAMOND=1;
uint256  GOLD=2;
uint256  SILVER=3;
uint256  IRON=4;    

constructor(string memory uri) ERC1155(uri){}

function transfer(address _to, uint256 _id, uint256 _value) public {
        safeTransferFrom(msg.sender,_to,_id,_value,"");
    }

    function mint(address to,uint256 id,uint256 amount,bytes memory data)public{
        _mint(to , id,amount,data);
    }

    function getBalance(address _owner, uint256 _id) public view returns(uint){
        return balanceOf(_owner,_id);
    }

    function burn(
        address account,
        uint256 id,
        uint amount
    ) public {
        require(msg.sender==account,"You can Only burn Your NFT's");
        _burn(account,id,amount);
    }
}
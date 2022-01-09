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
    uint256 constant PLATINUM = 0;
    uint256 constant DIAMOND = 1;
    uint256 constant GOLD = 2;
    uint256 constant SILVER = 3;
    uint256 constant IRON = 4;

    struct influencer {
        uint256 id;
        address ad;
        string name;
        string gmail;
        address collectionAddress;
    }

    struct person {
        uint256 id;
        address ad;
        string name;
        string gmail;
        // collection[] collectionsOwned;
        mapping(address => bool[5]) collectionsOwned;
        // {
        //     "influncer collection address":[F,F,F,F,F],
        //     "influncer collection address-2":[T,F,F,T,F],
        // }
    }
    // struct collection{
    //     address collectionid;
    //     bool[5] nftid;
    // }

    // for every transaction we will charge 3% fees and that will be 20% for us 80% for creator

    mapping(address => person) public people;
    uint256 peopleCount = 1;

    mapping(address => influencer) public influencers;
    uint256 public influncerCount;

    address[] influencerArray;
    mapping(address => bool) isInfluencer;

    function addInfulencer(
        address _ad,
        // uint256 _id,
        string memory _name,
        string memory _gmail
    ) public {
        // onlyOwner
        influencerArray.push(_ad);
        isInfluencer[_ad] = true;
        influencers[_ad].id = influncerCount;
        influncerCount++;
        influencers[_ad].gmail = _gmail;
        influencers[_ad].ad = _ad;
        influencers[_ad].name = _name;
    }

    modifier onlyInfluencer(address _ad) {
        require(isInfluencer[_ad] == true, "Not an influencer");
        _;
    }

    function addUser(string memory _name, string memory _gmail) public {
        require(people[msg.sender].id == 0, "user alread exists");
        people[msg.sender].name = _name;
        people[msg.sender].gmail = _gmail;
        people[msg.sender].id = peopleCount;
        people[msg.sender].ad = msg.sender;
        peopleCount++;
    }

    function deployCollection(address account, string memory uri)
        public
        returns (address collectionAddress)
    {
        // modifier - for registered influncer
        influencers[account].collectionAddress = address(new NFT(uri));
        return influencers[account].collectionAddress;
    }

    function mint(address influencerAddress, uint256 id)
        public
        returns (bool isNFTMinted)
    {
        //CHECK IF ALREAD MINTED BY ANOTHER USER OR OWNED BY MSG.SENDER
        address CollectionAddress = getCollectionAddress(influencerAddress);
        //check if not deployed 
        NFT(CollectionAddress).mint(msg.sender, id, 1, "");
        people[msg.sender].collectionsOwned[influencerAddress][id] = true;
        return people[msg.sender].collectionsOwned[influencerAddress][id];
    }

    //this is working
    function checkIfMinted(
        address _owner,
        address _influencerAddress,
        uint256 _id
    ) public view returns (bool isNFTMinted) {
        return people[_owner].collectionsOwned[_influencerAddress][_id];
    }

    function getUser(address _a)
        public
        view
        returns (uint256 userId, string memory userName)
    {
        return (people[_a].id, people[_a].name);
    }

    function getPeopleCount() public view returns (uint256 peopleCounting) {
        uint256  a =peopleCount;
        return a-1;
    }

    function getInfluncer(address _a)
        public
        view
        returns (uint256 influncerId, string memory influencerName)
    {
        return (influencers[_a].id, influencers[_a].name);
    }

    function getUserInfo(address _ad)
        public
        view
        returns (
            uint256 id,
            address addres,
            string memory name,
            string memory gmail
        )
    {
        return (
            people[_ad].id,
            people[_ad].ad,
            people[_ad].name,
            people[_ad].gmail
        );
    }

    function getCollectionAddress(address influencerAddress)
        public
        view
        returns (address collectionAddress)
    {
        return address(NFT(influencers[influencerAddress].collectionAddress));
    }

    //these are not working
    function getIronBalance(address influencerAddress)
        public
        view
        returns (uint256 IronBalance)
    {
        return NFT(influencers[influencerAddress].collectionAddress).getBalance(msg.sender, 4);
    }

    function getSilverBalance(address influencerAddress)
        public
        view
        returns (uint256 SilverBalance)
    {
        return NFT(influencers[influencerAddress].collectionAddress).getBalance(msg.sender, 3);

    }

    function getGoldBalance(address influencerAddress)
        public
        view
        returns (uint256 GoldBalance)
    {
        return NFT(influencers[influencerAddress].collectionAddress).getBalance(msg.sender, 2);
    }

    function getDiamondBalance(address influencerAddress)
        public
        view
        returns (uint256 DiamondBalance)
    {
        return NFT(influencers[influencerAddress].collectionAddress).getBalance(msg.sender, 1);

    }

    function getPlatinumBalance(address influencerAddress)
        public
        view
        returns (uint256 PlatinumBalance)
    {
        return NFT(influencers[influencerAddress].collectionAddress).getBalance(msg.sender, 0);

    }
}

contract NFT is ERC1155 {
    uint256 constant PLATINUM = 0;//1
    uint256 constant DIAMOND = 1;//4
    uint256 constant GOLD = 2;//15
    uint256 constant SILVER = 3;//30
    uint256 constant IRON = 4;//450

    uint256[5] nftCount;

    constructor(string memory uri) ERC1155(uri) {}

    function transfer(address _to, uint256 _id) public {
        safeTransferFrom(msg.sender, _to, _id, 1, "");
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        // require(nftCount[0]<=1 ,"for platinum" ) ; count check
        // require(nftCount[0]<=1 ,"for platinum" ) ; count check
        // require(nftCount[0]<=1 ,"for platinum" ) ; count check
        // require(nftCount[0]<=1 ,"for platinum" ) ; count check
        // require(nftCount[0]<=1 ,"for platinum" ) ; count check
        nftCount[id]++;
        _mint(to, id, amount, data);
    }

    function getBalance(address _owner, uint256 _id)
        public
        view
        returns (uint256)
    {
        return balanceOf(_owner, _id);
    }

    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public {
        require(msg.sender == account, "You can Only burn Your NFT's");
        _burn(account, id, amount);
    }
}

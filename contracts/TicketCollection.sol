// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// TODO: Add ERC721Enumberable to keep track of all tokens owned per address https://www.youtube.com/watch?v=ngxWWS3Qr3Q
contract TicketCollection is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint public totalSupply;
    uint public ticketPrice;
    string public baseURI;

    // TODO: Add tokenURI to constructor instead of hardcoding it
    constructor(
        string memory _collectionName,
        string memory _collectionSymbol,
        uint _totalSupply,
        uint _ticketPrice,
        string memory _initBaseURI
    ) ERC721(_collectionName, _collectionSymbol) {
        totalSupply = _totalSupply;
        ticketPrice = _ticketPrice;
        setBaseURI(_initBaseURI);
    }

    // backup
    // function _baseURI() internal pure override returns (string memory) {
    //     return
    //         "https://ipfs.io/ipfs/Qmf7PZU8NiWsWRzoUFtLB6bKJsheX44qENvaCoeBKYWNEo/";
    // }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    // TODO: Decide if we want to allow batch minting, so the user can mint more than one ticket at a time
    function safeMint(address to) public payable returns (uint) {
        require(msg.value >= ticketPrice, "price not met");
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        return tokenId;
    }

    // Get token Id for admin to see total amount of tickets sold
    function getTokenId() public view returns (uint256) {
        return _tokenIdCounter.current();
    }
}

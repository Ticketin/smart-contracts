// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TicketCollection is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // TODO: Add tokenURI to constructor instead of hardcoding it
    constructor(
        string memory _collectionName,
        string memory _collectionSymbol,
        address _owner
    ) ERC721(_collectionName, _collectionSymbol) {}

    function _baseURI() internal pure override returns (string memory) {
        return
            "https://ipfs.io/ipfs/Qmf7PZU8NiWsWRzoUFtLB6bKJsheX44qENvaCoeBKYWNEo/";
    }

    // TODO: Decide if we want to allow batch minting, so the user can mint more than one ticket at a time
    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    // Get token Id for admin to see total amount of tickets sold
    function getTokenId() public view returns (uint256) {
        return _tokenIdCounter.current();
    }
}

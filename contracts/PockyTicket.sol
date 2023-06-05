// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ERC721Enumerable, ERC721, IERC721Metadata} from '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {PockyCollections} from './PockyCollections.sol';

/**
 * @dev A ERC721 dNFT token contract for Pocky Ticket, powered by Chainlink.
 * The NFT changes its metadata (i.e. SVG image) according to the event result.
 */
contract Ticket is ERC721Enumerable, AccessControl {
  string private constant TOKEN_NAME = 'Pocky Ticket';
  string private constant SYMBOL = 'POCKYTICKET';

  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

  /** @dev PockeyCollections contract, which is a module responsible for managing the dNFT metadata */
  PockyCollections public collections;

  mapping(uint256 => uint256) private _tokenIdToCollectionId;
  mapping(uint256 => uint256) private _totalSupplyPerCollectionId;

  constructor(PockyCollections _collections) ERC721Enumerable() ERC721(TOKEN_NAME, SYMBOL) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(MINTER_ROLE, msg.sender);

    collections = _collections;
  }

  /**
   * @dev Mints a new token.
   * @notice Should have called by an admin user having {@link MINTER_ROLE}.
   *
   * @param collectionId The collection ID of the token.
   * @param to The beneficiary address to receive the minted token.
   */
  function mint(uint256 collectionId, address to) external onlyRole(MINTER_ROLE) {
    PockyCollections.Collection memory collection = collections.get(collectionId);
    require(block.timestamp <= collection.endDate / 1000, 'event has already ended');
    require(_totalSupplyPerCollectionId[collectionId] < collection.maxSupply, 'sold out');

    uint256 tokenId = totalSupply() + 1;
    _mint(to, tokenId);
    _tokenIdToCollectionId[tokenId] = collectionId;
    _totalSupplyPerCollectionId[collectionId] += 1;
  }

  /**
   * @dev returns a dynamic NFT metadata of given token.
   *
   * The returned URI is an base64-encoded URI self-containing the metadata by itself,
   * not pointing any external URIs like IPFS.
   */
  function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
    require(_exists(tokenId), 'URI query for nonexistent token');
    return collections.constructTokenURIOf(_tokenIdToCollectionId[tokenId]);
  }

  /** @dev returns the collection data of given token. */
  function collectionOf(uint256 tokenId) public view returns (PockyCollections.Collection memory) {
    require(_exists(tokenId), 'query for nonexistent token');
    return collections.get(_tokenIdToCollectionId[tokenId]);
  }

  /** @dev returns the total supply of the collection */
  function totalSupplyOfCollection(uint256 collectionId) public view returns (uint256) {
    return _totalSupplyPerCollectionId[collectionId];
  }

  /** @dev See {IERC165-supportsInterface}. */
  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}

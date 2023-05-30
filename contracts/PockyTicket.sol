// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ERC721Enumerable, ERC721, IERC721Metadata} from '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {TicketCollectionRegistry} from './TicketCollectionRegistry.sol';

/**
 * @dev A ERC721 dNFT token contract for Pocky Ticket, powered by Chainlink.
 * The NFT changes its metadata (i.e. SVG image) according to the event result.
 */
contract Ticket is ERC721Enumerable, AccessControl {
  string private constant TOKEN_NAME = 'Pocky Ticket';
  string private constant SYMBOL = 'POCKYTICKET';

  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

  /** @dev The TicketCollectionRegistry contract, which is a module responsible for managing the dNFT metadata */
  TicketCollectionRegistry public ticketCollectionRegistry;

  mapping(uint256 => string) private _tokenIdToCollectionId;

  constructor(TicketCollectionRegistry _ticketCollectionRegistry) ERC721Enumerable() ERC721(TOKEN_NAME, SYMBOL) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(MINTER_ROLE, msg.sender);

    ticketCollectionRegistry = _ticketCollectionRegistry;
  }

  /**
   * @dev Mints a new token.
   * @notice Should have called by an admin user having {@link MINTER_ROLE}.
   *
   * @param to The beneficiary address to receive the minted token.
   * @param collectionId The collection ID of the token.
   */
  function mint(address to, string calldata collectionId) external onlyRole(MINTER_ROLE) {
    uint256 tokenId = totalSupply() + 1;
    _mint(to, tokenId);
    _tokenIdToCollectionId[tokenId] = collectionId;
  }

  function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
    require(_exists(tokenId), 'URI query for nonexistent token');
    string storage collectionId = _tokenIdToCollectionId[tokenId];
    return ticketCollectionRegistry.constructTokenURIOf(collectionId);
  }

  function collectionOf(uint256 tokenId) public view returns (string memory) {
    require(_exists(tokenId), 'query for nonexistent token');
    return _tokenIdToCollectionId[tokenId];
  }

  /** @dev See {IERC165-supportsInterface}. */
  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}

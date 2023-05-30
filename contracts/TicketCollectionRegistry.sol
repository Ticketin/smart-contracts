// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {Base64} from 'base64-sol/base64.sol';
import {TicketSVGRenderer} from './TicketSVGRenderer.sol';

/**
 * @dev A module manages a common metadata among tokens (called collection),
 * and renders a OpenSea-compliant ERC721 metadata for each tokens.
 * A metadata can be updated by Chainlink oracle (API Consumer), for example, for updating the event result.
 */
contract TicketCollectionRegistry is AccessControl {
  /** @dev REGISTRAR_ROLE is admin user, who can register a collection. */
  bytes32 public constant REGISTRAR_ROLE = keccak256('REGISTRAR_ROLE');

  /** @dev RESULT_ORACLE_ROLE is given to Chainlink Oracle, who can update the `eventResult` of a collection. */
  bytes32 public constant RESULT_ORACLE_ROLE = keccak256('RESULT_ORACLE_ROLE');

  struct Collection {
    string eventName;
    string eventDate;
    string eventLocation;
    string description;
    string imageUrl;
    string backgroundUrl;
    string contentColor;
    string eventResult;
  }

  mapping(string => Collection) public collections;

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(REGISTRAR_ROLE, msg.sender);
    _setupRole(RESULT_ORACLE_ROLE, msg.sender);
  }

  /**
   * @dev Registers a new collection. Should have {@link REGISTRAR_ROLE}.
   *
   * @param collectionId The unique collection ID.
   * @param collection The collection data.
   */
  function register(string calldata collectionId, Collection calldata collection) external onlyRole(REGISTRAR_ROLE) {
    require(bytes(collections[collectionId].eventName).length == 0, 'collectionId already exists');
    collections[collectionId] = collection;
  }

  /**
   * @dev Updates a event result of a collection. Should have {@link RESULT_ORACLE_ROLE} (i.e. Oracle!)
   * @notice This function is called by Chainlink Oracle.
   * @param collectionId The collection you want to update
   * @param eventResult The event result
   */
  function updateResult(
    string calldata collectionId,
    string calldata eventResult
  ) external onlyRole(RESULT_ORACLE_ROLE) {
    Collection storage collection = collections[collectionId];
    require(bytes(collection.eventName).length > 0, 'collection does not exist');
    collection.eventResult = eventResult;
  }

  /**
   * @dev Generates a OpenSea-compliant ERC721 metadata for a token.
   *
   * @param collectionId the collection ID
   */
  function constructTokenURIOf(string memory collectionId) external view returns (string memory) {
    Collection storage collection = collections[collectionId];
    string memory image = Base64.encode(
      bytes(
        TicketSVGRenderer.renderSVG(
          TicketSVGRenderer.SVGInput({
            title: collection.eventName,
            description1: collection.eventDate,
            description2: collection.eventLocation,
            foregroundColor: collection.contentColor,
            backgroundImage: collection.backgroundUrl,
            contentImage: collection.imageUrl,
            hasResult: bytes(collection.eventResult).length > 0,
            resultText: collection.eventResult
          })
        )
      )
    );
    return
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"Pocky Ticket: ',
                collection.eventName,
                '", "description":"',
                collection.description,
                '", "image": "',
                'data:image/svg+xml;base64,',
                image,
                '"}'
              )
            )
          )
        )
      );
  }
}

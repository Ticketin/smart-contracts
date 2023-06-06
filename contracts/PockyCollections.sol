// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {Base64} from 'base64-sol/base64.sol';
import {TicketSVGRenderer} from './TicketSVGRenderer.sol';

/**
 * @dev A module manages the collection data (i.e. metadata shared across tickets for an event),
 * and renders a OpenSea-compliant ERC721 metadata for each tokens.
 * A metadata can be updated by Chainlink oracle (API Consumer), for example, for updating the event result.
 *
 * The frontend app should use it for serving available drops/collections.
 */
contract PockyCollections is AccessControl {
  /** @dev REGISTRAR_ROLE is admin user, who can register a collection. */
  bytes32 public constant REGISTRAR_ROLE = keccak256('REGISTRAR_ROLE');

  /** @dev RESULT_ORACLE_ROLE is given to Chainlink Oracle, who can update the `eventResult` of a collection. */
  bytes32 public constant RESULT_ORACLE_ROLE = keccak256('RESULT_ORACLE_ROLE');

  struct Collection {
    // —————— basic information
    /** The event name. */
    string name;
    /** ticket price */
    uint256 priceInETH;

    /** the collection owner. only the owner can withdraw the revenue */
    address owner;

    /** the maximum count (mint cap) of tickets per a collection */
    uint256 maxSupply;

    // —————— date-related fields
    // NOTE: time-sensitive sections such as Now, Upcoming should be categorized in
    // the frontend by parsing startDate / endDate. Here are the cases:
    // - Now: startDate <= Date.now() < endDate
    // - Upcoming: Date.now() > startDate
    // - Past (hidden): Date.now() >= endDate

    /** start date, in POSIX time (millis) */
    uint256 startDate;
    /** end date, in POSIX time (millis) */
    uint256 endDate;
    /** YYYYMMDD */
    string matchDate;

    // —————— metadata

    TicketSVGMetadata ticketSvgMetadata;

    /** The summary of the location where the event held. shown in ticket image */
    string eventLocation;
    /** Multi-line description shown in the detail page */
    string description;
    /** Banner image URL. */
    string imageUrl;
    /** Should be listed in the top of the main page? */
    bool featured;
    // —————— result-related fields
    /** Whether the result is updated. */
    bool updated;
    /** The updated result (by Chainlink oracle) */
    OracleResult eventResult;
  }

  struct TicketSVGMetadata {
    // home team info
    string homeTeamName;
    string homeTeamSymbol;
    string homeTeamLogo;
    string homeTeamColor;

    // away team info
    string awayTeamName;
    string awayTeamSymbol;
    string awayTeamLogo;
    string awayTeamColor;

    /** QR Code URL. `https://pocky.deno.dev/api/qrcode/${collectionId}` */
    string qrCodeUrl;

    /** Only the day of week, in uppercase. e.g. `"WEDNESDAY,"` */
    string dateLine1;

    /** rest of the date, in uppercase. e.g. `"OCTOBER 20 PM 7:00"` */
    string dateLine2;

    /** Only the first comma, in uppercase. e.g. `"TD GARDEN,"` */
    string locationLine1;

    /** rest of the date, in uppercase. e.g. `"100 Legends Way, Boston, MA"` */
    string locationLine2;
  }

  struct OracleResult {
    string homeScore;
    string homeFGM;
    string homeFGP;
    string homeTPM;
    string homeTPP;
    string homeFTM;
    string homeFTP;
    string awayScore;
    string awayFGM;
    string awayFGP;
    string awayTPM;
    string awayTPP;
    string awayFTM;
    string awayFTP;
  }

  Collection[] private _collections;

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(REGISTRAR_ROLE, msg.sender);
    _setupRole(RESULT_ORACLE_ROLE, msg.sender);
  }

  /**
   * @dev Registers a new collection. Should have {@link REGISTRAR_ROLE}.
   * @param collection The collection data.
   */
  function register(Collection calldata collection) external onlyRole(REGISTRAR_ROLE) {
    _collections.push(collection);
  }

  /** @dev returns whether the collectionId exists. */
  function exists(uint256 collectionId) public view returns (bool) {
    return bytes(_collections[collectionId].name).length > 0;
  }

  /** @dev returns the collection data for given ID. */
  function get(uint256 collectionId) external view returns (Collection memory) {
    require(exists(collectionId), 'collection does not exist');
    return _collections[collectionId];
  }

  /**
   * @dev The entire collection data.
   * The frontend app should use this method for listing collections in the main page.
   */
  function list() external view returns (Collection[] memory) {
    return _collections;
  }

  /**
   * @dev Updates a event result of a collection. Should have {@link RESULT_ORACLE_ROLE} (i.e. Oracle!)
   * @notice This function is called by Chainlink Oracle.
   * @param collectionId The collection you want to update
   * @param result The event result
   */
  function updateResult(uint256 collectionId, OracleResult calldata result) external onlyRole(RESULT_ORACLE_ROLE) {
    require(exists(collectionId), 'collection does not exist');
    _collections[collectionId].eventResult = result;
    _collections[collectionId].updated = true;
  }

  /**
   * @dev Generates a OpenSea-compliant ERC721 metadata for a token.
   *
   * @param collectionId the collection ID
   */
  function constructTokenURIOf(uint256 collectionId) external view returns (string memory) {
    Collection storage collection = _collections[collectionId];
    string memory image = Base64.encode(bytes(TicketSVGRenderer.renderSVG(collection)));
    return
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"Pocky Ticket: ',
                collection.name,
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

  function svgOf(uint256 collectionId) public view returns (string memory) {
    Collection storage collection = _collections[collectionId];
    return TicketSVGRenderer.renderSVG(collection);
  }
}

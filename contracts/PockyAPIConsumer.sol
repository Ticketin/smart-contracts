// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Chainlink, ChainlinkClient, LinkTokenInterface} from '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import {ConfirmedOwner} from '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
import {Base64} from 'base64-sol/base64.sol';
import {PockyCollections} from './PockyCollections.sol';

contract PockyAPIConsumer is ChainlinkClient, ConfirmedOwner {
  using Chainlink for Chainlink.Request;

  /** @dev PockyCollections contract, which is a module responsible for managing the dNFT metadata */
  PockyCollections public collections;

  mapping(bytes32 => uint256) public requestIdToCollectionId;

  bytes32 private jobId;
  uint256 private fee;

  constructor(PockyCollections _collections) ConfirmedOwner(msg.sender) {
    collections = _collections;

    // Initialize Chainlink Oracle.
    // Address of Polygon Mumbai
    setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
    jobId = '7d80a6386ef543a3abb52817f6707e3b'; // GET>string job
    fee = 10 ** 16; // 0.01 LINK
  }

  /**
   * Create a Chainlink request to retrieve ESPN API response.
   */
  function requestFetchMatchResult(uint256 collectionId) public returns (bytes32 requestId) {
    PockyCollections.Collection memory collection = collections.get(collectionId);

    Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
    req.add('get', string(abi.encodePacked('https://pocky.deno.dev/api/sport/nba/', collection.matchDate)));
    req.add('path', 'oracleResultAbiData');

    requestId = sendChainlinkRequest(req, fee);
    requestIdToCollectionId[requestId] = collectionId;
    return requestId;
  }

  /**
   * Receive the response from the Chainlink, and update the collection result.
   */
  function fulfill(
    bytes32 _requestId,
    string memory oracleResultAbiData
  ) public recordChainlinkFulfillment(_requestId) {
    updateEventResult(requestIdToCollectionId[_requestId], oracleResultAbiData);
  }

  /**
   * Decodes the `oracleResultAbiData` from Pocky Sport API Proxy
   * as a `PockyCollections.OracleResult` struct, and update the collection result.
   *
   * @param collectionId The collection you want to update
   * @param oracleResultAbiData The result data from Pocky Sport API Proxy
   */
  function updateEventResult(uint256 collectionId, string memory oracleResultAbiData) public {
    bytes memory decodedAbiData = Base64.decode(oracleResultAbiData);
    PockyCollections.OracleResult memory result = abi.decode(
      decodedAbiData,
      (PockyCollections.OracleResult)
    );
    collections.updateResult(collectionId, result);
  }

  /**
   * Allow withdraw of Link tokens from the contract
   */
  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
  }
}

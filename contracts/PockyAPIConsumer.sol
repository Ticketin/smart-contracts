// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Chainlink, ChainlinkClient, LinkTokenInterface} from '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import {ConfirmedOwner} from '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
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
    string memory pockySportResultApi = string(
      abi.encodePacked('https://pocky.deno.dev/api/sport/nba/', collection.matchDate)
    );

    Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
    req.add('getHomeScore', pockySportResultApi);
    req.add('pathHomeScore', 'home,score');
    req.add('getHomeFGM', pockySportResultApi);
    req.add('pathHomeFGM', 'home,stats,fieldGoalsMade');
    req.add('getHomeFGP', pockySportResultApi);
    req.add('pathHomeFGP', 'home,stats,fieldGoalsPct');
    req.add('getHomeTPM', pockySportResultApi);
    req.add('pathHomeTPM', 'home,stats,threePointsMade');
    req.add('getHomeTPP', pockySportResultApi);
    req.add('pathHomeTPP', 'home,stats,threePointPct');
    req.add('getHomeFTM', pockySportResultApi);
    req.add('pathHomeFTM', 'home,stats,freeThrowsMade');
    req.add('getHomeFTP', pockySportResultApi);
    req.add('pathHomeFTP', 'home,stats,freeThrowPct');

    req.add('getAwayScore', pockySportResultApi);
    req.add('pathAwayScore', 'away,score');
    req.add('getAwayFGM', pockySportResultApi);
    req.add('pathAwayFGM', 'away,stats,fieldGoalsMade');
    req.add('getAwayFGP', pockySportResultApi);
    req.add('pathAwayFGP', 'away,stats,fieldGoalsPct');
    req.add('getAwayTPM', pockySportResultApi);
    req.add('pathAwayTPM', 'away,stats,threePointsMade');
    req.add('getAwayTPP', pockySportResultApi);
    req.add('pathAwayTPP', 'away,stats,threePointPct');
    req.add('getAwayFTM', pockySportResultApi);
    req.add('pathAwayFTM', 'away,stats,freeThrowsMade');
    req.add('getAwayFTP', pockySportResultApi);
    req.add('pathAwayFTP', 'away,stats,freeThrowPct');

    requestId = sendChainlinkRequest(req, fee);
    requestIdToCollectionId[requestId] = collectionId;
    return requestId;
  }

  /**
   * Receive the response in the form of uint256
   */
  function fulfill(
    bytes32 _requestId,
    string memory homeScore,
    string memory homeFGM,
    string memory homeFGP,
    string memory homeTPM,
    string memory homeTPP,
    string memory homeFTM,
    string memory homeFTP
  )
    public
    // string memory awayScore,
    // string memory awayFGM,
    // string memory awayFGP,
    // string memory awayTPM,
    // string memory awayTPP,
    // string memory awayFTM
    recordChainlinkFulfillment(_requestId)
  {
    collections.updateResult(
      requestIdToCollectionId[_requestId],
      PockyCollections.OracleResult({
        homeScore: homeScore,
        homeFGM: homeFGM,
        homeFGP: homeFGP,
        homeTPM: homeTPM,
        homeTPP: homeTPP,
        homeFTM: homeFTM,
        homeFTP: homeFTP,
        awayScore: '',
        awayFGM: '',
        awayFGP: '',
        awayTPM: '',
        awayTPP: '',
        awayFTM: '',
        awayFTP: ''
        // awayFTP: awayFTP
      })
    );
  }

  /**
   * Allow withdraw of Link tokens from the contract
   */
  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
  }
}

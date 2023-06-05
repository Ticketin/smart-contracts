// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {PockyCollections} from './PockyCollections.sol';
import {Ticket} from './PockyTicket.sol';

/**
 * @dev Mints a new PockeyTicket dNFT as a user pays, and manages the revenue per collection.
 */
contract PockyTicketSales {
  PockyCollections public collections;
  Ticket public ticket;

  mapping(uint256 => uint256) private _balancePerCollectionId;

  constructor(PockyCollections _collections, Ticket _ticket) {
    collections = _collections;
    ticket = _ticket;
  }

  function purchase(uint256 collectionId) external payable {
    require(collections.exists(collectionId), 'collection does not exist');
    require(block.timestamp <= collections.get(collectionId).endDate / 1000, 'event has already ended');
    require(msg.value == collections.get(collectionId).priceInETH, 'invalid price');

    ticket.mint(collectionId, msg.sender);
    _balancePerCollectionId[collectionId] += msg.value;
  }

  function withdrawCollectionRevenue(uint256 collectionId) external {
    require(collections.exists(collectionId), 'collection does not exist');
    require(msg.sender == collections.get(collectionId).owner, 'only owner can withdraw');

    uint256 balance = _balancePerCollectionId[collectionId];
    require(balance > 0, 'no balance');

    _balancePerCollectionId[collectionId] = 0;
    payable(msg.sender).transfer(balance);
  }
}

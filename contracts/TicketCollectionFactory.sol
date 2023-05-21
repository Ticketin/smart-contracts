// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./TicketCollection.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TicketCollectionFactory {
    using Counters for Counters.Counter;

    struct Event {
        address ticketCollectionAddress;
        bool active;
    }

    // Collection counter to keep track of all created events i.c.w idToCollection mapping
    Counters.Counter public collectionCounter;

    // TODO: Probably need to make this a nested mapping OR a addres => address[]
    mapping(address => address) public adminToCollection;

    // Mapping to keep track of all created contracts by every admin
    mapping(uint256 => address) public idToCollection;

    function deployNewTicketCollection(
        string memory _collectionName,
        string memory _collectionSymbol,
        uint _totalSupply,
        uint _ticketPrice,
        string memory _baseURI
    ) public returns (address) {
        TicketCollection ticketCollection = new TicketCollection(
            _collectionName,
            _collectionSymbol,
            _totalSupply,
            _ticketPrice,
            _baseURI
        );
        ticketCollection.transferOwnership(msg.sender);

        adminToCollection[msg.sender] = address(ticketCollection);
        idToCollection[collectionCounter.current()] = address(ticketCollection);
        collectionCounter.increment();

        return address(ticketCollection);
    }
}

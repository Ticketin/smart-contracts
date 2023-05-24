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

    // Mapping to keep track of all events created by a admin
    mapping(address => address[]) public adminToCollection;

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

        adminToCollection[msg.sender].push(address(ticketCollection));
        idToCollection[collectionCounter.current()] = address(ticketCollection);
        collectionCounter.increment();

        return address(ticketCollection);
    }

    // gets values from the adminToCollection() mapping by address
    function getDeployedCollections(
        address _adminAddress
    ) public view returns (address[] memory) {
        address[] memory ticketCollectionAddresses = new address[](
            adminToCollection[_adminAddress].length
        );
        for (uint i = 0; i < adminToCollection[_adminAddress].length; i++) {
            ticketCollectionAddresses[i] = adminToCollection[_adminAddress][i];
        }
        return ticketCollectionAddresses;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./TicketCollection.sol";

contract TicketCollectionFactory {
    // TODO: Probably need to make this a nested mapping OR a addres => address[]
    mapping(address => address) public adminToCollection;

    // Mapping to keep track of all created contracts by every admin
    mapping(uint256 => address) public idToCollection;

    function deployNewTicketCollection(
        string memory _collectionName,
        string memory _collectionSymbol,
        address _owner
    ) public returns (address) {
        TicketCollection ticketCollection = new TicketCollection(
            _collectionName,
            _collectionSymbol,
            _owner
        );
        ticketCollection.transferOwnership(msg.sender);

        adminToCollection[msg.sender] = address(ticketCollection);

        return address(ticketCollection);
    }
}

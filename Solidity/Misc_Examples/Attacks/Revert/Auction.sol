pragma solidity >=0.4.0;

contract Action {
    address currentLeader;
    uint highestBid;

    function bid() public payable {
        require(msg.value > highestBid);

        require(payable(currentLeader).send(highestBid));
        currentLeader = msg.sender;
        highestBid = msg.value;
    }
}
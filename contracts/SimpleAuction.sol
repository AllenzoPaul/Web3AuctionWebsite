// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * SIMPLE AUCTION CONTRACT
 * Easy to understand blockchain bidding platform
 */
contract SimpleAuction {
    
    // The person who created the auction
    address public seller;
    
    // Item being sold
    string public itemName;
    
    // Minimum price to start bidding
    uint256 public minimumBid;
    
    // Current highest bid amount
    uint256 public highestBid;
    
    // Address of person with highest bid
    address public highestBidder;
    
    // When auction ends (timestamp)
    uint256 public auctionEndTime;
    
    // Is auction finished?
    bool public auctionEnded;
    
    // Track everyone's bids
    mapping(address => uint256) public bids;
    
    // Events (like notifications)
    event NewBid(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    
    /**
     * CREATE AUCTION
     * When you deploy this contract, auction starts
     */
    constructor(
        string memory _itemName,
        uint256 _minimumBid,
        uint256 _durationMinutes
    ) {
        seller = msg.sender;
        itemName = _itemName;
        minimumBid = _minimumBid;
        auctionEndTime = block.timestamp + (_durationMinutes * 1 minutes);
        auctionEnded = false;
    }
    
    /**
     * PLACE A BID
     * Anyone can call this and send money
     */
    function placeBid() public payable {
        // Check auction is still running
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(!auctionEnded, "Auction is finished");
        
        // Check bid is high enough
        require(msg.value >= minimumBid, "Bid too low - must be at least minimum");
        require(msg.value > highestBid, "Bid too low - someone bid higher");
        
        // If person had previous bid, add to it
        bids[msg.sender] += msg.value;
        
        // Update highest bid
        highestBid = bids[msg.sender];
        highestBidder = msg.sender;
        
        // Announce new bid
        emit NewBid(msg.sender, highestBid);
    }
    
    /**
     * WITHDRAW YOUR BID
     * Get your money back if you're not winning
     */
    function withdraw() public {
        require(msg.sender != highestBidder, "You're winning! Can't withdraw");
        
        uint256 amount = bids[msg.sender];
        require(amount > 0, "You have no bid to withdraw");
        
        // Reset their bid to 0
        bids[msg.sender] = 0;
        
        // Send money back
        payable(msg.sender).transfer(amount);
    }
    
    /**
     * END AUCTION
     * Anyone can call this after time is up
     */
    function endAuction() public {
        require(block.timestamp >= auctionEndTime, "Auction still running");
        require(!auctionEnded, "Auction already ended");
        
        auctionEnded = true;
        
        // If someone bid, pay the seller
        if (highestBidder != address(0)) {
            payable(seller).transfer(highestBid);
            emit AuctionEnded(highestBidder, highestBid);
        } else {
            emit AuctionEnded(address(0), 0);
        }
    }
    
    /**
     * VIEW FUNCTIONS - Just to see information
     */
    
    function getTimeLeft() public view returns (uint256) {
        if (block.timestamp >= auctionEndTime) {
            return 0;
        }
        return auctionEndTime - block.timestamp;
    }
    
    function getMyBid() public view returns (uint256) {
        return bids[msg.sender];
    }
    
    function isActive() public view returns (bool) {
        return !auctionEnded && block.timestamp < auctionEndTime;
    }
}
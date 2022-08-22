// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract StakingContract {


    // TODO for next time, add a lot more comments explaining each function
    // Use addressStakeDetails struct when doing deposit
    // Consider using arrays for multiple deposits per user per staking instance

    address payable contractAddress = payable(address(this));
    mapping (string => stakeInstance) public stakeList;
    mapping (string => mapping (address => uint)) public stakedAmountPerAddress;

    struct stakeInstance
    {
        bool stakeActive;
        uint stakeDuration; 
        uint maxTokensStaked;
        uint reward;
        uint currentTokensStaked;
        uint timeCreated;
    }

    struct addressStakeDetails
    {
        // TODO use two arrays here maybe? 
        // One for timeStaked and one for amountStaked, so users can deposit multiple times and have their reward/time tracked correctly
        uint timeStaked;
        uint amountStaked;
        bool stakeActive;
    }

    function createStake(string memory _stakeName, uint _stakeDuration, uint _maxTokensStaked, uint _reward) 
    external payable returns (string memory)
    {
        // TODO fix time to set new value closeDate to something like block.timestamp + _stakeDuration
        // TODO change require to use function
        require(!stakeList[_stakeName].stakeActive, "Staking contract already active for this name.");
        require(msg.value == _reward, "Not enough ETH supplied as intended reward amount.");
        stakeList[_stakeName] = stakeInstance(
            {
                stakeActive : true,
                stakeDuration : _stakeDuration,
                maxTokensStaked : _maxTokensStaked,
                reward : _reward,
                currentTokensStaked : 0,
                timeCreated : block.timestamp
            });
        (bool sent, ) = contractAddress.call{value: msg.value}("");
        require(sent, "Failed to send Ether");        
        return ("Staking contract created.");
    }


    function depositToStake(string memory _stakeName, uint _stakeAmount) 
    external payable
    {
        // TODO use new addressStake struct to store user data
        require(stakeList[_stakeName].stakeActive, "Staking not active for this contract.");
        require(msg.value == _stakeAmount, "Not enough ETH supplied");
        stakedAmountPerAddress[_stakeName][msg.sender] += _stakeAmount;
        stakeList[_stakeName].currentTokensStaked += _stakeAmount;
        (bool sent, ) = contractAddress.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function withdrawRewards(string memory _stakeName) 
    external payable
    {
        require(stakedAmountPerAddress[_stakeName][msg.sender] > 0, "Nothing to withdraw.");
        require(checkStakingInstanceComplete(_stakeName), "Staking instance not ready for withdrawal.");
        stakeList[_stakeName].currentTokensStaked -= stakedAmountPerAddress[_stakeName][msg.sender];
        stakedAmountPerAddress[_stakeName][msg.sender] = 0;
        // TODO implement staking formula
        // (amount staked / maxAmount) * (stakedDuration/fullStakeDuration)
        // Need to improve this later as well as it is quite primitive.
        uint reward = 123;
        (bool sent, ) = msg.sender.call{value: reward}("");
        require(sent, "Failed to send Ether");
    }

    function checkStakingInstanceComplete(string memory _stakeName) 
    public view returns(bool) 
    {
        uint daysDiff = (block.timestamp - stakeList[_stakeName].timeCreated) / 60 / 60 / 24;
        // TODO fix time: can only withdraw one whole day later with this.
        require(stakeList[_stakeName].stakeDuration < daysDiff, "Staking instance still running.");
        return stakeList[_stakeName].stakeActive;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract StakingContract {

    address payable contractAddress = payable(address(this));
    mapping (string => stakeStruct) public stakeList;
    mapping (string => mapping (address => uint)) public stakedAmountPerAddress;

    struct stakeStruct
    {
        bool stakeActive;
        uint stakeDuration; 
        uint maxTokensStaked;
        uint reward;
        uint currentTokensStaked;
    }

    function createStake(string memory _stakeName, uint _stakeDuration, uint _maxTokensStaked, uint _reward) 
    public payable returns (string memory)
    {
        require(!stakeList[_stakeName].stakeActive, "Staking contract already active for this name.");
        require(msg.value == _reward, "Not enough ETH supplied as intended reward amount.");
        stakeList[_stakeName] = stakeStruct(
            {
                stakeActive : true,
                stakeDuration : _stakeDuration,
                maxTokensStaked : _maxTokensStaked,
                reward : _reward,
                currentTokensStaked : 0
            });
        require(contractAddress.send(msg.value), "Sending reward to contract failed");
        return ("Staking contract created.");
    }


    function depositToStake(string memory _stakeName, uint _stakeAmount) 
    public payable
    {
        require(stakeList[_stakeName].stakeActive, "Staking not active for this contract.");
        require(msg.value == _stakeAmount, "Not enough ETH supplied");
        require(contractAddress.send(msg.value), "Sending reward to contract failed");
        stakedAmountPerAddress[_stakeName][msg.sender] += _stakeAmount;
        stakeList[_stakeName].currentTokensStaked += _stakeAmount;
    }

    function withdrawRewards() public {}

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}

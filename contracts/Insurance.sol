pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Insurance is StandardToken, Ownable {

	string public constant name = "Insurance Pool Token";
	string public constant symbol = "IPT";
	uint256 public constant decimals = 18;
	uint256 public constant INITIAL_SUPPLY = 100;

	uint MAXIMUM_POOL_SIZE = 0;
  uint LAPSE_BLOCK = 0;
  bool public contractFull = false;

	struct Insured {
		bool withdrawable;
		bool claimed;
		uint claimSize;
		bool exists;
		uint premium;
    uint policyStartTime;
    uint policyEndTime;
		//underlying
	}

	mapping(address => Insured) insurances;
	mapping(address => uint) contributors;
	uint public insurancesCount = 0;
	uint insurancesClaimed = 0;
	uint insurancesLapsed = 0;
	uint poolSize = 0;
    uint public totalInsured = 0;
    uint public premiums = 0;

	function Insurance() public {
		balances[msg.sender] = INITIAL_SUPPLY;
	}

	function init(uint _maxPoolSize, uint _lapseBlock) public onlyOwner {
		MAXIMUM_POOL_SIZE = _maxPoolSize;
    LAPSE_BLOCK = _lapseBlock;
	}

	//fallback function
	function() {
		//if ether is sent to this address, send it back.
		revert();
	}

	function contribute() public payable onlyOwner {
    require(!contractFull);
		poolSize = poolSize + msg.value;
		contributors[msg.sender] = contributors[msg.sender] + msg.value;
        if (poolSize >= MAXIMUM_POOL_SIZE) {
			contractFull = true;
			//contract is filled, so we can now release participation tokens
			approve(owner, INITIAL_SUPPLY);
		}
	}

	function participate(address _to, uint _tokens) public payable onlyOwner {
    require(contractFull);
		transferFrom(msg.sender, _to, _tokens);
	}

	function insure(uint _insuranceAmount) public payable {
    require(poolSize >= totalInsured + _insuranceAmount);
		var insured = Insured(false, false, _insuranceAmount, true, msg.value, now, now);
		insurances[msg.sender] = insured;
    totalInsured = totalInsured + _insuranceAmount;
    premiums = premiums + msg.value;
	}

// this function should be overriden in non-demo versions of the contract to allow injection of claim procedures
	function claim() public payable {
		if (insurances[msg.sender].exists) {
			insurances[msg.sender].withdrawable = true;
		}
	}

	function withdraw() public payable {
		if (insurances[msg.sender].withdrawable) {
			msg.sender.transfer(insurances[msg.sender].claimSize);
			insurances[msg.sender].claimed = true;
		}
  }

    //todo: only allow when all insurances are claimed or lapsed
  function withdrawAsParticipant() public payable {
    require(balances[msg.sender] > 0);
    require(block.timestamp >= LAPSE_BLOCK);
    var toTransfer = contributors[owner] * balances[msg.sender] / INITIAL_SUPPLY;
    var premiumsToTransfer = premiums * balances[msg.sender] / INITIAL_SUPPLY;
    msg.sender.transfer(toTransfer + premiumsToTransfer);
    contributors[owner] -= toTransfer;
    premiums -= premiumsToTransfer;
    if (msg.sender != owner) {approve(msg.sender, balanceOf(msg.sender));}
    //forfeit the tokens to prevent further withdrawals
    transferFrom(msg.sender, this, balanceOf(msg.sender));
  }

}

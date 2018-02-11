pragma solidity ^0.4.18;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract Pornx {
    using SafeMath for uint256;
    enum States {
        PreSale, // accept funds, update balances
        Funded // payout to holder
    }
    // 02/08/2018 10:00:00 GMT+8
    uint256 public constant start_timestamp = 1518055200;
    // 02/12/2018 23:59:59 GMT+8
    uint256 public constant end_timestamp = 1518451199;
    States public state;        
    uint256 public currentEth;
    uint256 public currentCoins;
    uint256 public currentCoinsWithBonuses;
    uint256 public maxCoinsWithBonuses;
    uint8 public decimals;
    address public initialHolder;
    mapping (address => uint256) public balances;
    mapping (address => uint256) public balances_eth;
    function Pornx() 
    public 
    {
        decimals = 18;
        currentEth = 0;
        currentCoins = 0;
        currentCoinsWithBonuses = 0;
        initialHolder = msg.sender;
        state = States.PreSale;
        maxCoinsWithBonuses = 15000000 * 10**18;
    }
    modifier requireState(States _requiredState) {
        require(state == _requiredState);
        _;
    }
    //0.05 min
    modifier minAmount(uint256 amount) {
        require(amount >= 50000000000000000);
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == initialHolder);
        _;
    }
    function requestPayout(uint256 _amount)
    onlyOwner
    public
    {
        msg.sender.transfer(_amount);
    }
    function check()
    public 
    {
        if (now > end_timestamp || currentCoinsWithBonuses > maxCoinsWithBonuses) {
            state = States.Funded;
        }
    }
    function moveToState(States _newState)
    onlyOwner
    public
    {
        state = _newState;
    }
    function() payable
    requireState(States.PreSale)
    minAmount(msg.value)
    public
    {
        uint8 bonus = 35;
        //5 eth
        if (msg.value >= 5000000000000000000) {
          bonus = 40;
        }
        uint256 _coinIncrease = msg.value * 3000 ;
        uint256 _coinBonus = _coinIncrease * bonus / 100;
        require (maxCoinsWithBonuses - currentCoinsWithBonuses >= _coinIncrease + _coinBonus);
        currentEth += msg.value;
        currentCoins += _coinIncrease;
        currentCoinsWithBonuses += _coinIncrease + _coinBonus;
        balances[msg.sender] += _coinIncrease + _coinBonus;
        balances_eth[msg.sender] += msg.value;
    }
}

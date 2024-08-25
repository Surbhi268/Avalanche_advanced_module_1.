// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

import "./IERC20.sol";





contract Vault {
    IERC20 public immutable token;
    uint public shares;
  
    address public _owner;

    uint public totalSupply;
    uint public totalShares;

    mapping(address => uint) storedTokens;
    mapping(address => uint) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token); 
        totalSupply = token.totalSupply();
    }


    //to deposit tokens in the bank vault
    function depositTokens(address _depositor,uint amount)external{
        storedTokens[_depositor] = amount;
    }


    // to withdraw tokens from the bank vault.

    function withdrawTokens(address _withdrawal) external returns(uint){

        uint amount = storedTokens[_withdrawal];
        storedTokens[_withdrawal] = 0;
        return  amount;
    }

    function bankBalance(address _customer) external view returns(uint){
        return storedTokens[_customer];
    }
    

   function transferFunc(address owner,address _recepient,uint _amount) public{
    token.transferFunc(owner,_recepient,_amount);
   }

    function _mint(address _to, uint _shares) internal {
        totalShares += _shares;
        balanceOf[_to] += _shares;
    }

    function _burn(address _from, uint _shares) internal {
        totalShares -= _shares;
        balanceOf[_from] -= _shares;
    }




 
   function deposit(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");

        uint256 tokenBalance = token.balanceOf(msg.sender);

        if (totalSupply == 0) {
            shares = _amount;
        } else {
            require(tokenBalance > 0, "Token balance must be greater than 0");
            shares = (_amount* totalSupply)/ tokenBalance;
        }

       _mint(msg.sender,shares);
       transferFunc(msg.sender,address(this),_amount);
    }

    function balance() external view returns(uint){
        return token.balanceOf(msg.sender);
    }

    function withdraw(uint _shares) external {
  
        _burn(msg.sender, _shares);
        transferFunc(address(this), msg.sender, shares);
    }

    function getTotalSupply() external{
          totalSupply = token.totalSupply();
    }

  
}
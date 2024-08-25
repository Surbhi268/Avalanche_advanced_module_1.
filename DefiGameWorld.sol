// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "./ERC20.sol";
import "./Vault.sol";
contract DefiGameWorld{


    uint public playerChance;
    uint public playerSum;
    uint public machineSum;
    string public result;
    address public player;
    address public opponent;
    string public bettingResult;

    ERC20 tokens;
    Vault vault;

    constructor(){
        playerChance = 3;
        playerSum = 0;
        machineSum=0;
        tokens = new ERC20("DEFI","DFG");
        vault = new Vault(address(tokens));
    }

    function endGame() internal returns(string memory){

        string memory message;
        if(playerSum > machineSum){

            tokens.mintTokens(player, 100); 
           message = "Player Won !!";
        }
        else{
           
            message = "Player Loose !!";
        }

         playerSum = 0;
        machineSum = 0;
        playerChance = 3;

        return message;
        
    }

    function depositInBankVault(uint _tokenAmount) external{
      require(tokens.balanceOf(msg.sender)>=_tokenAmount);
      tokens.transferFunc(msg.sender, address(vault), _tokenAmount);
        vault.depositTokens(msg.sender, _tokenAmount);
        
    }
    function withdrawFromBank() external{
     
      uint depositedAmount =  vault.withdrawTokens(msg.sender);
      uint interest = depositedAmount * 10/100;
      tokens.mintTokens(msg.sender, depositedAmount + interest);
    }

    function getBankBalance()external view returns(uint){
        return vault.bankBalance(msg.sender);
    }

    // pseudo functions

    function tranferToOther(address _address,uint _amount)external {
        require(tokens.balanceOf(msg.sender)>=_amount);
        vault.transferFunc(msg.sender,_address,_amount);
    }




    function mint(uint _tokenAmount) external {
        tokens.mintTokens(msg.sender, _tokenAmount);
    }

    function bettingTokens(address _opponent,uint _amount)external {
        require(tokens.balanceOf(_opponent)>=_amount);
        require(tokens.balanceOf(msg.sender)>=_amount);
        tokens._burn(_opponent, _amount);
        tokens._burn(msg.sender, _amount);

      uint _opponentScore =   machineRandomNumber();
      uint _myScore = playerRandomNumber();

      if(_myScore > _opponentScore){
        tokens.mintTokens(msg.sender, 10*_amount);
        bettingResult = "You Won !!";
      }else{
        tokens.mintTokens(_opponent, 10*_amount);
        bettingResult = "You Lost !! Opponent Won";
      }

    }


    function playLudo() external {
        
        if(playerChance == 3){
               player = msg.sender;
        }
        require(playerChance > 0,"game ended");
        playerSum += (playerRandomNumber()%6) + 1;
        machineSum += (machineRandomNumber()%6) + 1;
        playerChance--;

         if(playerChance == 0){
          result =  endGame();

        }else{
            result = "Game is in Procress";
        }

    }

    function checkBalance() public view returns(uint){ 
        return tokens.balanceOf(msg.sender);
    }



     function machineRandomNumber() internal view returns(uint) {
        uint val = uint256(keccak256(abi.encodePacked(block.timestamp, block.coinbase, block.difficulty,address(this))));
        return val;
    }

     function playerRandomNumber() internal view returns(uint) {
        uint val = uint256(keccak256(abi.encodePacked(block.timestamp, block.coinbase,msg.sender,msg.value)));
        return val;
    }

    function burnTokens(uint _tokenAmount) public {
        require(tokens.balanceOf(msg.sender)>=_tokenAmount);
        tokens._burn(msg.sender,_tokenAmount);
    }






}
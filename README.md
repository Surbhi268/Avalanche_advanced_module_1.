# Avalanche_advanced_module_1
In this I have created my own subnet using the linux os and then connected it to the metamask afterward I deployed the DefiGameWorld contract using my own subnet and in the game there are several function like
- player can play ludo with the machine
- winner will get some reward
- players can bet against each other and after they get 10 times of the initial betting amount
- also one can deposit their tokens in the bank and the bank will return the deposited tokens with the interst also.
- one can also able to transfer tokens to their friend for playing and burn
# Walkthrough vedio
https://www.loom.com/share/1adbaab982f74f73861f6ec6c2cb87d1?sid=37f3f96c-1ec2-4dc6-b6e6-2b8def013596

- Creating the own subnet
  ![image](https://github.com/user-attachments/assets/9cd200ef-7e6b-4e6e-b3d4-a534b3b20cc8)
  ![image](https://github.com/user-attachments/assets/242b4c15-dd40-40e8-a24b-8addf807f679)
  ![image](https://github.com/user-attachments/assets/ac582389-b57e-49c8-a309-a2e464eb0b03)

- Own created subnet transactions
![image](https://github.com/user-attachments/assets/d5118352-b6e4-4601-9fe1-6412c9241ebd)

- Code
  - DefiGameWorld.sol
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

- ERC20.sol
  // SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.22;

import {IERC20} from "./IERC20.sol";

error ERC20InvalidSender(address _nullAddress);
error ERC20InvalidReceiver(address _nullAddress);
error ERC20InsufficientBalance(address,address,uint);
error ERC20InsufficientBalances(address,uint,uint);
error ERC20InsufficientAllowance(address,uint,uint);


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
 */
contract ERC20 is  IERC20 {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function mintTokens(address owner,uint _amount) external{
        _mint(owner, _amount);
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }
    function transferFunc(address sender, address recepient, uint _amount) external{
        _transfer(sender, recepient, _amount);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalances(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) public {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     *
     * ```solidity
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

- IERC20.sol
   // SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.22;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

     function transferFunc(address sender, address recepient, uint _amount) external;

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);


     function mintTokens(address owner,uint _amount) external;
}
- Vault.sol
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

    function depositTokens(address _depositor,uint amount)external{
        storedTokens[_depositor] = amount;
    }

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

### Author
Surbhi Priya

email- psurbhi237@gmail.com

### License
This project is licensed under the MIT license




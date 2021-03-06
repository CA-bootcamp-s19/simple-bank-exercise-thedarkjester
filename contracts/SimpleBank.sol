/*
    This exercise has been updated to use Solidity version 0.6.12
    Breaking changes from 0.5 to 0.6 can be found here: 
    https://solidity.readthedocs.io/en/v0.6.12/060-breaking-changes.html
*/

pragma solidity ^0.5.0;

/// @author Consensys academy
/// @title Simple bank exercise
contract SimpleBank {

    //
    // State variables
    //
    
    /* Fill in the keyword. Hint: We want to protect our users balance from other contracts*/
    mapping (address => uint) private balances;
    
    /* Fill in the keyword. We want to create a getter function and allow contracts to be able to see if a user is enrolled.  */
    mapping (address => bool) public enrolled;

    /* Let's make sure everyone knows who owns the bank. Use the appropriate keyword for this*/
    address public owner ;
    
    //
    // Events - publicize actions to external listeners
    //
    
    /* Add an argument for this event, an accountAddress */
    /// @notice emits when a new address is enrolled
    event LogEnrolled(address accountAddress);

    /* Add 2 arguments for this event, an accountAddress and an amount */
    /// @notice emits when an amount is deposited to an account
    event LogDepositMade(address accountAddress, uint amount);

    /* Create an event called LogWithdrawal */
    /* Add 3 arguments for this event, an accountAddress, withdrawAmount and a newBalance */
    /// @notice emits when an amount is withdrawn along with the new balance
    event LogWithdrawal(address accountAddress, uint withdrawAmount, uint newBalance);

    //
    // Functions
    //

    /* Use the appropriate global variable to get the sender of the transaction */
    /// @notice constucts the contract
    /// @dev sets contract creator as the owner
    constructor() public {
        /* Set the owner to the creator of this contract */
        owner = msg.sender;
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract

    /// @notice default payment handler for unexpected payments
    /// @dev reverts payment if funds accidentally set without a function specific call
    function () external payable {
        revert();
    }

    /// @notice Get balance
    /// @return The balance of the user
    /// @dev is a view and uses the balances array
    // A SPECIAL KEYWORD prevents function from editing state variables;
    // allows function to run locally/off blockchain
    function getBalance() public view returns (uint) {
        /* Get the balance of the sender of this transaction */
        return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    /// @dev emits the LogEnrolled event
    // Emit the appropriate event
    function enroll() public returns (bool){
      // require(enrolled[msg.sender] == false);

       enrolled[msg.sender]= true;

       emit LogEnrolled(msg.sender);

       return true;
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    /// @dev emits the LogDepositMade event
    // Add the appropriate keyword so that this function can receive ether
    // Use the appropriate global variables to get the transaction sender and value
    // Emit the appropriate event    
    // Users should be enrolled before they can make deposits
    function deposit() public payable returns (uint) {
        /* Add the amount to the user's balance, call the event associated with a deposit,
          then return the balance of the user */
          require(enrolled[msg.sender]);
          
          uint newBalance  = add(balances[msg.sender], msg.value);
         
          balances[msg.sender] = newBalance;

          emit LogDepositMade(msg.sender, msg.value);

          return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @dev transfer is only after all checks and internal adjustments are made to avoid Re-Entry
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    // Emit the appropriate event    
    function withdraw(uint withdrawAmount) public returns (uint) {
        /* If the sender's balance is at least the amount they want to withdraw,
           Subtract the amount from the sender's balance, and try to send that amount of ether
           to the user attempting to withdraw. 
           return the user's balance.*/

           require(withdrawAmount > 0);
           require(balances[msg.sender] >= withdrawAmount);
           require(balances[msg.sender] >= withdrawAmount);
           require(address(this).balance >= withdrawAmount); // this contract really should have enough ETH

           uint newBalance  = sub(balances[msg.sender], withdrawAmount); // safe underflow math
           
           balances[msg.sender] = newBalance;

           emit LogWithdrawal(msg.sender, withdrawAmount, newBalance);

           msg.sender.transfer(withdrawAmount);

           return newBalance;
    }

    /// @notice adds two numbers together safely
    /// @param a first number
    /// @param b second number
    /// @dev taken from OpenZeppelin - a package should be referenced here, but put it in to illustrate
    /// @return sum of the two numbers
    function add(uint a, uint b) internal pure returns (uint) {
        uint256 c = a + b;
        require(c >= a); // make sure there is no weird overflow going on - I don't think anyone will ever have that much eth, but safety is important
        return c;
    }

    /// @notice subtracts numbers safely
    /// @param a first number expected to be the larger
    /// @param b second number expected to be the smaller
    /// @dev taken from OpenZeppelin - a package should be referenced here, but put it in to illustrate
    /// @return the difference between the two numbers
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /// @notice subtracts numbers safely
    /// @param a first number expected to be the larger
    /// @param b second number expected to be the smaller
    /// @param errorMessage to show when failure occurs
    /// @dev taken from OpenZeppelin - a package should be referenced here, but put it in to illustrate
    /// @return the difference between the two numbers
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
}

/* BadTransactionException.java */

/**
 *  Implements an exception that should be thrown for negtive deposit and withdraw.
 **/
public class BadTransactionException extends Exception {

  public int depositAmount;  // The invalid deposit number.

  /**
   *  Creates an exception object for nonexistent account "badAcctNumber".
   **/
  public BadTransactionException(int badDepositAmount) {
    super("Invalid deposit amount: " + badDepositAmount);

    depositAmount = badDepositAmount;
  }
}
pragma solidity < 0.8.0;

import "./Libs/SafeMath.sol";
import "./BigPurchase.sol";

    //This contract partially taken from 
    //https://github.com/smartzplatform/constructor-eth-invoice/blob/4a186dc8fc4da84dbcbc15114b7e6d1cc00f44cd/contracts/Invoice.sol
    //and implements invoice creation for whoever buys products in contract.
contract Invoice {
    using SafeMath for uint256;

    enum Status { Active, Overdue, Paid }

    event Refund(
        address receiver,
        uint256 amount
    );

    event Payment(
        address from,
        uint256 amount
    );

    event PaymentComplete(
        uint256 InvoiceNumber,
        uint256 amount
    );

    event PaymentRunOut(
        uint256 InvoiceNumber,
        uint256 paidAmount
    );


    uint256 public invoiceAmount;
    function GetInvoiceAmount() public view returns (uint256){
        return invoiceAmount;
    }

    uint256  paidAmount;
    uint256  validityPeriod;
    address  payer;
    address payable mainAddress;
    BigPurchase  mainContract;
    uint InvoiceNumber;
    bool allPayed;

    constructor (
        uint256 _invoiceAmount,
        uint _InvoiceNumber,
        address _payer,
        address payable _main
    ) public {
        validityPeriod = block.timestamp.add(1 days);      //the invoice will be active for one day, after we shall revert operations
        invoiceAmount = _invoiceAmount;
        InvoiceNumber = _InvoiceNumber;
        payer = _payer;
        mainContract = BigPurchase(_main);
        mainAddress = _main;
    }

    modifier onlyPayer() {
        require(msg.sender == payer);
        _;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getStatus() public returns (Status) {
        if (block.timestamp > validityPeriod){
            finalize();
        }
        return Status.Active;
    }

    function doRefund(uint256 amount) internal {
        msg.sender.transfer(amount);
        emit Refund(msg.sender, amount);
    }

    function PayProduct() public payable onlyPayer {
        require(getStatus() == Status.Active);

        uint256 will = paidAmount.add(msg.value);

        if (will >= invoiceAmount) {
            if (will > invoiceAmount)
                doRefund(will - invoiceAmount);

            paidAmount = invoiceAmount;
            allPayed = true;                    //we set this flag only here, marking payment complete
            finalize();
        } else {
            paidAmount = will;
        }

        emit Payment(msg.sender, msg.value);
    }
    //this function tells main contract, that its finished or timed out. 
    function finalize() public {

        mainContract.finalizeInvoice(InvoiceNumber, allPayed);
        
        if(allPayed)
            emit PaymentComplete(InvoiceNumber, paidAmount);
        else 
            emit PaymentRunOut(InvoiceNumber, paidAmount);

        selfdestruct(mainAddress);      //transfer all received money to main contract
    }
}

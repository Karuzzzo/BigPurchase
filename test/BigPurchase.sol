pragma solidity <0.8.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
pragma solidity <0.8.0;

// import "remix_tests.sol"; // this import is automatically injected by Remix.

import "../contracts/BigPurchase.sol";
import "../contracts/Libs/SafeMath.sol";

contract TestBigPurchase {
    BigPurchase purchase;
    
    function beforeAll() public {
        purchase = new BigPurchase();
    }
    function testAddingProduct() public {
        purchase.addProduct("Apple", 10, 1000, 100);

        string memory expected = "Apple";
        (, string memory name ,,, ) = purchase.GetProduct(1);
        //(uint id, string memory name, uint price,uint amount, uint treshold ) = purchase.GetProduct(1);

        Assert.equal(name, expected, "First element in mapping should have name 'apples' ");
  }

    function testItemStacking() public{
        purchase.addProduct("Apple", 10, 1000, 100);
        purchase.addProduct("Pineapple", 40, 1000, 250);
        purchase.addProduct("Apple", 10, 1000, 100);

        uint expected = 3000;
        (,,,uint amount, ) = purchase.GetProduct(1);

        Assert.equal(amount, expected, "There should be 3k apples and 1k of pineapple");
    }

    function testDiscounts() public {
        purchase.addProduct("Apple", 15, 1000, 100);
        purchase.addProduct("Pineapple", 10, 1000, 100);
        
        purchase.buyProduct(1, 150);
        uint TotalPrice = (15.mul((150.mul(95)))).div(100);
        Assert.equal(purchase.Invoices[1].invoiceAmount, TotalPrice, "There must be a discount");
    }

    //well im not sure how this will work, as we dont have balance, i guess. 
    //Cant quite understand, from which address we deploy tests, and does it even have a balance
    function testpayments() public {

    }
}
pragma solidity <0.8.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/Libs/SafeMath.sol";

pragma solidity <0.8.0;

// import "remix_tests.sol"; // this import is automatically injected by Remix.

import "../contracts/BigPurchase.sol";
import "../contracts/Invoice.sol";


contract TestBigPurchase {

    using SafeMath for uint256;

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
        purchase.addProduct("Apple", 10, 2000, 100);

        uint expected = 4000;
        (,,,uint amount, ) = purchase.GetProduct(1);

        Assert.equal(amount, expected, "There should be 4k apples");
    }

    function testMultipleProducts() public {
        string memory expected = "Pineapple";
        (,string memory name,,, ) = purchase.GetProduct(2);

        Assert.equal(name, expected, "There should be a pineapple");
    }

    function testDiscounts() public {
        purchase.addProduct("Apple", 10, 1000, 100);
        purchase.addProduct("Pineapple", 40, 1000, 250);

        purchase.buyProduct(1, 150);

        //uint ExpectedPrice = (Price.mul(Amount.mul(95))).div(100);
        uint256 ExpectedPrice = 1425;       //(150 * 10 * 95) / 100
        uint256 InvoicePrice = purchase.GetInvoiceAmount(1);

        Assert.equal(InvoicePrice, ExpectedPrice, "There must be a discount");
    }
    function testInvoiceCreation() public {
        uint InvoiceAmount = purchase.InvoicesCount();
        uint expected = 1;

        Assert.equal(InvoiceAmount, expected, "There shall be 1 invoice, created in previous test!");
    }
    //well im not sure how this will work, as we dont have balance, i guess. 
    //Cant quite understand, from which address we deploy tests, and does it even have a balance
    function testDeletionIfAllBought() public {
        purchase.buyProduct(2, 2000);
        purchase.addProduct("Watermelon", 90, 600, 40);


        string memory expected = "Watermelon";
        (, string memory name ,,, ) = purchase.GetProduct(2);

        Assert.equal(name, expected, "Second element in mapping should be Watermelon");

    }
}
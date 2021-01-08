pragma solidity <0.8.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BigPurchase.sol";
import "../contracts/Libs/SafeMath.sol";

contract TestBigPurchase {
    function testAddingProduct() {
        BigPurchase purchase = BigPurchase(DeployedAddresses.BigPurchase());
        purchase.addProduct("Apple", 10, 1000, 100);

        string memory expected = "Apple";
        Assert.equal(Products[1].Name, expected, "First element in mapping should have name 'apples' ");
  }
    function testItemStacking(){
        BigPurchase purchase = BigPurchase(DeployedAddresses.BigPurchase());
        purchase.addProduct("Apple", 10, 1000, 100);
        purchase.addProduct("Apple", 10, 1000, 100);
        purchase.addProduct("Pineapple", 40, 1000, 250);
        purchase.addProduct("Apple", 10, 1000, 100);

        uint expected = 3000;
        Assert.equal(Products[1].Amount, expected, "There should be 3k apples and 1k of pineapple");
    }

    function testDiscounts(){
        BigPurchase purchase = BigPurchase(DeployedAddresses.BigPurchase());
        purchase.addProduct("Apple", 15, 1000, 100);
        purchase.addProduct("Pineapple", 10, 1000, 100);
        
        purchase.buyProduct(1, 150);
        TotalPrice = (15.mul((150.mul(95)))).div(100);
        Assert.equal(Invoices[1].invoiceAmount, expected, "There must be a discount");
    }

    //well im not sure how this will work, as we dont have balance, i guess. 
    //Cant quite understand, from which address we deploy tests, and does it even have a balance
    function testpayments(){

    }
}
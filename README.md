# BigPurchase

### Warning! This smart contract should not be used in real life, only for educational purposes.

This  contract allows the creator to upload products, setting prices on it, its amount and treshold, from which there should be made a discount.
It also allows anyone to buy products. 
When purchasing large volumes indicated when you purchasing the product, the price will be reduced.

After purchasing the product, the buyer will have number his own invoice, which he must pay within a day. 
Otherwise, the product will go back to the market.

# Installation

You can deploy contract to testnet ganache, I do not recommend deploying it to real net. For deploy you will have to install ganache.

`npm install -g ganache-cli`

`git clone https://github.com/Karuzzzo/BigPurchase/`

`cd BigPurchase`

`npm install`

# Build

To build and run, you will need to have truffle as well.  
`npm install -g truffle`

`truffle migrate --reset` 

And your contract deployed to ganache.

# Usage

Contract creator can call function addProduct, to create new position on market. After it, event triggers, notifying everyone about new product.

After it, anyone can buy it, calling function buyProduct, sending identifier of requred product and its amount.

Then, buyer will get his own invoice, which he will have to pay. After payment, the deal will be marked as complete, event triggers and invoice initiates self-destruct.


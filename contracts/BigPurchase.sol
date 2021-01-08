pragma solidity < 0.8.0;

import "./Libs/SafeMath.sol";
import "./Invoice.sol";
contract BigPurchase{

    using SafeMath for uint256;

    event ProductAdded(string name, uint price, uint amount, uint treshold);
    event AwaitingPayment(string name, uint amount, uint price, uint InvoiceNumber);
    event ProductRunOut(string name);

    struct Product{
        uint Id;
        string Name;
        uint Price;
        uint Amount;
        uint Treshold;      //the quantity of the product, upon purchase of which the discount will be provided
    }

    address payable owner;

    //list of Products
    mapping(uint => Product) public Products;
    uint public ProductsCount;

    mapping(bytes => uint) ProductHashes;

    mapping(uint => Invoice) public Invoices;
    uint public InvoicesCount;

    mapping(uint => Product) public ProductStash;   //we stash here products which was bought, but not payed yet

    modifier OnlyOwner(){
        require(msg.sender == owner);
        _;
    }
    modifier OnlyOwnedInvoices(uint InvoiceNumber){
        require(msg.sender == address(Invoices[InvoiceNumber]));
        _;
    }

    constructor() public {
        owner = msg.sender;
        addProduct("Apples", 10, 20, 5);        //example position of 20 apples, discount will be made from 5 or more. Price of one apple is 10 units (value should be thought out)
    }

    function addProduct(string memory _name, uint _price, uint _amount, uint _treshold) public OnlyOwner {
        bool productExist = false;
        
        I have no idea why, but code down here doesnt work 
        //if we already have same product with same price, we add new product to existing
        if(ProductsCount >= 1 )
            for(uint a = 0; ((a <= ProductsCount) && (!productExist)); a.add(1)){       
                if(Products[a].Price == _price)
                    if(Products[a].Treshold == _treshold)
                        if(keccak256(abi.encodePacked(Products[a].Name)) == keccak256(abi.encodePacked(_name))){
                            Products[a].Amount.add(_amount);        //we cant compare strings directly, so compare their hashes
                            productExist = true;
                        }
            }

        if(!productExist){
            ProductsCount = ProductsCount.add(1);
            Products[ProductsCount] = Product(ProductsCount, _name, _price, _amount, _treshold);
        }

        emit ProductAdded(_name, _price, _amount, _treshold);
    }

    function buyProduct(uint ProductId, uint amount) public {
        
        require(ProductId <= ProductsCount);                        //checking if we gave right id of product
        Product memory toBuy = Products[ProductId];
        require(amount <= toBuy.Amount);                            //and if we have enough product
              
        uint TotalPrice;

        if (amount >= toBuy.Treshold){ 
            TotalPrice = (toBuy.Price.mul((amount.mul(95)))).div(100);         //making 5% discount, if purchase big enough
        } else {
            TotalPrice = toBuy.Price.mul(amount);
        }

        if(toBuy.Amount == amount){                                 //if all of supplied product was bought 
            delete(Products[ProductId]);
            emit ProductRunOut(toBuy.Name);                          //later implement shifting id of elements, so there will be no gaps in mapping
        } else {
            Products[ProductId].Amount = Products[ProductId].Amount.sub(amount);
        }
        
        InvoicesCount.add(1);                         //creating new invoice for customer to pay
        Invoices[InvoicesCount] = new Invoice(TotalPrice, InvoicesCount, msg.sender, address(uint160(address(this))));
        ProductStash[InvoicesCount] = toBuy;
        emit AwaitingPayment(toBuy.Name, amount, TotalPrice, InvoicesCount);
    } 

    function finalizeInvoice(uint InvoiceNumber, bool allPayed) 
    public 
    OnlyOwnedInvoices(InvoiceNumber)                //this function called only from created invoices 
    {
        if(allPayed){
            delete(Invoices[InvoiceNumber]);
            delete(ProductStash[InvoiceNumber]);
        } else {                                     //Invoice was not payed, we return product back on market
            Product memory toReturn = ProductStash[InvoiceNumber];
            addProduct(toReturn.Name, toReturn.Price, toReturn.Amount, toReturn.Treshold);
            
            delete(Invoices[InvoiceNumber]);
            delete(ProductStash[InvoiceNumber]);
        }
    }
}
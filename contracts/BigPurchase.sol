pragma solidity < 0.8.0;

import "./Libs/SafeMath.sol";
import "./Invoice.sol";
contract BigPurchase{

    using SafeMath for uint256;

    event ProductAdded(uint Id, string name, uint price, uint amount, uint treshold);
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

    //list of Products, and list of their hashes
    mapping(uint => Product) public Products;
    mapping(bytes32 => uint) public ProductHashes;    
    uint public ProductsCount;

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
        ProductsCount = 0;
        InvoicesCount = 0;
    }

    function getHashedProduct(string memory _name, uint _price, uint _treshold) internal pure returns (bytes32){
        return  keccak256(abi.encodePacked(_name))^
                keccak256(abi.encodePacked(_price))^
                keccak256(abi.encodePacked(_treshold));
    }

    function addProduct(string memory _name, uint _price, uint _amount, uint _treshold) public OnlyOwner {

        require((bytes(_name).length > 0) && (_price > 0) && _amount > 0);
        bytes32 hashedProduct = getHashedProduct(_name, _price, _treshold);

        //if we have its hash in mapping, we get number of this product. If we dont, we add product hash to mapping, and create new product position.
        if(ProductHashes[hashedProduct] == 0){
            ProductsCount = ProductsCount.add(1);
            ProductHashes[hashedProduct] = ProductsCount;
            Products[ProductsCount] = Product(ProductsCount, _name, _price, _amount, _treshold);
        } else {
            Products[ProductHashes[hashedProduct]].Amount += _amount;   
        }

        emit ProductAdded(ProductsCount ,_name, _price, _amount, _treshold);
    }

    function buyProduct(uint ProductId, uint amount) public {
        
        require(ProductId <= ProductsCount);                        //checking if we gave right id of product
        Product memory toBuy = Products[ProductId];
        require(amount <= toBuy.Amount);                            //and if we have enough product
              
        uint TotalPrice;

        if ((amount >= toBuy.Treshold) && (toBuy.Treshold != 0)){ 
            TotalPrice = (toBuy.Price.mul((amount.mul(95)))).div(100);         //making 5% discount, if purchase big enough
        } else {
            TotalPrice = toBuy.Price.mul(amount);
        }

        if(toBuy.Amount == amount){                                 //if all of supplied product was bought 
            delete(Products[ProductId]);

            ProductsCount = ProductsCount.sub(1);
            emit ProductRunOut(toBuy.Name);                          //later implement shifting id of elements, so there will be no gaps in mapping
        } else {
            Products[ProductId].Amount = Products[ProductId].Amount.sub(amount);
        }
        
        InvoicesCount = InvoicesCount.add(1);                         //creating new invoice for customer to pay
        Invoices[InvoicesCount] = new Invoice(TotalPrice, InvoicesCount, msg.sender, owner);
        ProductStash[InvoicesCount] = toBuy;

        emit AwaitingPayment(toBuy.Name, amount, TotalPrice, InvoicesCount);
    } 

    function finalizeInvoice(uint InvoiceNumber, bool allPayed) 
    public 
    OnlyOwnedInvoices(InvoiceNumber)                    //this function called only from created invoices 
    {
        if(allPayed){                                   //Invoice payed, remove product from stash, closing deal   
            delete(Invoices[InvoiceNumber]);
            delete(ProductStash[InvoiceNumber]);     
        } else {                                        //Invoice was not payed, we return product back on market
            Product memory toReturn = ProductStash[InvoiceNumber];
            addProduct(toReturn.Name, toReturn.Price, toReturn.Amount, toReturn.Treshold);
            
            delete(Invoices[InvoiceNumber]);
            delete(ProductStash[InvoiceNumber]);
        }
    }

    //Kostyl section
    //thing is, as i understand, we cant access structures from another contract, as theyre not declared there. So we will get info from main contract. 
    //On deploy, this functions shall be deleted
    function GetProduct(uint id) public view  returns (uint, string memory, uint, uint, uint){
        return(Products[id].Id, Products[id].Name, Products[id].Price, Products[id].Amount,  Products[id].Treshold );
    }
    function GetInvoiceAmount(uint id) public view returns (uint256){
        return Invoices[id].GetInvoiceAmount();
    }
}
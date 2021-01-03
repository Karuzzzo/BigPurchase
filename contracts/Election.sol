pragma solidity > 0.4.11;

contract Election{

    struct Candidate{
        uint id;
        string name;
        uint voteCount;
    }
    uint public candidatesCount;
    address owner;
    //list of voters
    mapping(address => bool) public voters;

    //list of candidates
    mapping(uint => Candidate) public candidates;
    
    modifier OnlyOwner(){
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
        addCandidate(("Anatoly"));
    }

    function addCandidate(string memory _name) public OnlyOwner {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }
    function vote (uint _candidateId) public {

        require(!voters[msg.sender]);

        require(_candidateId > 0 && _candidateId<= candidatesCount);

        voters[msg.sender] = true;

        candidates[_candidateId].voteCount++; 
    }
}
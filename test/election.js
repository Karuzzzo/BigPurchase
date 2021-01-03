var Election = artifacts.require("../contracts/Election.sol");

contract("Election", function(accounts){
    var electionInstance;

    it("initializes w 1 candidate", ( ) => {
        Election.deployed()
        .then(instance => instance.candidatesCount())
        .then(count => {assert.equal(count, 1, "There is not 1 candidate"); });
    });

    it("checks candidates for correct values", () => {
        Election.deployed()
        .then (instance => {
        electionInstance = instance;
        electionInstance.candidates(1)
            .then( candidate => {
                assert.equal(candidate.name, "Anatoly");
                assert.equal(candidate.id, 1);
                assert.equal(candidate.voteCount, 0); }
            )
        electionInstance.candidates(2)    
            .then(candidate =>  {               
                assert.equal(candidate.name, "Whatever");
                assert.equal(candidate.id, 2);
                assert.equal(candidate.voteCount, 0); }
            )
        }) 
    })
});

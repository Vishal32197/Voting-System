// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Voting {
    
     struct Candidate {
        uint256 id;
        string name; 
        string proposal;
        address owner; 
        uint256 voteCount;
    }

     struct Voter {
        uint256 id;
        bool exists;
        uint256 voteCount;
        bool hasVoted;
        bool hasDelegated;
        address delegate;
        uint256 vote;
    }

    mapping(address => Voter) public voters;
    mapping(uint256 => Candidate) public candidates;
    mapping(address => bool) public hasVoted;
    address[] public candidateAddresses; 
    address public owner; 
    bool public electionStarted;
    uint256 public totalCandidates;
    uint256 public candidateCount;
  
    modifier onlyOwner() {
        require(msg.sender == owner, "Only admin can call this function");
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    function addCandidate(string memory _name, string memory _proposal, address _owner) public {
        require(msg.sender == owner, "Only contract owner can add candidates");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_proposal).length > 0, "Proposal cannot be empty");
        
        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, _name, _proposal, _owner, 0);
        candidateAddresses.push(_owner);
    }

    function addVoter(address _voter, address _owner) public onlyOwner {
        require(!voters[_voter].exists, "Voter already exists");
        owner = _owner; 
        voters[_voter] = Voter(0, true, 0, false, false, address(0),0);
    }

    function getCandidateCount() public view returns (uint256) {
        return candidateCount;
    }
 
   function getCandidateDetails(uint256 _id) public view returns (uint256, string memory, string memory) {
        require(_id > 0 && _id <= candidateCount, "Invalid candidate ID");

        Candidate memory candidate = candidates[_id];
        return (_id, candidate.name, candidate.proposal);
    }

 function delegateVotingRights(address _delegate) external  {
    require(!voters[msg.sender].hasVoted, "Voter has already voted");
    require(!voters[msg.sender].hasDelegated, "Voting rights already delegated");
    voters[msg.sender].delegate = _delegate;
    voters[msg.sender].hasDelegated = true;
}

   function castVote(uint256 _candidateId) external {
    require(!voters[msg.sender].hasVoted, "Voter has already voted");
    require(_candidateId <= candidateCount && _candidateId > 0, "Invalid candidate ID");
    candidates[_candidateId].voteCount++;
    voters[msg.sender].vote = _candidateId;
    voters[msg.sender].hasVoted = true;
}

function getWinner() external view  returns (string memory, uint256, uint256) {
    require(candidateCount > 0, "No candidates registered");
    Candidate memory winner = candidates[1]; 
    for (uint256 i = 2; i <= candidateCount; i++) {
        if (candidates[i].voteCount > winner.voteCount) {
            winner = candidates[i];
        }
    }
    return (winner.name, winner.id, winner.voteCount);
}
}
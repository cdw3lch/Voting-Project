// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract VotingProject {

    struct Voter {
        bool votedOrNot;
        address delegate;
        uint weight;
        uint votedProposal;
    }

    struct Proposal {
        string name;
        uint voteCount;
    }

    address public chairman;

    Proposal[] public proposals;

    mapping(address => Voter) public voters;

    constructor(string[] memory proposalNames){
        chairman = msg.sender;

        for(uint i=0; i<proposalNames.length;i++){
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount:0
            }));
        }

    }

    function vote(uint proposalIndex) public {
        Voter storage sender = voters[msg.sender];
        require(sender.votedOrNot, "Already voted");
        require(sender.weight != 0, "Has not the right to vote");
        sender.votedOrNot = true;
        sender.votedProposal = proposalIndex;

        proposals[proposalIndex].voteCount += sender.weight;

    }

    function abilityToVote(address voter) public{
        require(msg.sender ==chairman, "Only the Chairman can give the ability to vote");
        require(voters[voter].votedOrNot, "The voter already voted");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    function winningProposal() public view returns (uint winningProposalIndex){
        uint winningVoteCount = 0;
        for(uint i=0; i< proposals.length;i++){
            if(proposals[i].voteCount > winningVoteCount){
                winningVoteCount = proposals[i].voteCount;
                winningProposalIndex = i;
            }
        }
    }

    function delegate(address to) public {
        Voter storage voter = voters[msg.sender];
        require(!voter.votedOrNot, "You already voted");
        require(to != msg.sender, "You can't delegate to yourself");

        while(voters[to].delegate != address(0)){
            to = voters[to].delegate;

            require(to != msg.sender, "found an infinity loop");
        }
        voter.votedOrNot = true;
        voter.delegate = to;
        Voter storage _delegate = voters[to];
        if(_delegate.votedOrNot){
            proposals[_delegate.votedProposal].voteCount += voter.weight;    
        }else{
            _delegate.weight += voter.weight;
        }
    }

    function winnerProposalName() public view returns (string memory winnerName){
        winnerName = proposals[winningProposal()].name;
    }
}

pragma solidity ^0.4.24;

import "./ITokenBurner.sol";
import "../IToken.sol";
import "../IManagedToken.sol";
import "../../../infrastructure/ownership/Ownership.sol";
import "../../../infrastructure/behaviour/IObservable.sol";

/**
 * TokenBurner
 *
 * Provides the ability to burn tokens 
 *
 * #created 11/06/2018
 * #author Frank Bonnet
 */
contract TokenBurner is ITokenBurner, Ownership {

    enum Stages {
        Deploying,
        Deployed
    }

    Stages public stage;
    IManagedToken public token;


    /**
     * Throw if at stage other than current stage
     * 
     * @param _stage expected stage to test for
     */
    modifier at_stage(Stages _stage) {
        require(stage == _stage);
        _;
    }


    /**
     * Only if '_token' is the token that is part of the 
     * token burner
     */
    modifier only_token(address _token) {
        require(_token == address(token));
        _;
    }


    /**
     * Start in the deploying stage
     */
    constructor() public {
        stage = Stages.Deploying;
    } 


    /**
     * Setup token burner
     *
     * @param _token Ref to the token smart-contract
     */
    function setup(address _token) external only_owner at_stage(Stages.Deploying) {
        token = IManagedToken(_token);
    }


    /**
     * After calling the deploy function the token burner 
     * rules become immutable 
     */
    function deploy() external only_owner at_stage(Stages.Deploying) {
        require(IObservable(token).isObserver(this));
        stage = Stages.Deployed;
    }

    
    /**
     * Returns true if '_token' is the token that is 
     * burned by this token burner
     * 
     * @param _token The address being tested
     * @return Whether the '_token' is part of this token burner
     */
    function isToken(address _token) external view returns (bool) {
        return _token == address(token);
    }


    /**
     * Returns the token that is burned by this 
     * token burner
     * 
     * @return The token that is part of this token burner
     */
    function getToken() external view returns (address) {
        return token;
    }


    /**
     * Burn current balance
     */
    function burn() external at_stage(Stages.Deployed) {
        uint balance = IToken(token).balanceOf(this);
        token.burn(this, balance);
    }
}
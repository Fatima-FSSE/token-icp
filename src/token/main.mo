import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

actor Token{

  let owner : Principal = Principal.fromText("flg5g-6b2zt-chi4y-k5hwg-5nibs-5iwye-bhsvo-wq75w-s763w-uthbs-kqe");
  let totalSupply : Nat = 1000000000;
  let symbol : Text = "DANG";

  private stable var balanceEntries: [(Principal, Nat)] = [];

  //A ledger to keep track of Token balances
  private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash); // Arguments value (size of HashMap, key for which to search, How to hash the keys)
  if(balances.size() < 1) {
      Debug.print(debug_show(balances.size()));
      //Adding owner to the ledger as a first entry.
      //using put method "func put(k: K, v: V) insert the value v at key k. Overwrites and existing entry with key"
      balances.put(owner, totalSupply); // adding all the token to the owner.
    };


  //Check balance method
  public query func balanceOf(who: Principal) : async Nat {

    let balance : Nat = switch (balances.get(who)){ 
        case null 0;
        case (?result) result;
    };

    return balance;
  };

  public query func getSymbol() : async Text {
    return symbol;
  };  

  public shared (msg) func payOut() : async Text {
         //Debug.print(debug_show (msg.caller));
        if (balances.get(msg.caller) == null) {
            let amount = 10000;
            let balOfOwner: Nat = await balanceOf(owner);
            let newBalAfterPayout: Nat = balOfOwner - amount;
            balances.put(owner, newBalAfterPayout);
            balances.put(msg.caller, amount);

            return "Success";
        } else {
            return "Already Claimed";
        };
    };

  public shared(msg) func transfer(to: Principal, amount: Nat) : async Text {

    let fromBalance = await balanceOf(msg.caller);
    if (fromBalance > amount ) {
      let newFromBalance: Nat = fromBalance - amount;
      balances.put(msg.caller, newFromBalance);
      let toBalance = await balanceOf(to);
      let newToBalance : Nat = toBalance + amount;
      balances.put(to, newToBalance);
      return "Success";

    } else {
      return "Insufficient Funds";
    };

        
  };

  system func preupgrade() {
    balanceEntries := Iter.toArray(balances.entries());

  };

  system func postupgrade() {
    balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
    if(balances.size() < 1) {
      balances.put(owner, totalSupply); // adding all the token to the owner.
    }
  };

};
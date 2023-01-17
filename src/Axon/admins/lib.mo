import Buffer "mo:base/Buffer";
import Types "../migrations/types";
import SB "mo:stablebuffer/StableBuffer";

module {

    ////////////
    // Types //
    //////////
    
    public type UpgradeData = Types.CurrentAdmin.UpgradeData;


    public class Admins(state: Types.CurrentAxon.State, creator : Principal) : Types.CurrentAxon.AdminInterface {

        //////////
        // API //
        ////////

        SB.add(state.admins, creator);

        public func isAdmin(state: Types.CurrentAxon.State, p : Principal) : Bool {
            for(principal in SB.vals(state.admins)){
                if (principal == p) return true;
            };
            false;
        };


        public func addAdmin(state: Types.CurrentAxon.State,p : Principal, caller : Principal) : () {
            assert(isAdmin(state, caller));
            SB.add<Principal>(state. admins,p);
        };

        public func removeAdmin(state: Types.CurrentAxon.State,p : Principal, caller : Principal) : () {
            assert(isAdmin(state, caller));
            let newAdmins : Buffer.Buffer<Principal> = Buffer.Buffer(0);
            for (principal in SB.vals(state.admins)){
                if(principal != p){
                    newAdmins.add(principal);
                };
            };
            //  Make sure we never have 0 admins left
            assert(newAdmins.size() != 0);
            SB.clear(state.admins);
            for (principal in newAdmins.vals()){
                SB.add(state.admins, principal);
            };
        };

        public func getAdmins(state: Types.CurrentAxon.State) : [Principal] {
            SB.toArray(state.admins);
        };
    };
};
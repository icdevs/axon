module Admins {

    public type UpgradeData = {
        admins : [Principal];
    };

    public type Interface = {
        //  Get the UD before upgrading. 
        preupgrade : () -> UpgradeData;

        // Reinitialize the state of the module after upgrading.
        postupgrade : (ud : ?UpgradeData) -> ();

        //  Check if a principal is an admin.
        isAdmin : (p : Principal) -> Bool;

        //  Add a new principal as admin.
        //  @auth : Admin
        addAdmin : (p : Principal, caller : Principal) -> ();

        //  Remove a principal from the list of admins. 
        //  @auth : admin
        removeAdmin : (p : Principal, caller : Principal) -> ();

        // Get the list of admins.
        getAdmins : () -> [Principal];
    };
};
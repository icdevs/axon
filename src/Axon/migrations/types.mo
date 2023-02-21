import v2_0_1 "./v002_000_001/types";
import v2_0_0_axon "./v002_000_000/axon_types";
import v2_0_2 "./v002_000_002/types";
import v2_0_0_admin "./v002_000_000/admin_types";


module {
  // do not forget to change current migration when you add a new one
  // you should use this field to import types from you current migration anywhere in your project
  // instead of importing it from migration folder itself
  public let CurrentAxon = v2_0_2;
  public let CurrentAdmin = v2_0_0_admin;

  public type Args = {
    init_axons: [v2_0_0_axon.AxonEntries];
    init_admins: ?v2_0_0_admin.UpgradeData;
    creator : Principal;
  };

  public type State = {
    #v0_0_0: {#id; #data:()};
    #v2_0_1: { #id; #data: v2_0_1.State };
    #v2_0_2: { #id; #data: v2_0_2.State };
    // do not forget to add your new migration state types here
  };
};
import React from "react";
import { Link } from "react-router-dom";
import { FaArrowRight } from "react-icons/fa";
import AllAxons from "../components/Axons/AllAxons";
import MyAxons from "../components/Axons/MyAxons";
import Panel from "../components/Containers/Panel";
import { useGlobalContext } from "../components/Store/Store";

export default function Home() {
  const {
    state: { isAuthed },
  } = useGlobalContext();

  return (
    <div className="flex flex-col gap-8 pt-8" suppressHydrationWarning>
      <Panel className="p-8 text-xl custom-panel">
        <div className="container shadow-md p-6 m-2">
          
            Welcome to icVoice.<br/><br/>

            Here we give all token holders a voice by providing a crypto-secure DAOs that track membership and holdings of Tokens and NFTs.  If you hold a token or NFT in one of our supported platforms you should see the corresponding DAO listed below once you log in.<br/><br/>

            Currently we support:<br/><br/>

            <ul className="list-disc  pl-8">
              <li>The SNS-1.</li>
              <li>ICP.</li>
              <li>YourCoin.</li>
              <li>Origyn Foundation</li>
              <li>The Suzanne Walking NFT Collection</li>
              <li>...more to come.</li>
            </ul>

            <br/><br/>

            If you don't see something you think you should see, please see the FAQ at the bottom of this page.
        
        </div>
      </Panel>
      <hr/>
      <Panel className="p-8 text-xl custom-panel">
        <div className="container shadow-md p-6 m-2 flex flex-col gap-4 items-start md:flex-row md:justify-between">
          <span>Manage DAOs</span>
          <Link to="/axon/new" className="rounded-md btn-cta px-4 py-2 text-xl inline-flex gap-2 items-center whitespace-nowrap">
              Create new Governance <FaArrowRight />
          </Link>
        </div>
      </Panel>

      {isAuthed && <MyAxons />}

      <AllAxons />

      <Panel className="p-8 text-xl custom-panel">
       
            FAQ<br/><br/>

            <div className="container shadow-md p-6 m-2">

              Q: I don't see a DAO I expect to be part of and/or it doesn't think I'm a member! Help!<br/><br/>

              A: First, log in!  If you still don't see what you expect to, it may be because of the following issues:<br/><br/>

              <ul className="list-decimal pl-8">
                <li>The account you are logged in with needs at least some of the token to be included in the DAO. Send that account some of the intended token and wait for the next processing cycle. This can vary from DAO to DAO but should not be more than 1/2 of a day.
                </li>
                <li>For OGY and ICP, the transaction logs don't contain principals, so we can't find and attribute your accounts until you tell us about them. You will need to go to the following servers and submit the inject_subaccount function for your principal and sub_accounts.  This will only work for accounts that you can call from(ie. not NNS based accounts. You'll have to use #3 for that.).
                  <ul className="list-disc  pl-8">
                    <li>SNS-1: </li>
                    <li>ICP: </li>
                    </ul>
                </li>
                <li>You use Internet Identity to hold your tokens on the or other application. In this case you will need to delegate your voting rights for those tokens to your principal that you use on this site.  Your principal is listed at the top of the page.  You will need: 1. Your II Principal which you can retrieve from the "My Canisters" page of the NNS Wallet.  2. You will need to retrieve the delegation account you will need to send 0.1 ICP to accomplish the delegation.<br/><br/>
                  <ul className="list-disc  pl-8">
                    <li>SNS-1: </li>
                    <li>ICP: </li>
                    <li>OGY: </li>
                    <li>Suzanne Walking: </li>
                    <li>YourCoin: </li>
                  </ul><br/><br/>

                  Navigate to icScan on the proper icVoice Canister above and call the get_delegation_info function with the proper values(followee is the principal you want to access the dao with, follower would be your NNS Account with a subaccount of null). <br/><br/>

                  You need to send 0.1 ICP from the follower account(this should be your "Main" account on the NNS) to the delegation account.<br/><br/>

                  After sending this transaction, you will need to find your transaction index from:  https://dashboard.internetcomputer.org/transactions and return to the icVoice Canister above on icScan and call process_delegation_info to complete the delegation. <br/><br/>

                  If you ever want to remove the delegation, you need to send 0.1 ICP to the removalAccount and process the delegation again.

                </li>
                
              </ul>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: Can I make proposals?<br/><br/>

              A: Yes. Currently you only need one vote to make a proposal, but if this is abused we'll have to implement a proposal fee(likely coming anyway, but it is open for experimentation for now).<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: What can the DAO do?<br/><br/>

              A: You can make:
              <ul className="list-decimal  pl-8">
                <li>Axon proposals: Set the visibility, policy, minters of the DAO. Don't remove the icVoice canister or it won't work! Mostly people will make "Motions" and vote on them.</li>
                <li>Canister Commands: Call any function on the IC you want to. Sign up for an account on a social media service. Make bets on prediction markets.  Your DAO has a wallet and you can send it tokens and then send them out.</li>
                <li>Neuron Commands: You can wire up hot keys to your neurons and let the DAO control them.  Caution:  If the item doesn't pass quorum and/or execute the vote you may not get rewards. Have a back up plan.</li>
                
              </ul>
              
              .<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: What happens to my delegation fees?<br/><br/>

              A: They are donations to ICDevs and we use them to buy cycles for the service and/or put them in the general treasury to pay for software development on the IC.<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: Can I delegate my stake?<br/><br/>

              A: You sure can! You can either use the delegation method described above(difficult and really just for II based accounts) or you can go to the Axon canister itself an look for the delegate function.  Call it from your account you want to delegate(owner) and included the target_delegate (the person you want to vote for you).  Current liquid democracy is only implemented to a single degree, so you will not follow your delegate's delegate.(Coming soon)<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: What kind of power do these DAOs have?<br/><br/>

              A: They are completely independent of any power to actually execute any code or make decisions. They are basically a good place to run polls and motion proposals for these environments that include all the people that hold non-staked tokens.  It is possible that these communities could adopt these DAOs and give them some powers.  For example, an NFT DAO could give control of the the collection to the DAO that is made up of the owners of the collection.<br/><br/>
            </div>

            <div className="container shadow-md p-6 m-2">
              Q: Who controls this axon instance? I hear that you can change things without permission?<br/><br/>

              A: ICDevs currently controls the axon instance running these DAOs. Once we have the kinks worked out and we know we can upgrade via another Axon instance we will give control of the Axon instance to the BTB DAO and they can upgraded it by consensus.<br/><br/>
            </div>

            <div className="container shadow-md p-6 m-2">

              Q: Can I add a token or NFT?<br/><br/>

              A: Not yet. If there is enough interest we will pursue making this easy. In the mean time, we will work for ICDevs donations.  Please reach out!<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: Can I create a DAO for something else?<br/><br/>

              A: We can create one for you at https://77i6o-oqaaa-aaaag-qbm6q-cai.ic0.app/ or you can deploy your own version of axon by deploying a canister.  See https://github.com/icdevs/axon for more info!<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: Wy is your site so ugly? I want it to be pretty and do more stuff. Why don't you have my desired feature built already?<br/><br/>

              A: Because you haven't submitted any pull request that make it look beautiful and work the way you want it to. This site is supported by the community and we'd be happy for someone to undertake a redesign of it.<br/><br/>

            </div>
        

      </Panel>
    </div>
  );
}

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
          
            Welcome to VoIC.<br/><br/>

            Here we give all token holders a voice by providing a crypto-secure DAOs that track membership and holdings of Tokens and NFTs.  If you hold a token or NFT in one of our supported platforms you should see the corresponding DAO listed below once you log in.<br/><br/>

            Currently we support:<br/><br/>

            <ul className="list-disc  pl-8">
              <li>ICP - available at <a className="shadow-lg shadow-slate-400" href="https://coinbase.com" target="_blank">Coinbase</a> and other exchanges</li>
              <li>Origyn Foundation - (OGY) - Available on <a className="shadow-lg shadow-slate-400" href="https://sonic.com" target="_blank">Sonic.ooo</a>, <a className="shadow-lg shadow-slate-400" href="https://mexc.com" target="_blank">Mexc.com</a>, and <a className="shadow-lg shadow-slate-400" href="https://icpswap.com" target="_blank">icswap.com</a></li>
              <li>The SNS-1 - available at <a className="shadow-lg shadow-slate-400" href="https://icpswap.com" target="_blank">icpswap.com</a></li>
              <li>ckBTC - available at <a className="shadow-lg shadow-slate-400" href="https://icpswap.com" target="_blank">icpswap.com</a></li>
              <li>CigDAO/YourCoin - available at <a className="shadow-lg shadow-slate-400" href="https://cigdao.com" target="_blank">cigdao.com</a></li>
              <li>The Suzanne Walking NFT Collection - Available at <a className="shadow-lg shadow-slate-400" href="https://yumi.art" target="_blank">Yumi</a></li>
              <li>The BTB DAO - Info at <a className="shadow-lg shadow-slate-400" href="https://icdevs.org/BuilderDAO.html" target="_blank">ICDevs.org</a></li>
              <li>...more to come.</li>
            </ul>

            <br/><br/>

            DAOs can do lots of things like hold funds, make canister calls, hold and vote on shared neurons, but they can also play DAO Deathmatch Reversi!<br/><br/>

            <img src="/img/battle.png"/><br/><br/>

            <h2>Reversi DAO Battles!</h2>

            <div>Note: DAOs can only have one game going at a time.</div>

            <table className="table-auto w-full text-sm">
              <thead><tr><td></td><th>ICP</th><th>SNS-1</th><th>YC</th><th>Origyn</th><th>ckBTC</th><th>Suzanne</th><th>BTB DAO</th></tr></thead>
              <tbody>
                <tr>
                  <th>ICP <br/> <a className="underline" href="https://utiy3-bqaaa-aaaam-abe7a-cai.ic0.app/axon/3" target="_blank">play as icp</a><br/>Player name: icp_voic<br/></th>
                  <td className="text-center">X</td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/icp_voic/sns1-voic" target="_blank">watch</a><br/>
                    
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/icp_voic/cigdao_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/icp_voic/ogy_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/icp_voic/ckbtc_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/icp_voic/suzanne_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/icp_voic/btb_dao" target="_blank">watch</a><br/>
                    
                  </td>
                </tr>
                <tr>
                  <th>SNS-1<br/><a className="underline" href="https://utiy3-bqaaa-aaaam-abe7a-cai.ic0.app/axon/0" target="_blank">play as SNS-1</a><br/>Player name: sns_voic<br/></th>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/sns_voic/icp_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">X</td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/sns_voic/cigdao_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/sns_voic/ogy_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/sns_voic/ckbtc_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/sns_voic/suzanne_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/sns_voic/btb_dao" target="_blank">watch</a><br/>
                    
                  </td>
                </tr>
                <tr>
                  <th>CigDAO<br/><a className="underline" href="https://utiy3-bqaaa-aaaam-abe7a-cai.ic0.app/axon/1" target="_blank">play as CigDAO</a><br/>Player name: cigdao_voic<br/></th>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/cigdao_voic/icp_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/cigdao_voic/sns_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  <td className="text-center">X</td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/cigdao_voic/ogy_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/cigdao_voic/ckbtc_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/cigdao_voic/suzanne_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/cigdao_voic/btb_dao" target="_blank">watch</a><br/>
                   
                  </td>
                </tr>
                <tr>
                  <th>Origyn<br/><a className="underline" href="https://utiy3-bqaaa-aaaam-abe7a-cai.ic0.app/axon/2" target="_blank">play as Origyn</a><br/>Player name: ogy_voic<br/></th>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ogy_voic/icp_voic" target="_blank">watch</a><br/>
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ogy_voic/sns_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ogy_voic/cigdao_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  <td className="text-center">X</td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ogy_voic/ckbtc_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ogy_voic/suzanne_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ogy_voic/btb_dao" target="_blank">watch</a><br/>
                    
                  </td>
                </tr>
                <tr>
                  <th>ckBTC<br/><a className="underline" href="https://utiy3-bqaaa-aaaam-abe7a-cai.ic0.app/axon/5" target="_blank">play as Origyn</a><br/>Player name: ckbtc_voic<br/></th>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ckbtc_voic/icp_voic" target="_blank">watch</a><br/>
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ckbtc_voic/sns_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ckbtc_voic/cigdao_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ckbtc_voic/ogy_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  <td className="text-center">X</td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ckbtc_voic/suzanne_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/ckbtc_voic/btb_dao" target="_blank">watch</a><br/>
                    
                  </td>
                </tr>
                <tr>
                  <th>Suzanne<br/><a className="underline" href="https://utiy3-bqaaa-aaaam-abe7a-cai.ic0.app/axon/4" target="_blank">play as Suzanne Walking</a><br/>Player name: suzanne_voic<br/></th>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/suzanne_voic/icp_voic" target="_blank">watch</a><br/>
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/suzanne_voic/sns_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/suzanne_voic/cigdao_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/suzanne_voic/ogy_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/suzanne_voic/ckbtc_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">X</td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/suzanne_voic/btb_dao" target="_blank">watch</a><br/>
                    
                  </td>
                </tr>
                <tr>
                  <th>BTB Dao<br/><a className="underline" href="https://https://77i6o-oqaaa-aaaag-qbm6q-cai.ic0.app/axon/4" target="_blank">play as BTB DAO</a><br/>Player name: suzanne_voic<br/></th>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/btb_dao/icp_voic" target="_blank">watch</a><br/>
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/btb_dao/sns_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/btb_dao/cigdao_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/btb_dao/ogy_voic" target="_blank">watch</a><br/>
                   
                  </td>
                  
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/btb_dao/ckbtc_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">
                    <a className="underline" href="https://afkvi-zyaaa-aaaak-qb4za-cai.ic0.app/#!/observe/btb_dao/suzanne_voic" target="_blank">watch</a><br/>
                    
                  </td>
                  <td className="text-center">X</td>
                </tr>
              </tbody></table>

            <br/><br/>

            <h4>To start a game, your DAO must challenge another dao by issuing a challenge command and voting on it as a DAO. The other DAO must accept:</h4><br/><br/>

            <img src="img/challenge.png" width="30%"/><br/><br/>

            The DAO Names are:<br/>
            btb_voic - The BTB DAO.<br/>
            icp_voic - NNS and ICP holders<br/>
            ogy_voic - OGY token holders<br/>
            sns1_voic - SNS-1 token holders<br/>
            ckBTC_voic - ckBTC token holders<br/>
            suzanne_voic - Co-Owners of the Suzanne Walking Painting <br/><br/>


            <h4>To make move, your DAO must execute a move while it is your turn by voting on a move canister command.(Note: Top left is (0,0)):</h4><br/><br/>

            <img src="img/move.png" width="30%"/><br/><br/>

            If you don't see something you think you should see, please see the FAQ at the bottom of this page.
        
        </div>
      </Panel>
      <hr/>

      



      {isAuthed && <MyAxons />}

      <AllAxons />

      <Panel className="p-8 text-xl custom-panel">
       
            FAQ<br/><br/>

            <div className="container shadow-md p-6 m-2">

              Q:  I don't see the DAO I'm a member of, or I can't see my membership. What can I do?<br/><br/>

              A: First, log in to the platform. If you still can't see your DAO or membership, the following issues might be causing the problem:<br/><br/>

              <ul className="list-decimal pl-8">
                <li>Your account needs to hold some of the DAO's tokens to be recognized as a member. Send some of the token to your account and wait for the next processing cycle. Processing times may vary between DAOs but should not exceed half a day.
                </li>
                <li>For OGY and ICP, transaction logs do not contain principals, so we can't attribute your accounts until you inform us. To do this, you'll need to go to the servers specified for the DAO you're trying to access and submit the inject_subaccount function for your principal and sub-accounts. Note that this method only works for accounts that can be called from and not for NNS-based accounts. If you have an NNS-based account, you'll need to use method #3.
                  <ul className="list-disc  pl-8">
                    <li>ICP: <a className="underline" href="https://icscan.io/canister/3pojq-paaaa-aaaag-abg2a-cai" target ="_blank">icScan</a></li>
                    <li>OGY: <a className="underline" href="https://icscan.io/canister/zj62h-yyaaa-aaaan-qc53q-cai" target ="_blank">icScan</a></li>
                  </ul>

                  <img src="img/inject.png" width="50%"/><br/><br/>
                </li>
                <li>If you're using Internet Identity to hold your tokens, you'll need to delegate your voting rights for those tokens to your principal that you use on this site. Your principal is listed at the top of the page. To delegate, you'll need: 1. Your II Principal, which you can retrieve from the "My Canisters" page of the NNS Wallet. 2. You'll need to retrieve the delegation account, which you can accomplish by requesting the proper account to send to by calling the delegation_info function.<br/><br/>
                  <ul className="list-disc  pl-8">
                    <li>SNS-1: <a className="underline" href="https://icscan.io/canister/g4fug-pyaaa-aaaak-qb4na-cai" target ="_blank">icScan</a></li>
                    <li>ckBTC: <a className="underline" href="https://icscan.io/canister/jio3a-xaaaa-aaaal-ab66q-cai" target ="_blank">icScan</a></li>
                    <li>ICP: <a className="underline" href="https://icscan.io/canister/3pojq-paaaa-aaaag-abg2a-cai" target ="_blank">icScan</a></li>
                    <li>OGY: <a className="underline" href="https://icscan.io/canister/zj62h-yyaaa-aaaan-qc53q-cai" target ="_blank">icScan</a></li>
                    <li>Suzanne Walking: <a className="underline" href="https://icscan.io/canister/sphrk-uaaaa-aaaap-aa2qq-cai" target ="_blank">icScan</a></li>
                    <li>YourCoin: <a className="underline" href="https://icscan.io/canister/uuj6p-miaaa-aaaam-abe7q-cai" target ="_blank">icScan</a></li>
                  </ul><br/><br/>

                 

                  To complete the delegation, navigate to icScan on the proper icVoice Canister above and call the get_delegation_info function with the proper values (followee is the principal you want to access the DAO with, follower would be your NNS Account with a subaccount of null).<br/><br/>

                  <img src="img/delegationinfo.png" width="50%"/><img src="img/result.png" width="50%"/><br/><br/>

                  Next, send 0.1 ICP from the follower account (your "Main" account on the NNS) to the delegation account. After sending this transaction, find your transaction index from https://dashboard.internetcomputer.org/transactions and return to the icVoice Canister above on icScan. For SNS and ckBTC transactions you may need to use ICLighthouse at <a href="https://637g5-siaaa-aaaaj-aasja-cai.raw.ic0.app/token/zfcdd-tqaaa-aaaaq-aaaga-cai" target="_blank">https://637g5-siaaa-aaaaj-aasja-cai.raw.ic0.app/token/zfcdd-tqaaa-aaaaq-aaaga-cai</a> and  <a href="https://637g5-siaaa-aaaaj-aasja-cai.raw.ic0.app/token/zfcdd-tqaaa-aaaaq-aaaga-cai" target="_blank">https://637g5-siaaa-aaaaj-aasja-cai.raw.ic0.app/token/mxzaz-hqaaa-aaaar-qaada-cai</a><br/><br/>
                  
                  <img src="img/process.png" width="50%"/><br/><br/>
                  
                  Finally, call process_delegation_info to complete the delegation. If you ever want to remove the delegation, you need to send 0.1 ICP to the removalAccount and process the delegation again.
                </li>
                
              </ul>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: Can I make proposals?<br/><br/>

              A: Yes an No. Currently only ICDevs can make proposals for each dao, but if you ask us, we'll submit you to be added as a proposer. The DAO must agree.  Once there are other proposers, you're welcome to kick us out or change the parameters of the DAO. If this is abused we'll have to implement a proposal fee(likely coming anyway, but it is open for experimentation for now).<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: What can the DAO do?<br/><br/>

              A: You can make Axon proposals to set the visibility, policy, and minters of the DAO. Don't remove the icVoice canister or it won't work! Mostly, people will make "Motions" and vote on them. You can also make Canister Commands to call any function on the IC you want, such as signing up for an account on a social media service or making bets on prediction markets. Your DAO has a wallet, and you can send it tokens and then send them out. Additionally, you can make Neuron Commands to wire up hot keys to your neurons and let the DAO control them. Caution: If the item doesn't pass quorum and/or execute the vote, you may not get rewards. Have a backup plan.<br/><br/>
              It can also play Reversi!<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: What happens to my delegation fees?<br/><br/>

              A: They are donations to ICDevs and we use them to buy cycles for the service and/or put them in the general treasury to pay for software development on the IC.<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: Can I delegate my stake?<br/><br/>

              A: You can delegate your stake by either using the delegation method described above (which is difficult and really just for II-based accounts) or by going to the Axon canister itself and looking for the delegate function. The VoIC Axon canister is <a href="https://icscan.io/canister/zo74t-vaaaa-aaaan-qc53a-cai" target="_blank">zo74t-vaaaa-aaaan-qc53a-cai</a><br/><br/>


              <img src="img/delegate.png" width="50%"/><br/><br/>
              <img src="img/delegateaxon.png" width="50%"/><br/><br/>

              
              
              
              Call it from your account, which you want to delegate (owner), and include the target_delegate (the person you want to vote for you). Current liquid democracy is only implemented to a single degree, so you will not follow your delegate's delegate. (Coming soon)<br/><br/>

              
            </div>

            <div className="container shadow-md p-6 m-2">

              Q: What kind of power do these DAOs have?<br/><br/>

              A: These DAOs are initially completely independent of any power to execute any code or make decisions on their respective platforms. They are basically a good place to run polls and motion proposals for these environments that include all the people that hold non-staked tokens. It is possible that these communities could adopt these DAOs and give them some powers. For example, an NFT DAO could give control of the collection to the DAO that is made up of the owners of the collection.<br/><br/>
            </div>

            <div className="container shadow-md p-6 m-2">
              Q: Who controls this axon instance? I hear that you can change things without permission?<br/><br/>

              A: ICDevs currently controls the Axon instance running these DAOs. Once we have the kinks worked out and know we can upgrade via another Axon instance, we will give control of the Axon instance to the BTB DAO, and they can upgrade it by consensus.<br/><br/>
            </div>

            <div className="container shadow-md p-6 m-2">

              Q: Can I add a token or NFT?<br/><br/>

              A: Not yet. If there is enough interest, we will pursue making this easy. In the meantime, we will work for ICDevs donations. Please reach out!<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: Can I create a DAO for something else?<br/><br/>

              A: Yes, we can create one for you at https://77i6o-oqaaa-aaaag-qbm6q-cai.ic0.app/, or you can deploy your version of Axon by deploying a canister. See https://github.com/icdevs/axon for more info!<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: How do you track everyone's accounts and keep the site up to date??<br/><br/>

              A: See <a href="https://github.com/icdevs/voic">Github</a>!<br/><br/>

            </div>

            <div className="container shadow-md p-6 m-2">

              Q: Why is your site so ugly? I want it to be pretty and do more stuff. Why don't you have my desired feature built already?<br/><br/>

              A: We haven't built your desired feature because we are supported by the community, and we'd be happy for someone to undertake a redesign of it. If you have a feature request, please submit a pull request, and we'll be happy to work with you to make it happen.<br/><br/>

            </div>
        

      </Panel>

      {isAuthed &&<Panel className="p-8 text-xl custom-panel">
        <div className="container shadow-md p-6 m-2 flex flex-col gap-4 items-start md:flex-row md:justify-between">
          <span>Manage DAOs</span>
          <Link to="/axon/new" className="rounded-md btn-cta px-4 py-2 text-xl inline-flex gap-2 items-center whitespace-nowrap">
              Create new Governance <FaArrowRight />
          </Link>
        </div>
      </Panel>}
    </div>
  );
}

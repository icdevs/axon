import React, { useState } from "react";
import { useIsProposer } from "../../lib/hooks/Axon/useIsProposer";
import Modal from "../Layout/Modal";
import ProposalForm from "../Proposal/ProposalForm";

export default function CanisterCommandModal() {
  const isProposer = useIsProposer();
  const [isOpen, setIsOpen] = useState(false);
  const openModal = () => setIsOpen(true);
  const closeModal = () => setIsOpen(false);

  if (!isProposer) {
    return null;
  }

  return (
    <>
      <div>
        <button
          type="button"
          onClick={openModal}
          className="text-xs px-2 py-1 btn-secondary"
        >
          Canister Command
        </button>
      </div>
      <Modal
        isOpen={isOpen}
        openModal={openModal}
        closeModal={closeModal}
        title="Create Canister Command Proposal"
      >
        <ProposalForm proposalType="CanisterCommand" closeModal={closeModal} />
      </Modal>
    </>
  );
}

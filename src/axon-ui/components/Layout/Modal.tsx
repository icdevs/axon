import { Dialog, Transition } from "@headlessui/react";
import classNames from "classnames";
import React, { Fragment, useRef } from "react";
import { FaTimes } from "react-icons/fa";

export default function Modal({
  title,
  isOpen,
  openModal,
  closeModal,
  children,
  className = "w-full max-w-sm",
}) {
  const cancelButtonRef = useRef();

  return (
    <Transition appear show={isOpen} as={Fragment}>
      <Dialog
        as="div"
        className="fixed inset-0 z-10 overflow-y-auto"
        onClose={closeModal}
        initialFocus={cancelButtonRef}
      >
        <div className="min-h-screen px-4 text-center">
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <Dialog.Overlay className="fixed inset-0" />
          </Transition.Child>

          {/* This element is to trick the browser into centering the modal contents. */}
          <span
            className="inline-block h-screen align-middle"
            aria-hidden="true"
          >
            &#8203;
          </span>
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0 scale-95"
            enterTo="opacity-100 scale-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100 scale-100"
            leaveTo="opacity-0 scale-95"
          >
            <div
              className={classNames(
                "inline-block p-4 my-8 text-left align-middle border bg-white",
                className
              )}
            >
              <div className="flex justify-between pb-2">
                <Dialog.Title
                  as="h3"
                  className="text-lg leading-tight font-bold"
                >
                  {title}
                </Dialog.Title>
                <button
                  type="button"
                  className="cursor-pointer"
                  onClick={closeModal}
                  ref={cancelButtonRef}
                >
                  <FaTimes />
                </button>
              </div>
              {children}
            </div>
          </Transition.Child>
        </div>
      </Dialog>
    </Transition>
  );
}

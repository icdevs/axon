import React from "react";
import { FaGithub, FaTwitter } from "react-icons/fa";

export default function Footer() {
  return (
    <footer className="py-8 flex items-center justify-center gap-4 transition-opacity">
      <a
        href="https://icscan.io/canister/vq3jg-tiaaa-aaaao-ag2uq-cai"
        className="opacity-50 hover:opacity-100"
        target="_blank"
        rel="noopener noreferrer"
      >
        <img src="/img/icscan.jpg" className="w-4" />
      </a>
      <a
        href="https://github.com/icdevs/axon"
        className="opacity-50 hover:opacity-100"
        target="_blank"
        rel="noopener noreferrer"
      >
        <FaGithub />
      </a>
      <a
        href="https://twitter.com/icdevs_org"
        className="opacity-50 hover:opacity-100"
        target="_blank"
        rel="noopener noreferrer"
      >
        <FaTwitter />
      </a><br/>
      <div>Funded by <a href="https://icdevs.org">ICDevs.org</a>. Please consider <a href="https://icdevs.org/donations.html">donating.</a></div>
    </footer>
  );
}

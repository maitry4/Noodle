"use client";

import Link from "next/link";
import { useState } from "react";

export default function Home() {
  const [started, setStarted] = useState(false);
  return (
    <div className="relative flex flex-col items-center justify-center min-h-screen text-[#705D40] overflow-hidden">
      {/* Background video */}
      <video
        autoPlay
        loop
        muted
        playsInline
        className="absolute inset-0 w-full h-full object-cover z-0"
      >
        <source src="/noodle-loop.mp4" type="video/mp4" />
      </video>

      <div className="relative z-20 flex flex-col items-center justify-center">
        <img src="/noodle_image.png" alt="Noodle" className="w-64 h-auto" />
      <p className="text-xl text-[#462703] drop-shadow-md">Your privacy-first AI buddy who roast's you out of your head.</p>
      <h1 className="text-5xl font-bold text-[#462703] mb-4 drop-shadow-lg">Meet Noodle</h1>
        <button className="px-6 py-3  bg-[#fbb422] text-[#462703] font-bold rounded-full shadow-lg hover:shadow-xl transition transform hover:-translate-y-1">
          Download Now
        </button>
      <p className="mt-4 font-bold text-sm bg-[#a3a861] text-[#462703] rounded-full px-3 py-1 z-20">
        1234 rants resolved so far
      </p>
      </div>

      {/* Floating complaint button */}
      <div className="fixed bottom-8 right-8 z-20">
        <Link href="https://forms.gle/uN1tnGJPCHoLQwGw5" target="_blank"className="w-14 h-14 bg-[#462703] text-[#F6ECD8] rounded-full shadow-lg flex items-center justify-center hover:bg-[#D9CFB0] transition">
          &#x1F4AC;
        </Link>
      </div>

      {/* Resolved rants count */}
    </div>
  );
}
/** @type {import('tailwindcss').Config} */

module.exports = {
  content: ["./src/**/*.{html,ts}"],
  theme: {
    extend: {
      transform: ["hover", "focus"],
      translate: ["hover", "focus"],
      transition: ["hover", "focus"],
      duration: ["hover", "focus"],
      ease: ["hover", "focus"],
    },
  },
  plugins: [],
};

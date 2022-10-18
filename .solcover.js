module.exports = {
  skipFiles: ["./ERC4907ProfitShare/test"],
  mocha: {
    grep: "@skip-on-coverage",
    invert: true,
  },
};

const tileset = require("./gen_mem").tileset;

const printCharRow = (n) => {
  console.log(
    Array(8)
      .fill(0)
      .map((_, i) => i)
      .reduce((acc, i) => `${acc}${(n & (1 << i)) === 0 ? " " : "\u25A0"}`, "")
    //   .join("")
  );
};

for (let i = 0; i < 256; i++) {
  console.log(`Char ${i}`);

  const offset = i * 8;
  printCharRow(tileset[offset + 0]);
  printCharRow(tileset[offset + 1]);
  printCharRow(tileset[offset + 2]);
  printCharRow(tileset[offset + 3]);
  printCharRow(tileset[offset + 4]);
  printCharRow(tileset[offset + 5]);
  printCharRow(tileset[offset + 6]);
  printCharRow(tileset[offset + 7]);

  console.log("");
}

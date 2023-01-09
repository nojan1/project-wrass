import { useState } from "react";
import styled from "styled-components";
import ModalContent from "./modal";

const CoolButton = styled.button`
  padding: 5px 20px;
  font-size: 14px;
  margin: 0 auto;
`;

const ImportWindow = ({ inImport, onClose, onDataImported }) => {
  const [rawData, setRawData] = useState("");

  if (!inImport) return null;

  const handleImport = () => {
    const byteData = rawData.split("\n").reduce((acc, line) => {
      line = line.replace(/ /g, "");
      line = line.replace(/\/\/.*/g, "");

      if (line.startsWith("db")) line = line.substring(3).trim();
      console.log(line);
      const data = line
        .split(",")
        .filter((x) => x)
        .map((stringByte) => {
          stringByte = stringByte.trim();

          if (stringByte.startsWith("0x")) return parseInt(stringByte, 16);

          if (stringByte.startsWith("$"))
            return parseInt(stringByte.substr(1), 16);

          if (/^-?\d+$/.test(stringByte)) return parseInt(stringByte);

          return 0;
        });

      return [...acc, ...data];
    }, []);

    const tileData = [];
    for (let offset = 0; offset < byteData.length; offset += 8) {
      const block = [...new Array(8).keys()].map((i) => byteData[offset + i]);
      tileData.push(block);
    }

    if (tileData.length > 0) onDataImported(tileData);
    else alert("No data");

    setRawData("");
    onClose();
  };

  return (
    <ModalContent onClose={onClose}>
      <center>
        <textarea
          cols="70"
          rows="40"
          onChange={(e) => setRawData(e.target.value)}
          value={rawData}
        />
        <CoolButton type="button" onClick={handleImport}>
          Import
        </CoolButton>
      </center>
    </ModalContent>
  );
};

export default ImportWindow;

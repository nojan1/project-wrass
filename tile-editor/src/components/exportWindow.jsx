import { useState } from "react";
import styled from "styled-components";
import ModalContent from "./modal";

const ExportDataContainer = styled.div`
  overflow-y: scroll;
  max-height: 500px;
  background-color: white;
  border: 1px solid black;
  padding: 20px;
  font-size: 18px;
  font-weight: bold;
  font-family: monospace;

  pre {
    margin: 0;
    padding: 0;
  }
`;

const buildAsmExportString = (tiles) => {
  const tileRows = tiles.map((tile) => {
    const encodedBytes = tile.map((x) => `$${x.toString(16)}`);
    return `db ${encodedBytes.join(",")}`;
  });

  return tileRows.join("\n");
};

const buildJsOutputString = (tiles) => {
  const flattened = tiles.reduce((acc, cur) => [...acc, ...cur], []);
  return `[
${flattened.map((x) => `  0x${x.toString(16)}`).join(",\n")}
]`;
};

const ExportWindow = ({ inExport, onClose, tilesToExport }) => {
  const [jsOutput, setJsOutput] = useState(false);

  if (!inExport) return null;

  return (
    <ModalContent onClose={onClose}>
      <input
        type="checkbox"
        value={jsOutput}
        onChange={(e) => setJsOutput(e.target.checked)}
      />
      <span> Use JS output</span>
      <ExportDataContainer>
        <pre>
          {jsOutput
            ? buildJsOutputString(tilesToExport)
            : buildAsmExportString(tilesToExport)}
        </pre>
      </ExportDataContainer>
    </ModalContent>
  );
};

export default ExportWindow;

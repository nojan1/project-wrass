import styled from "styled-components";
import ModalContent from "./modal";

const ExportDataContainer = styled.div`
    overflow-y: scroll;
    max-height: 500px;
    background-color: white;
    border:1px solid black;
    padding: 20px;
    font-size: 18px;
    font-weight: bold;
    font-family: monospace;

    pre {
        margin: 0;
        padding: 0;
    }
`;

const buildExportString = tile => {
    const encodedBytes = tile.map(x => `$${x.toString(16)}`);
    return `db ${encodedBytes.join(',')}`;
}

const ExportWindow = ({
    inExport,
    onClose,
    tilesToExport
}) => {
    if(!inExport)
        return null;

    return (
        <ModalContent onClose={onClose}>
            <ExportDataContainer>
                <pre>
                    {tilesToExport.map(buildExportString).join('\n')}
                </pre>
            </ExportDataContainer>
        </ModalContent>
    ); 
}

export default ExportWindow;
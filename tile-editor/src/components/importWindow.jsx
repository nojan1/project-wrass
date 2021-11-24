import { useState } from "react";
import styled from "styled-components";
import ModalContent from "./modal";

const CoolButton = styled.button`
    padding: 5px 20px;
    font-size: 14px;
    margin:0 auto;
`;

const ImportWindow = ({
    inImport,
    onClose,
    onDataImported
}) => {
    const [rawData, setRawData] = useState("");

    if(!inImport)
        return null;

    const handleImport = () => {
        const tileData = rawData.split('\n').map(line => {
            line = line.replace(/ /g, '');
            line = line.replace(/\/\/.*/g, '');

            if(line.startsWith('db'))
                line = line.substring(3).trim();
            console.log(line);
            return line.split(',').map(stringByte => {
                stringByte = stringByte.trim();

                if(stringByte.startsWith('0x'))
                    return parseInt(stringByte, 16);

                if(stringByte.startsWith('$'))
                    return parseInt(stringByte.substr(1), 16);

                if(/^-?\d+$/.test(stringByte))
                    return parseInt(stringByte);
                
                return 0;
            });
        });
        
        if(tileData.length > 0)
            onDataImported(tileData);
        else
            alert('No data');

        setRawData("");
        onClose();
    }

    return (
        <ModalContent onClose={onClose}>
            <center>
                <textarea cols="70" rows="40" onChange={(e) => setRawData(e.target.value)} value={rawData} />
                <CoolButton type="button" onClick={handleImport}>
                    Import
                </CoolButton>
            </center>
        </ModalContent>
    ); 
}

export default ImportWindow;
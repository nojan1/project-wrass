import styled from "styled-components";
import { useState } from "react";
import ExportWindow from "./exportWindow";
import TileEditor from "./tileEditor";
import Menu from "./menu";
import ImportWindow from "./importWindow";

const TilesWrapper = styled.div`
    padding: 10px;
    margin-right: 50px;
    display: flex;
    flex-wrap: wrap;

    >* {
        margin-right: 10px;
        margin-bottom: 10px;
    }
`;

const TileContainer = () => {
    const [ tiles, setTiles ] = useState([]);
    const [ inExport, setInExport ] = useState(false);
    const [ inImport, setInImport ] = useState(false);

    const handleOnTileAdd = () => {
        setTiles([...tiles, [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]]);
    }

    const handleTileUpdated = (tileIndex, newContent) => {
        setTiles(oldTiles => {
            const newTiles = [...oldTiles];
            newTiles[tileIndex] = newContent;
            return newTiles;
        });
    };
 
    const handleTileDelete = (tileIndex) => {
        if(window.confirm('Do you want to delete?')){
            setTiles(oldTiles => {
                const newTiles = [...oldTiles];
                newTiles.splice(tileIndex, 1);
                return newTiles;
            });
        }
    };

    const handleTilesImported = (data) => {
        setTiles(oldTiles => {
            const newTiles = [...oldTiles];
            
            for(let i = 0;i < data.length; i++){
                newTiles.push(data[i]);
            }

            return newTiles;
        });
    }

    return (
        <>
            <Menu onAddTile={handleOnTileAdd} onExport={() => setInExport(true)} onImport={() => setInImport(true)} />
            <ExportWindow inExport={inExport} onClose={() => setInExport(false)} tilesToExport={tiles} />
            <ImportWindow inImport={inImport} onClose={() => setInImport(false)} onDataImported={handleTilesImported} />

            <TilesWrapper>
                {tiles.map((tile, i) => 
                    <TileEditor 
                        key={i} 
                        tileContents={tile}    
                        onTileContentsChanged={(newContent) => handleTileUpdated(i, newContent)}
                        onTileDeleted={() => handleTileDelete(i)}
                    />
                )}
            </TilesWrapper>
        </>
    );
};

export default TileContainer;
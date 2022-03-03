import { useState } from 'react';
import ColorSelector from './colorSelector';
import styled from 'styled-components';
import IconButton from './iconButton';
import { faTrash } from '@fortawesome/free-solid-svg-icons'

const TileGrid = styled.div`
    display: grid;
    grid-column-gap: 0px;
    grid-row-gap: 0px;
    grid-template-columns: 30px 30px 30px 30px 30px 30px 30px 30px;
    grid-template-rows: 30px 30px 30px 30px 30px 30px 30px 30px;
`;

const TileCell = styled.div`
    display: inline-grid;
    border:1px solid ${props => props.isChecked ? 'transparent' : 'black'};
    background-color: ${props => props.isChecked ? props.foregroundColor : props.backgroundColor};
    cursor: pointer;
`;

const Toolbar = styled.div`
    height: 30px;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: right;
    width: 230px;

    >* {
        margin-left: 5px;
    }
`;

const TileEditor = ({ 
    tileContents,
    onTileContentsChanged,
    onTileDeleted
}) => {    
    const [foregroundColor, setForegroundColor] = useState('black');
    const [backgroundColor, setBackgroundColor] = useState('white');

    const handleClick = (row, index) => {
        const isCurrentlySet = tileContents[row] & (1 << index);

        let newContents = [...tileContents];
        newContents[row] = isCurrentlySet === 0
            ? tileContents[row] | (1 << index)
            : tileContents[row] & ~(1 << index);

        onTileContentsChanged(newContents);
    };

    return (
        <div>
            <Toolbar>
                <input type="checkbox" />
                <ColorSelector setBackgroundColor={setBackgroundColor} setForgroundColor={setForegroundColor} />
                <IconButton icon={faTrash} onClick={onTileDeleted}/>
            </Toolbar>
            
            <TileGrid>
                {tileContents.map((number, row) => 
                    <>
                        {[...Array(8).keys()].map(i => 
                            <TileCell 
                                key={`${row}-${i}`} 
                                isChecked={(number & (1 << i)) !== 0}
                                onClick={() => handleClick(row, i)}      
                                foregroundColor={foregroundColor}
                                backgroundColor={backgroundColor}
                            />    
                        )}
                    </>
                )}
            </TileGrid>
        </div>
    );
};

export default TileEditor;
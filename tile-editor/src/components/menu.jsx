import styled from "styled-components";
import { faPlus, faFileExport, faFileImport } from '@fortawesome/free-solid-svg-icons'
import IconButton from "./iconButton";

const MenuContainer = styled.div`
    position: fixed;
    top:0;
    right:0;
    width: 50px;
    padding: 10px 5px 0 5px;
    background-color: black;
    border-bottom-left-radius: 20px;
    display: flex;
    align-items: center;
    flex-direction: column;

    >* {
        margin-bottom: 10px;
    }
`

const Menu = ({
    onAddTile,
    onExport,
    onImport
}) => (
    <MenuContainer>
        <IconButton icon={faPlus} size='lg' color='white' onClick={onAddTile}/>
        <IconButton icon={faFileExport} size='lg' color='white' onClick={onExport} style={{paddingLeft: '10px'}}/>
        <IconButton icon={faFileImport} size='lg' color='white' onClick={onImport}/>
    </MenuContainer>
);

export default Menu;
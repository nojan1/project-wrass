import { useState } from "react";
import ModalContent from "./modal";
import styled from "styled-components";
import IconButton from "./iconButton";
import { faBrush } from '@fortawesome/free-solid-svg-icons'

const COLORS = [
    'rgb(0,0,0)',
    'rgb(255,255,255)',
    'rgb(0,0,170)',
    'rgb(0,170,0)',
    'rgb(170,0,0)',
    'rgb(0,0,85)',
    'rgb(0,85,85)',
    'rgb(85,0,0)',
    'rgb(0,85,170)',
    'rgb(170,0,85)',
    'rgb(85,170,85)',
    'rgb(170,0,170)',
    'rgb(255,255,0)',
    'rgb(255,170,255)',
    'rgb(80,80,80)',
    'rgb(40,40,40)',
];

const ColorCell = styled.div`
    width: 30px;
    height: 30px;
    border: 1px solid black;
    background-color: ${props => props.color};
    cursor: pointer;
`; 

const ColorsContainer = styled.div`
    display: flex;
    flex-direction: row;
`;

const ColorRow = ({
    onColorSelected
}) => (
    <ColorsContainer>
        {COLORS.map((color, i) => 
            <ColorCell 
                key={i}
                color={color}
                onClick={() => onColorSelected(color)}
            />
        )}
    </ColorsContainer>
);

const ColorSelector = ({
    setBackgroundColor,
    setForgroundColor
}) => {
    const [isOpen, setIsOpen] = useState(false);


    return (
        <>
        <IconButton icon={faBrush} onClick={() => setIsOpen(true)}/>

         {isOpen ? 
            <ModalContent onClose={() => setIsOpen(false)}>
                <h4>Forground</h4>
                <ColorRow 
                    onColorSelected={setForgroundColor}
                />

                <h4>Background</h4>
                <ColorRow 
                    onColorSelected={setBackgroundColor}
                />
            </ModalContent> 
        : null}
        </>
    );
};

export default ColorSelector;
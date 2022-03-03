import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import styled from "styled-components";
import { faWindowClose } from '@fortawesome/free-solid-svg-icons'

const ModalBackdrop = styled.div`
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(60,60,60,0.3);
    z-index: 10;
    display: flex;
    justify-content: center;
    align-items: center;
`;

const ModalContainer = styled.div`
    max-width: 600px;
    border-radius:2px;
    background-color: #e0e0e0;
    z-index: 11;
`

const ModalContainerInner = styled.div`
    clear:both;
    padding: 20px;
`

const CloseButton = styled(FontAwesomeIcon)`
    cursor: pointer;
    float: right;
`;

const ModalContent = ({children, onClose}) => (
    <ModalBackdrop>
        <ModalContainer>
            {onClose ? 
                <CloseButton icon={faWindowClose} onClick={onClose} size='2x'/>
            : null }
            
            <ModalContainerInner>
                {children}
            </ModalContainerInner>
        </ModalContainer>
    </ModalBackdrop>
);

export default ModalContent;
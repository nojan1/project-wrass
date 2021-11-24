import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import styled from "styled-components";

const StyledFontAwesomeIcon = styled(FontAwesomeIcon)`
    cursor: pointer;
`;

const IconButton = (props) => (
    <StyledFontAwesomeIcon {...props} />
);

export default IconButton;
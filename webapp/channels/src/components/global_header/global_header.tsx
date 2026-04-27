// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import React, {useEffect} from 'react';
import styled from 'styled-components';

import {useCurrentProductId} from 'utils/products';

import CenterControls from './center_controls/center_controls';
import {useIsLoggedIn} from './hooks';
import LeftControls from './left_controls/left_controls';
import RightControls from './right_controls/right_controls';

const GlobalHeaderContainer = styled.header`
    position: relative;
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: space-between;
    height: 44px;
    color: rgba(var(--sidebar-text-rgb), 0.64);
    padding: 0 4px 0 8px;
    z-index: 99;

    > * + * {
        margin-left: 12px;
    }

    @media screen and (max-width: 768px) {
        display: none;
    }
`;

const GlobalHeader = (): JSX.Element | null => {
    const isLoggedIn = useIsLoggedIn();
    const currentProductID = useCurrentProductId();

    useEffect(() => {
        const buildTime = new Date().toISOString();
        console.log(`[Mattermost Build Debug] GlobalHeader rendered at ${buildTime}`);
        console.log('[Mattermost Build Debug] Eye button (icon: mắt) has been added to RightControls - EyeButton component is active');
    }, []);

    if (!isLoggedIn) {
        return null;
    }

    return (
        <GlobalHeaderContainer 
            id='global-header'
            data-build-timestamp={new Date().toISOString()}
        >
            <LeftControls/>
            <CenterControls productId={currentProductID}/>
            <RightControls productId={currentProductID}/>
        </GlobalHeaderContainer>
    );
};

export default GlobalHeader;

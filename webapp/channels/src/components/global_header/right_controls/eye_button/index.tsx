// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import React from 'react';
import {FormattedMessage, useIntl} from 'react-intl';
import {EyeOutlineIcon} from '@mattermost/compass-icons/components';

import WithTooltip from 'components/with_tooltip';

const EyeButton = (): JSX.Element => {
    const {formatMessage} = useIntl();

    const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
        e.preventDefault();
        // Open /zabbix_monitor/ in a new tab
        window.open(`${window.location.origin}/zabbix_monitor/`, '_blank');
    };

    return (
        <WithTooltip
            title={(
                <FormattedMessage
                    id='global_header.preview'
                    defaultMessage='Preview'
                />
            )}
        >
            <button
                type='button'
                className='HeaderIconButton'
                onClick={handleClick}
                data-testid='previewButton'
                aria-label={formatMessage({id: 'global_header.preview', defaultMessage: 'Preview'})}
            >
                <EyeOutlineIcon
                    size={18}
                    color={'currentColor'}
                    aria-hidden='true'
                />
            </button>
        </WithTooltip>
    );
};

export default EyeButton;

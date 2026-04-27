import React from 'react';
import {FormattedMessage, useIntl} from 'react-intl';

import WithTooltip from 'components/with_tooltip';

const ZabbixMonitorButton = (): JSX.Element => {
    const {formatMessage} = useIntl();

    const openZabbixMonitor = (e: React.MouseEvent<HTMLButtonElement>) => {
        e.preventDefault();
        window.location.href = `${window.location.origin}/zabbix_monitor/`;
    };

    return (
        <WithTooltip
            title={
                <FormattedMessage
                    id='global_header.zabbixMonitor'
                    defaultMessage='Zabbix monitor'
                />
            }
        >
            <button
                type='button'
                className='HeaderIconButton'
                onClick={openZabbixMonitor}
                aria-label={formatMessage({id: 'global_header.zabbixMonitor', defaultMessage: 'Zabbix monitor'})}
            >
                <svg
                    width='16'
                    height='16'
                    viewBox='0 0 24 24'
                    fill='none'
                    xmlns='http://www.w3.org/2000/svg'
                    aria-hidden='true'
                    focusable='false'
                >
                    <rect
                        x='3'
                        y='4'
                        width='18'
                        height='12'
                        rx='2'
                        stroke='currentColor'
                        strokeWidth='2'
                    />
                    <path
                        d='M9 20H15'
                        stroke='currentColor'
                        strokeWidth='2'
                        strokeLinecap='round'
                    />
                    <path
                        d='M12 16V20'
                        stroke='currentColor'
                        strokeWidth='2'
                        strokeLinecap='round'
                    />
                </svg>
            </button>
        </WithTooltip>
    );
};

export default ZabbixMonitorButton;

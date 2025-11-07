import React, { useEffect, useState } from 'react';
import BackupRestoreSettings from '../../components/Backup/RestoreSettings/BackupRestoreSettings';
import { useNavigate } from 'react-router-dom';
import Backups from '../Backups/Backups';
import QueryString from 'qs';
import { Helmet } from 'react-helmet';
import { useSelector } from 'react-redux';

export default function BackupWrapper(props) {
  const { i18n } = useSelector(state => state.session);
  const navigate = useNavigate();
  const parsedQueryString = QueryString.parse(window.location.search, { ignoreQueryPrefix: true });
  const [isBackupSettings, setIsBackupSettings] = useState(false);

  useEffect(() => {
    if (parsedQueryString.backup) {
      setIsBackupSettings(true);
    } else {
      setIsBackupSettings(false);
    }
  }, [window.location]);

  return (
    <>
      <Helmet>
        <title>{`Vesta - ${i18n.DNS}`}</title>
      </Helmet>
      {
        isBackupSettings
          ? <BackupRestoreSettings backup={parsedQueryString.backup} />
          : <Backups {...props} changeSearchTerm={props.changeSearchTerm} />
      }
    </>
  );
}
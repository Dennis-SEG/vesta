import React, { useEffect, useState } from 'react';
import MailAccounts from '../MailAccounts/MailAccounts';
import { useNavigate } from 'react-router-dom';
import Mails from '../Mails/Mails';
import QueryString from 'qs';
import { Helmet } from 'react-helmet';
import { useSelector } from 'react-redux';

export default function MailWrapper(props) {
  const { i18n } = useSelector(state => state.session);
  const [mailDomain, setMailDomain] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    const parsedQueryString = QueryString.parse(window.location.search, { ignoreQueryPrefix: true });

    if (parsedQueryString.domain) {
      setMailDomain(parsedQueryString.domain);
    } else {
      setMailDomain('');
    }
  }, [window.location]);

  return (
    <>
      <Helmet>
        <title>{`Vesta - ${i18n.MAIL}`}</title>
      </Helmet>
      {
        mailDomain
          ? <MailAccounts {...props} domain={mailDomain} changeSearchTerm={props.changeSearchTerm} />
          : <Mails {...props} changeSearchTerm={props.changeSearchTerm} />
      }
    </>
  );
}
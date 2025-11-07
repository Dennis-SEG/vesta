import React, { useEffect, useState } from 'react';
import EditMailAccount from 'src/components/MailAccount/Edit/EditMailAccount';
import EditMail from 'src/components/Mail/Edit/EditMail';
import { useNavigate } from 'react-router-dom';
import QueryString from 'qs';
import { Helmet } from 'react-helmet';
import { useSelector } from 'react-redux';

export default function EditMailWrapper() {
  const { i18n } = useSelector(state => state.session);
  const navigate = useNavigate();
  const parsedQueryString = QueryString.parse(window.location.search, { ignoreQueryPrefix: true });
  const [isMailAccount, setIsMailAccount] = useState(false);

  useEffect(() => {
    if (parsedQueryString.domain && parsedQueryString.account) {
      setIsMailAccount(true);
    } else {
      setIsMailAccount(false);
    }
  }, [window.location]);

  return (
    <>
      <Helmet>
        <title>{`Vesta - ${i18n.MAIL}`}</title>
      </Helmet>
      {
        isMailAccount
          ? <EditMailAccount domain={parsedQueryString.domain} account={parsedQueryString.account} />
          : <EditMail />
      }
    </>
  );
}
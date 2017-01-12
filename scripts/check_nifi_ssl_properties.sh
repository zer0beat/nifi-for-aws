#!/bin/bash

NIFI_PROPERTIES_FILE='/opt/nifi/conf/nifi.properties'

echo '              NIFI PROPERTIES CHECKER'
echo '-------------------------------------------------------'

echo 'SECURITY PROPERTIES'

printf '\n%s\n' 'Check KeyStore path is set'
grep 'nifi.security.keystore=' $NIFI_PROPERTIES_FILE --color=auto

printf '\n%s\n' '..Check KeyStore type [jks]'
grep 'nifi.security.keystoreType' $NIFI_PROPERTIES_FILE --color=auto

printf '\n%s\n' '..Check KeyStore password is set'
grep 'nifi.security.keystorePasswd' $NIFI_PROPERTIES_FILE --color=auto

printf '\n%s\n' '..Check KeyStore Certificate password is set'
grep 'nifi.security.keyPasswd' $NIFI_PROPERTIES_FILE --color=auto

printf '\n%s\n' '..Check TrusStore path is set'
grep 'nifi.security.truststore=' $NIFI_PROPERTIES_FILE --color=auto

printf '\n%s\n' '..Check TrusStore type [jks]'
grep 'nifi.security.truststoreType' $NIFI_PROPERTIES_FILE --color=auto

printf '\n%s\n' '..Check TrusStore password is set'
grep 'nifi.security.truststorePasswd' $NIFI_PROPERTIES_FILE --color=auto

printf '\n%s\n' '..Check connecting clients authentication [true]'
grep 'nifi.security.needClientAuth' $NIFI_PROPERTIES_FILE --color=auto

echo ''
echo 'ADDITIONAL SETTINGS:'
echo '-------------------------------------------------------'

printf '\n%s\n' '..Check which hostname runs the server'
echo "[...] <<This allows admins to configure the application to run only on specific network interfaces. If it is desired that the HTTPS interface be accessible from all network interfaces, a value of 0.0.0.0 should be used.>>"
grep 'nifi.web.https.host' $NIFI_PROPERTIES_FILE --color=auto

printf '\n%s\n' '..Check http port is unset'
grep 'nifi.web.http.port' $NIFI_PROPERTIES_FILE --color=auto


echo ''
echo '-------------------------------------------------------'
echo 'NODES CONNECTION PROPERTIES'

printf '\n%s\n' '..Check is true'
grep 'nifi.remote.input.secure' $NIFI_PROPERTIES_FILE --color=auto

printf '\n%s\n' '..Check is true'
grep 'nifi.cluster.protocol.is.secure' $NIFI_PROPERTIES_FILE --color=auto

echo ''
echo '-------------------------------------------------------'
echo 'USERS AUTHENTICATION PROPERTIES'


printf '\n%s\n' '..Check only certificate login is accepted [unset]
'
grep 'nifi.security.user.login.identity.provider' $NIFI_PROPERTIES_FILE --color=auto



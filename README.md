El objetivo es la creación de 2 contenedores docker que aloje cada uno un sevidor LDAP con Réplicación Multio-Master y comunicación segura por TLS, e incular ambos para que funcionen como uno.

# openldap-schema
El servidor LDAP ( OpenLdap) se basa en [openldap-osixia](https://github.com/osixia/docker-openldap)

# Pasos
1. Crear un dominio para los servidores OpenLDAP (**ldap1.decieloytierra.es**)
1. Ejecutar el script del Makefile para creación de sevidores LDAP con Réplicación --> **make replica**
1. Comprobar que funciona la funcionalidad de Réplica
  - Probamos en el contenedor 1 (**openldap1**)
```
  docker cp ~/foramontano/openldap-schema/service/slapd/assets/test/nuevo_usuario.ldif openldap1:/container/service/slapd/assets/test/
  docker exec openldap1 ldapadd -x -D "cn=admin,dc=decieloytierra,dc=es" -w masAl3gr1a+12 -f /container/service/slapd/assets/test/nuevo_usuario.ldif -H ldap://ldap1.decieloytierra.es -ZZ
 ```
  - Probamos en el contenedor 2 (**openldap2**)
```
  docker cp ~/foramontano/openldap-schema/service/slapd/assets/test/nuevo_usuario2.ldif openldap2:/container/service/slapd/assets/test/
  docker exec openldap2 ldapadd -x -D "cn=admin,dc=decieloytierra,dc=es" -w masAl3gr1a+12 -f /container/service/slapd/assets/test/nuevo_usuario.ldif -H ldap://ldap2.decieloytierra.es -ZZ
 ```
## Consultas de interés
```
# Consulta contexto base
ldapsearch -x -LLL -b "" -s base namingContexts

# Consulta configuración (relacionado con TLS)
sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | grep olcTLS

# Consulta configuración réplicación MULTI-MASTER
sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | grep olcSyncrepl
sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | grep olcModuleLoad

# Lista de esquemas importados al servidor LDAP
sudo ldapsearch -LLLQY EXTERNAL -H ldapi:/// -b cn=schema,cn=config | grep dn:

# Consulta al servidor LDAP mediante TLS
ldapsearch -x -ZZ

# Consulta a un servidor LDAP con TLS activado (-ZZ).
ldapsearch -x -H ldap://ldap2.decieloytierra.es:390 -b dc=decieloytierra,dc=es -D "cn=admin,dc=decieloytierra,dc=es" -w masAl3gr1a+12 -ZZ | grep dn

```
 




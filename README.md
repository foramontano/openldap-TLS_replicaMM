# foramontano/openldap-schema
El objetivo es la creación de 2 contenedores docker que alojen cada uno un sevidor LDAP (OpenLdap) con Réplicación Multio-Master y comunicación segura por TLS, y vincular ambos para que funcionen como uno.

# openldap-schema
El servidor LDAP ( OpenLdap) se basa en [openldap-osixia](https://github.com/osixia/docker-openldap)

# Pasos
## 1. Crear un dominio para los servidores OpenLDAP 
Creo en el área de gestión de DNS un dominio de trabajo para los servidores: **ldap1.decieloytierra.es**
## 2. Generar los certificados, mediante Let's Encrypt, asociados al dominioi recién creado
```
sudo certbot --nginx -d ldap1.decieloytierra.es
```
En este caso lo hago a través de **NGINX** que es el servidor WEB que tengo instalado en el **servidor ANFITRIÓN**

## 3. Ejecutar el script del Makefile para creación de sevidores LDAP con Réplicación 
```
make replica**
```
Al ejecutar el script se crearán dos contenedores (**openldap1** y **openldap2**) vinculados entre sí
- El contenedor 1 estará escuchando en el puerto 389 --> ldap://ldap1.decieloytierra.es
- El contenedor 2 estará escuchando en el puerto 390 --> ldap://ldap1.decieloytierra.es:390

## 3. Comprobar que funciona la funcionalidad de Réplica
  - Probamos en el contenedor 1 (**openldap1**)
```
  docker cp ~/foramontano/openldap-schema/service/slapd/assets/test/nuevo_usuario.ldif openldap1:/container/service/slapd/assets/test/
  docker exec openldap1 ldapadd -x -D "cn=admin,dc=decieloytierra,dc=es" -w password -f /container/service/slapd/assets/test/nuevo_usuario.ldif -H ldap://ldap1.decieloytierra.es -ZZ
 # Consulto en el servidor 2 a ver si se ha replicado la información del usuario recuén creado en el servidor 1
 ldapsearch -x -H ldap://ldap1.decieloytierra.es:390 -b dc=decieloytierra,dc=es -D "cn=admin,dc=decieloytierra,dc=es" -w password -ZZ | grep dn
 ```
  - Probamos en el contenedor 2 (**openldap2**)
```
  docker cp ~/foramontano/openldap-schema/service/slapd/assets/test/nuevo_usuario2.ldif openldap2:/container/service/slapd/assets/test/
  docker exec openldap2 ldapadd -x -D "cn=admin,dc=decieloytierra,dc=es" -w password -f /container/service/slapd/assets/test/nuevo_usuario.ldif -H ldap://ldap2.decieloytierra.es -ZZ
 # Consulto en el servidor 1 a ver si se ha replicado la información del usuario recuén creado en el servidor 2
 ldapsearch -x -H ldap://ldap1.decieloytierra.es -b dc=decieloytierra,dc=es -D "cn=admin,dc=decieloytierra,dc=es" -w password -ZZ | grep dn
 ```
### Consultas de interés
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
ldapsearch -x -H ldap://ldap1.decieloytierra.es:390 -b dc=decieloytierra,dc=es -D "cn=admin,dc=decieloytierra,dc=es" -w password -ZZ | grep dn

```
 





FROM osixia/openldap:1.3.0
MAINTAINER Isidoro Nevares Martín  <isidoronm@germinadordetalentos.com>

# Elementos que quiero que se ejecuten mientras "arranca" el contenedor
ADD service/slapd/assets/bootstrap /container/service/slapd/assets/config/bootstrap

# Script que permite añadir nuevos schemas una vez levantado el contenedor
COPY service/slapd/assets/add_schemas.sh /container/service/slapd/assets

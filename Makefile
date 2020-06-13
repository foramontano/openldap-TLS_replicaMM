NAME = foramontano/openldap-schema
VERSION = 0.1.0
NOMBRE_CONTENEDOR_LDAP=openldap

.PHONY: all build build-nocache

all: build deploy

build:
	docker build -t $(NAME):$(VERSION) --rm .

deploy:
	docker run \
		--name $(NOMBRE_CONTENEDOR_LDAP) -p 389:389 -p 636:636 \
		--volume /etc/letsencrypt:/container/service/slapd/assets/certs \
		--volume $(PWD)/service/slapd/assets/schema:/container/service/slapd/assets/schema \
		--env-file .env \
		--env LDAP_TLS=true \
		--env LDAP_TLS_ENFORCE=false \
		--env LDAP_TLS_CIPHER_SUITE=SECURE256:-VERS-SSL3.0 \
		--env LDAP_TLS_PROTOCOL_MIN=3.1 \
		--env LDAP_TLS_VERIFY_CLIENT=demand \
		--env LDAP_TLS_CRT_FILENAME=live/ldap.decieloytierra.es/cert.pem \
		--env LDAP_TLS_KEY_FILENAME=live/ldap.decieloytierra.es/privkey.pem \
		--env LDAP_TLS_CA_CRT_FILENAME=live/ldap.decieloytierra.es/fullchain.pem \
		--detach foramontano/openldap-fdschema:0.1.0

build-nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm .

NAME = foramontano/openldap-schema
VERSION = 0.1.0

NOMBRE_CONTENEDOR_LDAP1=openldap1
HOSTNAME1=ldap1.decieloytierra.es
IP1=172.17.0.2

NOMBRE_CONTENEDOR_LDAP2=openldap2
HOSTNAME2=ldap2.decieloytierra.es
IP2=172.17.0.3

.PHONY: all build build-nocache

all: build deploy

build:
	docker build -t $(NAME):$(VERSION) --rm .

deploy: deploy1 deploy2

deploy1:
	docker run --hostname $(HOSTNAME1)\
		--name $(NOMBRE_CONTENEDOR_LDAP1) -p 389:389 \
		--volume $(NOMBRE_CONTENEDOR_LDAP1)-database:/var/lib/ldap \
		--volume $(NOMBRE_CONTENEDOR_LDAP1)-config:/etc/ldap/slapd.d \
		--volume /etc/letsencrypt:/container/service/slapd/assets/certs \
		--env-file=$(PWD)/.env \
		--env LDAP_TLS_CRT_FILENAME=live/$(HOSTNAME1)/cert.pem \
		--env LDAP_TLS_KEY_FILENAME=live/$(HOSTNAME1)/privkey.pem \
		--env LDAP_TLS_CA_CRT_FILENAME=live/$(HOSTNAME1)/fullchain.pem \
		--detach $(NAME):$(VERSION) --loglevel debug

deploy2:
	docker run --hostname $(HOSTNAME2) \
		--name $(NOMBRE_CONTENEDOR_LDAP2) -p 390:389 \
		--volume $(NOMBRE_CONTENEDOR_LDAP2)-database:/var/lib/ldap \
		--volume $(NOMBRE_CONTENEDOR_LDAP2)-config:/etc/ldap/slapd.d \
		--volume /etc/letsencrypt:/container/service/slapd/assets/certs \
		--env-file=$(PWD)/.env \
		--env LDAP_TLS_CRT_FILENAME=live/$(HOSTNAME2)/cert.pem \
		--env LDAP_TLS_KEY_FILENAME=live/$(HOSTNAME2)/privkey.pem \
		--env LDAP_TLS_CA_CRT_FILENAME=live/$(HOSTNAME2)/fullchain.pem \
		--detach $(NAME):$(VERSION) --loglevel debug

replica: replica1 replica2

replica1:
	docker run --hostname $(HOSTNAME1)\
		--name $(NOMBRE_CONTENEDOR_LDAP1) -p 389:389 \
		--ip $(IP1) --add-host $(HOSTNAME2):$(IP2) \
		--volume $(NOMBRE_CONTENEDOR_LDAP1)-database:/var/lib/ldap \
		--volume $(NOMBRE_CONTENEDOR_LDAP1)-config:/etc/ldap/slapd.d \
		--volume /etc/letsencrypt:/container/service/slapd/assets/certs \
		--env-file=$(PWD)/.env \
		--env LDAP_TLS_CRT_FILENAME=live/$(HOSTNAME1)/cert.pem \
		--env LDAP_TLS_KEY_FILENAME=live/$(HOSTNAME1)/privkey.pem \
		--env LDAP_TLS_CA_CRT_FILENAME=live/$(HOSTNAME1)/fullchain.pem \
		--env LDAP_REPLICATION=true \
		--env LDAP_REPLICATION_HOSTS="#PYTHON2BASH:['ldap://$(HOSTNAME1)','ldap://$(HOSTNAME2)']" \
		--detach $(NAME):$(VERSION) --loglevel debug

replica2:
	docker run --hostname $(HOSTNAME2) \
		--name $(NOMBRE_CONTENEDOR_LDAP2) -p 390:389 \
		--ip $(IP2) --add-host $(HOSTNAME1):$(IP1) \
		--volume $(NOMBRE_CONTENEDOR_LDAP2)-database:/var/lib/ldap \
		--volume $(NOMBRE_CONTENEDOR_LDAP2)-config:/etc/ldap/slapd.d \
		--volume /etc/letsencrypt:/container/service/slapd/assets/certs \
		--env-file=$(PWD)/.env \
		--env LDAP_TLS_CRT_FILENAME=live/$(HOSTNAME1)/cert.pem \
		--env LDAP_TLS_KEY_FILENAME=live/$(HOSTNAME1)/privkey.pem \
		--env LDAP_TLS_CA_CRT_FILENAME=live/$(HOSTNAME1)/fullchain.pem \
		--env LDAP_REPLICATION=true \
		--env LDAP_REPLICATION_HOSTS="#PYTHON2BASH:['ldap://$(HOSTNAME2)','ldap://$(HOSTNAME1)']" \
		--detach $(NAME):$(VERSION) --loglevel debug

build-nocache:
	docker build -t $(NAME):$(VERSION) --no-cache --rm .

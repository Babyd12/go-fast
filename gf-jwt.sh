#!/bin/bash

#Installation de jwt 
# composer require lexik/jwt-authentication-bundle

#Dans cette commande, echo "JWT_PASSPHRASE" génère la passphrase et la passe à la commande openssl via stdin.
# echo "JWT_PASSPHRASE" | openssl genrsa -out config/jwt/private.pem -aes256 -passout stdin 4096
# 
# openssl rsa -pubout -in config/jwt/private.pem -out config/jwt/public.pem -passin pass:JWT_PASSPHRASE

#Ces commandes supprimeront la ligne contenant "JWT_PASSPHRASE" dans le fichier .env et ajouteront la nouvelle ligne avec la valeur contenu dans le "echo"
# sed -i '/JWT_PASSPHRASE/d' .env
# echo 'JWT_PASSPHRASE=JWT_PASSPHRASE' >> .env

#Ajoute les configuration dans config/packages/security.yaml

    #\n\ indique un retour à la ligne et une continuté d'exécution
    # pour arriver a main il faut 12 espace soit 3 tab + 1 espace
    # le "\" a la fin c'est pour indiquer que la commande continue sinon la commande sarrete des qu'il que des ya un espace sur le reste de la ligne
sed -i '/providers: app_user_provider/a\
            # Add by go-fast-jwt\n\
            entry_point: jwt\
            json_login:\
                check_path: /auth\
                username_path: email\
                password_path: password\
            success_handler: lexik_jwt_authentication.handler.authentication_success\
            failure_handler: lexik_jwt_authentication.handler.authentication_failure' config/packages/security.yaml

sed -i '/access_control:/a\
        # Add by go-fast-jwt\n\
        - { path: ^/api, roles: PUBLIC_ACCESS }' config/packages/security.yaml

#Ajoute les configuration dans config/routes.yaml
sed -i '/type: attribute/a\
# Add by go-fast-jwt\
auth:\
    path: /auth\
    methods: ['/POST']' config/routes.yaml


# j'efface tout le contenu après la ligne contenant "version" et le remplacer par "Un autre code commençant par add by"
    #---explication
    # '^'api_platform: : Recherche la ligne qui commence par api_platform:
    # ',' : Séparateur pour délimiter la plage de lignes à considérer.
    # '^ version:'  : Recherche la ligne qui commence par quatre espaces et contient version:
sed -i '/^api_platform:/,/^    version:/!d' config/packages/api_platform.yaml

#recherche la ligne "version et ajoute du code "
sed -i '/version:/a\
    # Add by go-fast-jwt\n\
    eager_loading:\
        fetch_partial: \
    defaults:\
        pagination_client_enabled: true\
        pagination_client_items_enabled: true\
    swagger:\
        api_keys:\
            JWT:\
                name: Authorization\
                type: header' config/packages/api_platform.yaml


#-----------ACCROYME
# a : after
# $d : delete all lines
# -i /hello/ : search word helle 

# '^'api_platform: : Recherche la ligne qui commence par api_platform:
# ',' : Séparateur pour délimiter la plage de lignes à considérer.
# '^ version:'  : Recherche la ligne qui commence par quatre espaces et contient version:


#\n\ indique un retour à la ligne et une continuté d'exécution
# pour arriver a main il faut 12 espace soit 3 tab + 1 espace
# le "\" a la fin c'est pour indiquer que la commande continue sinon la commande sarrete des qu'il que des ya un espace sur le reste de la ligne
#au début cétais comme ça: sed -i '/main:/a\        entry_point: jwt\n        json_login:\n            check_path: /auth' fichier.yaml



#PAS DESPACE VERTICAL OU HORIZONTAL
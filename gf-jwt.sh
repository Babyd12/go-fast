#!/bin/bash
#version -1.1
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

awk '/provider: app_user_provider/ {
    print
    getline
    if($0 !~ /# Add by go-fast-jwt/){
        print "            # Add by go-fast-jwt"
        print "            entry_point: jwt"
        print "            json_login:"
        print "                check_path: /auth"
        print "                username_path: email"
        print "                password_path: password"
        print "            success_handler: lexik_jwt_authentication.handler.authentication_success"
        print "            failure_handler: lexik_jwt_authentication.handler.authentication_failure"
        next         
    }
} 1' config/packages/security.yaml > temp_file && mv temp_file config/packages/security.yaml


awk '/access_control:/ {
    print
    getline
    if ($0 !~ /# Add by go-fast-jwt/) {
        print "        # Add by go-fast-jwt"
        print "        - { path: ^/api, roles: PUBLIC_ACCESS }"
        next
    }
} 1' config/packages/security.yaml > temp_file && mv temp_file config/packages/security.yaml


#Ajoute les configurations dans config/routes.yaml
awk '/type: attribute/ {
    print
    getline 
    if ($0 !~ /# Add by go-fast-jwt/) {
        print "# Add by go-fast-jwt"
        print "auth:"
        print "    path: /auth"
        print "    methods: ['/POST']"
        next
    }
} 1' config/routes.yaml > temp_file && mv temp_file config/routes.yaml


# j'efface tout le contenu après la ligne excepté celui contenu entre "api_platform" et "version" et le remplacer par "Un autre code commençant par Add by"
    #---explication
    # '^'api_platform: : Recherche la ligne qui commence par api_platform:
    # ',' : Séparateur pour délimiter la plage de lignes à considérer.
    # '^ version:'  : Recherche la ligne qui commence par quatre espaces et contient version:
sed -i '/^api_platform:/,/^    version:/!d' config/packages/api_platform.yaml

recherche la ligne "version et ajoute du code "
awk '/version:/ {
    print
    getline
    if ($0 !~ /# Add by go-fast-jwt/) {
        print "    # Add by go-fast-jwt\n\
    eager_loading:\n\
        fetch_partial: true\n\
        defaults:\n\
            pagination_client_enabled: true\n\
            pagination_client_items_enabled: true\n\
        swagger:\n\
            api_keys:\n\
                JWT:\n\
                    name: Authorization\n\
                    type: header"
     next
    }
} 1' config/packages/api_platform.yaml > temp_file && mv temp_file config/packages/api_platform.yaml


# Explication du code awk :

# /version:/ { : Si une ligne contient "version:", exécute le bloc suivant.
# print : Imprime la ligne courante.
# getline : Passe à la ligne suivante.
# if ($0 !~ /# Added by go-fast-jwt/) { : Si la ligne suivante ne contient pas "# Added by go-fast-jwt", exécute le bloc suivant.
# print " # Added by go-fast-jwt\n\ ..." : Imprime le texte spécifié.
# } : Fin du bloc conditionnel.
# } 1 : Imprime chaque ligne.
# config/packages/api_platform.yaml : Chemin du fichier à traiter.
# > temp_file : Redirige la sortie vers un fichier temporaire.
# && mv temp_file config/packages/api_platform.yaml : Renomme le fichier temporaire pour écraser le fichier d'origine.


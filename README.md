# Artifactory Module
[![Build Status](https://travis-ci.org/Adaptavist/puppet-artifactory.svg?branch=master)](https://travis-ci.org/Adaptavist/puppet-artifactory)

## Overview

The **Artifactory** installs and configures Jfrog Artifactory via the Adaptavists avst-app utility

Make sure you register an apt/yum repository where the avst-app packages are located, this can be done via the Adaptavist [packages_repo](https://github.com/Adaptavist/puppet-packages_repos) puppet module

## Configuration

The Avstapp module is entirely configured in [Hiera](#hiera). Examples of Hiera configuration will be given in [YAML](#yaml), Hiera's primary backend.

The following section will present how to configure each of the module aspects
presented in the section above.

### Application server configuration

Here is a complete YAML snippet for configuring a Crowd server which will be discussed in the following paragraphs:

    # Set users to be used for artifactory instalation
    artifactory::hosting_user: 'hosting'
    artifactory::hosting_group: 'hosting'
    
    # artifactory configuration 
    artifactory::instance_name: 'artifactory_test'
    artifactory::conf:
        tarball_location_url: 'https://download.example.com/artifactory/artifactory-powerpack-3.3.0.zip'
        db:
          DB_PORT:     '3306'
          DB_NAME:     'artifactory_db'
          DB_DRIVER:   'org.mysql.Driver'
          DB_URL:  'jdbc:mysql://localhost:3306/artifactory_db'
          DB_MAX_POOL_SIZE: '20'
          DB_USER: 'artifactory'
          DB_PASS: 'top_secret_password'
          DB_VALIDATION_QUERY:  'select 1'
          DB_DIALECT: ""    
        drivers:
          location_url:
            - "http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.22/mysql-connector-java-5.1.22.jar"
        java_flags:
          JVM_MINIMUM_MEMORY: '512m'
          JVM_MAXIMUM_MEMORY: '1024m' 
          JVM_MAX_PERM_SIZE: '256m' 
        custom:
            PROVIDER_FILESYSTEM_DIR: '/opt/artifactory/install/data'
            VERSION: '3.3.0'
            CONTEXT_PATH: ''
            PRODUCT: artifactory
            SHUTDOWN_PORT: '8012'
        license: "license goes here
        
        
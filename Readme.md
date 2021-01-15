[![Latest Stable Version](https://poser.pugx.org/bthpan/flowerflow/v)](//packagist.org/packages/bthpan/flowerflow)
[![Build Status](https://travis-ci.com/ejessyp/flowerflow.svg?branch=main)](https://travis-ci.com/ejessyp/flowerflow)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/ejessyp/flowerflow/badges/quality-score.png?b=main)](https://scrutinizer-ci.com/g/ejessyp/flowerflow/?branch=main)

[![Build Status](https://scrutinizer-ci.com/g/ejessyp/flowerflow/badges/build.png?b=main)](https://scrutinizer-ci.com/g/ejessyp/flowerflow/build-status/main)
[![Code Intelligence Status](https://scrutinizer-ci.com/g/ejessyp/flowerflow/badges/code-intelligence.svg?b=main)](https://scrutinizer-ci.com/code-intelligence)

### Flowerflow

### Requirements
1. php
2. webserver (apache)
3. composer
4. Database mysql


### Installation

### Step 1, install anax environment

Install anax environment.
Go to a php apache server root.
```
anax create proj ramverk1-me-v2
cd proj
```


### Step 2, install using composer

Install the module using composer.

```
composer require bthpan/flowerflow
```
### Step 3, rsync the files

Stand in the proj dir:
```
rsync -av  vendor/bthpan/flowerflow/.  ./
```

### Step 4, create databases and load initial data
Stand in the proj/sql/ddl dir:
Login database with root:
```
source ddl.sql;
```
Start using http://localhost/proj/htdocs/
Try login with user: admin/12345.

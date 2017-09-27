# glycodomainR package

Package for automatically installing and updating R data sets
from the GlycoDomainViewer data repository

Installation
```
devtools::install_github('hirenj/glycodomainR')
```

Obtain a CLIENT_ID and CLIENT_SECRET for access to datasets from the GlycoDomainViewer

Setup
```
R -e 'glycodomainR::initialize()'
R -e 'glycodomainR::install_packages()'
```

Paste in CLIENT_ID and CLIENT_SECRET when prompted

You can periodically update data using the following command

Updating data
```
R -e 'glycodomainR::update_packages()'
```

To set an alternative data repository, set the `gatordata.server` option
```
options(gatordata.server='https://alternative.server')
```

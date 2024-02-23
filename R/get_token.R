get_access_token_vault = function(endpoint) {
  vault <- vaultr::vault_client(login="token")
  wanted_token=vault$read(paste('oauth2/',endpoint,'/creds/fullaccess',sep='') )
  if ( class(wanted_token) == 'list' ) {
    return ( wanted_token[[1]] );
  }
}

get_access_token_direct = function(endpoint) {
    json_body = jsonlite::toJSON(list(
      client_id=keyring::key_get('gatordata.client_id',server_endpoint),
      client_secret=keyring::key_get('gatordata.client_secret',server_endpoint),
      audience=server_config$API_AUDIENCE,
      grant_type='client_credentials'
    ),auto_unbox = T)

    token_data = httr::POST(gatordata_endpoint$access,body=json_body, httr::add_headers("Content-Type" = "application/json"))
    return ( token_data )
}

get_session_id = function() {
  server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')

  server_config =  httr::content(httr::GET(paste(server_endpoint,'api/login/config',sep='/')))

  gatordata_endpoint <- httr::oauth_endpoint(
    authorize = NULL,
    access    = paste('https://',server_config$AUTH0_DOMAIN,'.auth0.com/oauth/token',sep='')
  )
  client_id = ''

  if (('vaultr' %in% rownames(installed.packages())) && (Sys.getenv('VAULT_TOKEN') != "") ) {
    token_data = get_access_token_vault(gsub('https://','',server_endpoint,fixed=T))
    client_id = Sys.getenv('GLYCODOMAINR_CLIENT_ID')
  } else {
    token_data = httr::content(get_access_token_direct(server_endpoint))$access_token
    client_id = keyring::key_get('gatordata.client_id',server_endpoint)
  }

  url <- httr::modify_url(
    url = server_endpoint,
    path = c("api", "login")
  )

  req <- httr::POST(url,
              httr::add_headers(
                "Authorization" = paste('Bearer',token_data),
                "x-api-key" = client_id
              ))

  session_id = httr::content(req)$session_id
  return (session_id)
}

#' @export
install_packages = function() {
  server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')

  session_id = get_session_id()
  utils::install.packages('gatordata',repos=httr::modify_url(url=server_endpoint, path=c('api','repository','token',session_id)))
}

#' @export
list_packages = function() {
  server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')

  session_id = get_session_id()
  utils::available.packages(httr::modify_url(url=server_endpoint, path=c('api','repository','token',session_id,'src','contrib')))
}
list_package_urls = function() {
  files = list_packages()[,c('File','Repository')]
  paste(files[,2],files[,1],sep='/')
}

#' @export
update_packages = function() {
  server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')

  session_id = get_session_id()
  utils::update.packages(repos=httr::modify_url(url=server_endpoint, path=c('api','repository','token',session_id)))
}

#' @export
auto_update = function() {
  initialize()
  update_packages()
}

#' @export
package_snapshot = function() {
  current_packages = installed.packages()
  package_version_data = current_packages[grepl('^gator',current_packages[,'Package']),c('Package','Version')]
  File=apply(package_version_data,1,function(x) paste(paste(sub('gator.','',x['Package']),x['Version'],sep='_'),'RData.tar.gz',sep='.'))
  `rownames<-`(cbind(package_version_data,File),NULL)
}

#' @export
download_package_snapshot = function(folder) {
  ifelse(!dir.exists(file.path(folder)), dir.create(file.path(folder)), FALSE)
  server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')
  token = get_session_id()
  packages_to_download = package_snapshot()[,'File']
  for (package in packages_to_download) {
    download.file( paste(server_endpoint,'api/repository/token',token,'src/contrib',package,sep='/'), file.path(folder,package) )
  }
}


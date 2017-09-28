library(httr)

get_session_id = function() {
  server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')

  server_config =  httr::content(httr::GET(paste(server_endpoint,'api/login/config',sep='/')))

  gatordata_endpoint <- httr::oauth_endpoint(
    authorize = NULL,
    access    = paste('https://',server_config$AUTH0_DOMAIN,'.auth0.com/oauth/token',sep='')
  )

  json_body = jsonlite::toJSON(list(
    client_id=keyring::key_get('gatordata.client_id',server_endpoint),
    client_secret=keyring::key_get('gatordata.client_secret',server_endpoint),
    audience=server_config$API_AUDIENCE,
    grant_type='client_credentials'
  ),auto_unbox = T)



  token_data = httr::POST(gatordata_endpoint$access,body=json_body, httr::add_headers("Content-Type" = "application/json"))

  url <- httr::modify_url(
    url = server_endpoint,
    path = c("api", "login")
  )

  req <- httr::POST(url,
              httr::add_headers(
                "Authorization" = paste('Bearer',httr::content(token_data)$access_token),
                "x-api-key" = keyring::key_get('gatordata.client_id')
              ))

  session_id = httr::content(req)$session_id
  return (session_id)
}
install_packages = function() {
  server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')

  session_id = get_session_id()
  utils::install.packages('gatordata',repos=httr::modify_url(url=server_endpoint, path=c('api','repository','token',session_id)))
}
list_packages = function() {
  server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')

  session_id = get_session_id()
  utils::available.packages(httr::modify_url(url=server_endpoint, path=c('api','repository','token',session_id,'src','contrib')))
}
list_package_urls = function() {
  files = list_packages()[,c('File','Repository')]
  paste(files[,2],files[,1],sep='/')
}
update_packages = function() {
  server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')

  session_id = get_session_id()
  utils::update.packages(repos=httr::modify_url(url=server_endpoint, path=c('api','repository','token',session_id)))
}

auto_update = function() {
  initialize()
  update_packages()
}

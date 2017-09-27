library(httr)


server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')

server_config =  httr::content(httr::GET(paste(server_endpoint,'api/login/config',sep='/')))

gatordata_endpoint <- httr::oauth_endpoint(
  authorize = NULL,
  access    = paste('https://',server_config$AUTH0_DOMAIN,'.auth0.com/oauth/token',sep='')
)

get_session_id = function() {
  json_body = jsonlite::toJSON(list(
    client_id=keyring::key_get('gatordata.client_id'),
    client_secret=keyring::key_get('gatordata.client_secret'),
    audience=server_config$API_AUDIENCE,
    grant_type='client_credentials'
  ),auto_unbox = T)



  token_data = httr::POST(gatordata_endpoint$access,body=json_body, httr::add_headers("Content-Type" = "application/json"))

  # 4. Use API
  url <- httr::modify_url(
    url = server_endpoint,
    path = c("api", "login")
  )

  req <- POST(url,
              httr::add_headers(
                "Authorization" = paste('Bearer',content(token_data)$access_token),
                "x-api-key" = keyring::key_get('gatordata.client_id')
              ))

  #stop_for_status(req)
  session_id = content(req)$session_id
  return (session_id)
}
install_packages = function() {
  session_id = get_session_id()
  install.packages('gatordata',repos=httr::modify_url(url=server_endpoint, path=c('api','repository','token',session_id)))
}
list_packages = function() {
  session_id = get_session_id()
  available.packages(httr::modify_url(url=server_endpoint, path=c('api','repository','token',session_id,'src','contrib')))
}
update_packages = function() {
  session_id = get_session_id()
  update.packages(repos=httr::modify_url(url=server_endpoint, path=c('api','repository','token',session_id)))
}

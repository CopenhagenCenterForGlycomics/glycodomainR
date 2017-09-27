#init

server_endpoint = ifelse('gatordata.server' %in% names(options()), getOption('gatordata.server'), 'https://glycodomain.glycomics.ku.dk')

initialize = function() {
  stored_client_ids = keyring::key_list('gatordata.client_id')$username
  stored_client_secrets = keyring::key_list('gatordata.client_secret')$username
  if (! server_endpoint %in% stored_client_ids) {
    message("There is no Client ID set for ",server_endpoint," please add one now")
    keyring::key_set('gatordata.client_id',server_endpoint)
  }
  if (! server_endpoint %in% stored_client_secrets) {
    message("There is no Client secret set for ",server_endpoint," please add one now")
    keyring::key_set('gatordata.client_secret',server_endpoint)
  }
}

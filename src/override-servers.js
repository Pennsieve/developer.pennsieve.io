import { AuthItemOverride } from './AuthItemOverride'

const AUTH_SERVICE_NAME = 'Authorization Service'

/**
 * Override the default server and host configuration for a Swagger or OpenAPI
 * spec. This allows us to change the documented server URLs based on how the
 * gateway rewrites requests.
 *
 * Adapted from [1]. See [2] for full documentation of the plugin API. [3] has
 * some concrete examples of the plugin API.
 *
 * [1] https://github.com/shockey/swagger-ui-plugins/blob/master/packages/disable-try-it-out-without-servers/src/index.js
 * [2] https://swagger.io/docs/open-source-tools/swagger-ui/customization/plugin-api/
 * [3] https://github.com/swagger-api/swagger-ui/issues/5027#issuecomment-438745785
 */
export function OverrideServers(urls) {
  const authServer = urls.find(u => u.name === AUTH_SERVICE_NAME).server
  return function(system) {
    return {
      statePlugins: {
        spec: {
          wrapActions: {
            updateJsonSpec: (oriAction, system) => (json) => {
              const specUrl = system.specSelectors.url()
              const serverOverride = urls.find(url => url.url === specUrl).server

              if (serverOverride) {

                if (isOAS3(json)) { // OpenAPI 3.0
                  json.servers = [{url: serverOverride}]

                } else {  // Swagger 2.0
                  const parsed = parseURL(serverOverride)
                  json.schemes = [parsed.scheme]
                  json.host = parsed.host + parsed.path
                }
              }
              return oriAction(json)
            }
          }
        },
      },
      wrapComponents: {
        AuthItem: ((OriginalComponent, { React }) => (props) => {
          return React.createElement("div", null,
            React.createElement(AuthItemOverride, {
              ...props,
              authServer,
              authorize: system.authActions.authorize,
              authorized: system.authSelectors.authorized,
            }),
            React.createElement(OriginalComponent, props),
          )
        })
      }
    }
  }
}

/**
  * Copied from [1] since the spec is not loaded yet so the
  * `system.specSelectors.isOAS3()` will not yet work.
  *
  * [1] https://github.com/swagger-api/swagger-ui/blob/ad786b023f8e54fcdb4a883039425148d8a8a327/src/core/plugins/oas3/helpers.jsx
  */
function isOAS3(spec) {
  const oasVersion = spec.openapi
  if (typeof oasVersion !== "string") {
    return false
  }
  return oasVersion.startsWith("3.0.") && oasVersion.length > 4
}

function parseURL(url) {
  const parser = document.createElement('a')
  parser.href = url

  let path = parser.pathname
  if (path[0] !== '/') {
    path = '/' + path // Fix IE11
  }

  return {
    scheme: parser.protocol.replace(/:/g, ""),
    host: parser.host,
    path: path,
  }
};

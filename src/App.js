import React, { useEffect } from 'react';
import SwaggerUI from 'swagger-ui'
import StandalonePreset from 'swagger-ui/dist/swagger-ui-standalone-preset'
import 'swagger-ui/dist/swagger-ui.css'
import { OverrideServers } from './override-servers'
import urls from './urls.json'

/**
 * top level react component
 * NOTE: we can use React 16+ features here because we are in this project's
 * React App, not swagger-ui's
 */
function App() {
  // equivalent of `componentDidMount`, mounts the swagger ui on our div
  useEffect(
    () => {
      // Build a system
      const ui = SwaggerUI({
        urls: urls,
        dom_id: '#swagger-ui',
        deepLinking: true,
        presets: [
          SwaggerUI.presets.apis,
          StandalonePreset
        ],
        plugins: [
          SwaggerUI.plugins.DownloadUrl,
          OverrideServers(urls)
        ],
        layout: "StandaloneLayout"
      })

      window.ui = ui
    },
    []
  )
  return (
    <div id="swagger-ui"/>
  );
}

export default App;

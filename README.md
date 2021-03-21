# Pennsieve Developer Documentation

## Create React App

See below regarding how the project was bootstrapped.  We deploy a basic React App because `swagger-ui` itself is
implemented in React.  This provides the path of least resistance for customization.

## [Makefile](./Makefile)

The project is currently deployed via a simple Makefile.

### Install
the `install` script just runs `yarn install` to bootstrap the javascript runtime.

### Test
the `test-*` scripts simply copy the proper `urls.<environemnt>.json` file to `urls.json`, and then start the React App
in development mode via the `start` yarn script.

### Deploy
The `deploy-*` scripts copy the proper
`urls.<environemnt>.json` file to `urls.json`, which is read by the App.  

Then, they run the `build` yarn script, and
copy the resulting `build` directory, along with the static `landing-page` directory, into the proper S3 bucket.

Because of the way the app is deployed, relative links e.g. `<script src="/static/js..."` need to be updated to include
the current directory: `<script src="./static/js..."`. A sed script modifies `build/index.html` accordingly.

Finally, the corresponding cloudfront distribution is invalidated so that the new files are retrieved on subsequent requests.

## Default Directory Indexes Lambda Edge

Implement default directory indexes in Amazon S3-backed Amazon CloudFront Origins using Lambda@Edge. This solution is based on AWS' [recommended fix](https://aws.amazon.com/blogs/compute/implementing-default-directory-indexes-in-amazon-s3-backed-amazon-cloudfront-origins-using-lambdaedge/).


# Below is the contents of the README that comes with any project initialized via CRA

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

## Available Scripts

In the project directory, you can run:

### `yarn start`

Runs the app in the development mode.<br />
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.<br />
You will also see any lint errors in the console.

### `yarn test`

Launches the test runner in the interactive watch mode.<br />
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `yarn build`

Builds the app for production to the `build` folder.<br />
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.<br />
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `yarn eject`

**Note: this is a one-way operation. Once you `eject`, you can’t go back!**

If you aren’t satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you’re on your own.

You don’t have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn’t feel obligated to use this feature. However we understand that this tool wouldn’t be useful if you couldn’t customize it when you are ready for it.

## Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).

### Code Splitting

This section has moved here: https://facebook.github.io/create-react-app/docs/code-splitting

### Analyzing the Bundle Size

This section has moved here: https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size

### Making a Progressive Web App

This section has moved here: https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app

### Advanced Configuration

This section has moved here: https://facebook.github.io/create-react-app/docs/advanced-configuration

### Deployment

This section has moved here: https://facebook.github.io/create-react-app/docs/deployment

### `yarn build` fails to minify

This section has moved here: https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify

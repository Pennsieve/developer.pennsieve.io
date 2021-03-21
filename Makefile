WORKING_DIR   ?= "$(shell pwd)"
SERVICE_NAME  ?= "directory-index-lambda-edge"
LAMBDA_BUCKET ?= "pennsieve-cc-lambda-functions-use1"
PACKAGE_BASE  ?= "${SERVICE_NAME}"
PACKAGE_NAME  ?= "${PACKAGE_BASE}-${VERSION}.zip"

.DEFAULT: help
help:
	@echo "Make Help"
	@echo ""
	@echo "     make install       - bootstrap javascript project"
	@echo "     make test-dev      - start app in dev mode with dev urls"
	@echo "     make test-prod     - start app in dev mode with prd urls"
	@echo "     make deploy-dev    - deploys to dev and busts cache"
	@echo "     make deploy-prod   - deploys to prd and busts cache"
	@echo "     make package       - package lambda edge function"
	@echo "     make publish       - package and publish lambda edge function"
	@echo "     make lambda-test   - test lambda edge function"

install:
	yarn

test-dev:
	cp src/urls.dev.json src/urls.json
	yarn start

test-prd:
	cp src/urls.prd.json src/urls.json
	yarn start

deploy-dev:
	cp src/urls.dev.json src/urls.json
	yarn build
	# replace href="/static/css with href="./static/css
	sed -i .tmp -e 's,href="/,href="./,g' -e 's,src="/,src="./,g' build/index.html
	aws s3 sync build/ s3://pennsieve-dev-developer-use1/api
	aws s3 cp landing-page/dev.html s3://pennsieve-dev-developer-use1/index.html
	aws s3 sync landing-page/assets/ s3://pennsieve-dev-developer-use1/assets/
	aws cloudfront create-invalidation --distribution-id E3PIWQVF8PNEMB --paths "/*"

deploy-prod:
	cp src/urls.prod.json src/urls.json
	yarn build
	# replace href="/static/css with href="./static/css
	sed -i .tmp -e 's,href="/,href="./,g' -e 's,src="/,src="./,g' build/index.html
	aws s3 sync build/ s3://pennsieve-prod-developer-use1/api
	aws s3 cp landing-page/prod.html s3://pennsieve-prod-developer-use1/index.html
	aws s3 sync landing-page/assets/ s3://pennsieve-prod-developer-use1/assets/
	aws cloudfront create-invalidation --distribution-id EUL3CTLC78QXT --paths "/*"

lambda-test:
	@echo ""
	@echo ""
	@echo "***********************************"
	@echo ""
	@echo "Testing lamda edge function"
	@echo ""
	@echo "***********************************"
	@echo ""
	@echo ""
	@cd directory-index-lambda-edge; \
            npm install; \
            yarn test

package:
	@make lambda-test
	@echo ""
	@echo ""
	@echo "***********************************"
	@echo ""
	@echo "Building $(PACKAGE_NAME)"
	@echo ""
	@echo "***********************************"
	@echo ""
	@echo ""
	cd $(WORKING_DIR)/directory-index-lambda-edge; \
        zip -r $(WORKING_DIR)/$(PACKAGE_NAME) .

publish:
	@make package
	@echo ""
	@echo ""
	@echo "Publishing lambda to S3..."
	aws s3 cp ${WORKING_DIR}/${PACKAGE_NAME} s3://${LAMBDA_BUCKET}/${PACKAGE_BASE}/
	@rm -rf ${WORKING_DIR}/${PACKAGE_NAME}

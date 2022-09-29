# This Dockerfile utilizes multi-stage builds and the builder pattern. The first image defined
# the builder which is used to install gems and compile assets. The second image defined is
# the actual application runtime image. It copies the necessary pieces for runtime out of
# the builder image.

# This version should match the version in .circleci/config.yml and templates/.circleci/config.yml.tt
ARG ruby_base_version=17.0.0
ARG ruby_version=3.1.1

#
# BUILDER IMAGE
#
FROM appfolio/ruby_base:builder_${ruby_base_version}_ruby-${ruby_version} as builder
WORKDIR /home/code

RUN yum install -y libcurl-devel
COPY vendor/cache ./vendor/cache
COPY Gemfile Gemfile.lock ./

RUN bundle config set --local deployment 'true' \
 && bundle install --jobs 4 \
 && find ./vendor -type f -name *.gem | xargs rm -rf

COPY package.json package-lock.json .npmrc .browserslistrc ./
COPY babel.config.js postcss.config.js ./
COPY config.ru Rakefile secrets_manifest.yml ./
COPY public ./public
COPY bin ./bin
COPY lib ./lib
COPY db ./db
COPY config ./config
COPY app ./app

RUN --mount=type=secret,id=github_npm_token GITHUB_NPM_TOKEN=$(cat /run/secrets/github_npm_token) npm install
RUN --mount=type=secret,id=github_npm_token GITHUB_NPM_TOKEN=$(cat /run/secrets/github_npm_token) bundle exec rake assets:precompile RAILS_ENV=test USE_PRECOMPILED_ASSETS=1 && \
  rm -rf ./node_modules/* ./tmp/*

#
# RUNTIME IMAGE
#
# This is what is published to dockerhub / deployed by adep app.
FROM appfolio/ruby_base:${ruby_base_version}_ruby-${ruby_version} as deployment
WORKDIR /home/code
ENV EXECJS_RUNTIME='Disabled'
COPY --from=builder /home/code /home/code

#
# Author:: Matthew FL <matthew@balancedpayments.com>
#
# Copyright 2013-2014, Balanced, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

balanced_ci_pipeline 'precog' do
  repository 'git@github.com:balanced/precog.git'
  # this should really be called the "acceptance cookbook"
  cookbook_repository 'git@github.com:balanced-cookbooks/acceptance.git'
  pipeline %w{test quality build acceptance}
  project_url 'https://github.com/balanced/precog'
  python_package 'precog_service'
  test_db_user 'precog'
  test_db_name 'precog_test'
  test_db_host 'localhost'
  branch 'omnibussed'

  test_command 'pip install --no-use-wheel -e .[tests] && nosetests -sv --with-xunitmp --with-cov --cov=precog_service --cov-report term-missing'
  quality_command 'coverage.py coverage.xml precog_service.models:92 precog_service.resources:92'

  job 'build' do |new_resource|
    promotion true
  end

  job 'test' do |new_resource|
    conditional_continue job_name: "#{new_resource.name}-build"

    builder_recipe do
      include_recipe 'git'
      include_recipe 'python'
      include_recipe 'rsyslog'
      include_recipe 'balanced-rabbitmq'
      include_recipe 'balanced-elasticsearch'
      include_recipe 'balanced-postgresql'
      include_recipe 'balanced-postgresql::server'
      include_recipe 'balanced-postgresql::client'
      include_recipe 'balanced-mongodb'
      include_recipe 'redisio::install'
      include_recipe 'redisio::enable'

      %w(libatlas-dev libatlas-base-dev liblapack-dev gfortran libxml2-dev libxslt1-dev libatlas3gf-base).each do |name|
        package name
      end

      include_recipe 'postgresql::client'
      include_recipe 'postgresql::ruby'

      pg_user new_resource.test_db_user do
        privileges superuser: true, createdb: true, login: true
        password ''
      end

      pg_database new_resource.test_db_name do
        owner new_resource.test_db_user
      end

      pg_database_extensions new_resource.test_db_name do
        extensions ['hstore']
      end

      directory node['ci']['path'] do
        owner node['jenkins']['node']['user']
        group node['jenkins']['node']['group']
      end

      directory "#{node['ci']['path']}/.pip" do
        owner node['jenkins']['node']['user']
        group node['jenkins']['node']['group']
        mode '700'
      end

      file "#{node['ci']['path']}/.pip/pip.conf" do
        owner node['jenkins']['node']['user']
        group node['jenkins']['node']['group']
        mode '600'
        content "[global]\nindex-url = https://omnibus:#{citadel['omnibus/devpi_password'].strip}@pypi.vandelay.io/balanced/prod/+simple/\n"
      end

      file "#{node['ci']['path']}/.pydistutils.cfg" do
        owner node['jenkins']['node']['user']
        group node['jenkins']['node']['group']
        mode '600'
        content "[easy_install]\nindex_url = https://omnibus:#{citadel['omnibus/devpi_password'].strip}@pypi.vandelay.io/balanced/prod/+simple/\n"
      end

    end

  end

end

include_recipe 'balanced-ci'

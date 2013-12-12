#
# Author:: Noah Kantrowitz <noah@coderanger.net>
#
# Copyright 2013, Balanced, Inc.
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

# We don't want to run builders on the server machine
node.override['ci']['is_builder'] = false

ci_server 'balanced-ci' do
  path '/var/lib/jenkins'
  component 'git'
  component 'google_auth' do
    domain 'balancedpayments.com'
  end
  component 'secure_slaves' do
    master_key citadel['jenkins_server/master.key']
    secrets_key citadel['jenkins_server/hudson.util.Secret']
    encrypted_api_token citadel['jenkins_server/apiToken']
  end
end

jenkins_plugin 'github'

include_recipe 'balanced-ci'
include_recipe 'balanced-ci::balanced'
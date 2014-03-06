#
# Author:: Noah Kantrowitz <noah@coderanger.net>
#
# Copyright 2014, Balanced, Inc.
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

chef_gem 'octokit'
require 'octokit'
github = Octokit::Client.new(access_token: citadel['github/token'])
github.org_repos('balanced-cookbooks').each do |repo|
  files = github.contents("balanced-cookbooks/#{repo.name}").map {|f| f.path}
  next unless files.include?('.kitchen.yml') # No tests, not interested

  balanced_ci_pipeline repo.name do
    cookbook_repository "git@github.com:balanced-cookbooks/#{repo.name}.git"
    pipeline %w{acceptance}
    job 'acceptance' do |new_resource|
      job_name "cookbook-#{repo.name}"
      scm_trigger Chef::Config[:solo] ? '' : '* * * * *'
      builder_label 'cookbooks'
      parameterized false
    end
  end

end

include_recipe 'balanced-ci'
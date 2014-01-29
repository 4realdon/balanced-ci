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

balanced_ci_pipeline 'balanced-docs' do
  repository 'git@github.com:balanced/balanced-docs.git'
  cookbook_repository 'git@github.com:balanced-cookbooks/balanced-docs.git'
  pipeline %w{test quality build acceptance}
  project_url 'https://github.com/balanced/balanced-docs'
  branch 'master'
  test_command 'true'
  quality_command 'true'
end

include_recipe 'balanced-ci'
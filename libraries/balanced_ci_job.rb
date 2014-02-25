#
# Author:: Marshall Jones <marshall@balancedpayments.com>
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

class Chef

  class Resource::BalancedCiJob < Resource::CiJob
    attribute(:downstream_triggers, kind_of: Array, default: [])
    attribute(:downstream_joins, kind_of: Array, default: [])

    attribute(:project_url, kind_of: String, default: nil)
    attribute(:branch, kind_of: String, default: nil)
    attribute(:cobertura, kind_of: String, default: nil)
    attribute(:mailer, kind_of: String, default: nil)
    attribute(:junit, kind_of: [String, FalseClass])
    attribute(:violations, equal_to: [true, false])
    attribute(:clone_workspace, equal_to: [true, false])
    attribute(:inherit, kind_of: String, default: nil)
    attribute(:parameterized, equal_to: [true, false], default: false)
    attribute(:conditional_continue, kind_of: Hash, default: {})
    attribute(:environment_script, kind_of: String)
    attribute(:scm_trigger, kind_of: String)
    attribute(:promoted, equal_to: [true, false], default: false)
    attribute(:promotion_source, template: true, default_source: 'promote.xml.erb')

    def default_options
      super.merge(
        project_url: project_url,
        repository: repository,
        branch: branch,
        cobertura: cobertura,
        mailer: mailer,
        junit: junit,
        violations: violations,
        clone_workspace: clone_workspace,
        downstream_triggers: downstream_triggers,
        downstream_joins: downstream_joins,
        inherit: inherit,
        conditional_continue: conditional_continue,
        environment_script: environment_script,
        parameterized: parameterized,
        scm_trigger: scm_trigger,
        promoted: promoted,
        job_name: job_name,
      )
    end

  end

  class Provider::BalancedCiJob < Provider::CiJob; 

    def action_enable
      super
      if new_resource.parent
        converge_by("create jenkins promotion for job #{new_resource.job_name}") do
          notifying_block do
            create_promotion
          end
        end
      end
    end

    private

    def create_promotion
      create_promotion_directory
      write_promotion_config
    end

    def promotion_directory_path
      # this will be something looks like 
      # /var/lib/jenkins/jobs/billy-acceptance/promotions/billy-acceptance-promotion/
      ::File.join(
        new_resource.parent.jobs_path, 
        new_resource.job_name, 
        'promotions', 
        "#{ new_resource.job_name }-promotion",
      )
    end 

    def promtion_config_path
      ::File.join(promotion_directory_path, 'config.xml')
    end

    def create_promotion_directory
      directory promotion_directory_path do
        owner new_resource.parent.user
        group new_resource.parent.group
        mode new_resource.parent.dir_permissions
        recursive true
      end
    end

    def write_promotion_config
      file promtion_config_path do
        content new_resource.promotion_source_content
        owner new_resource.parent.user
        group new_resource.parent.group
        mode '600'
      end
    end

  end

end


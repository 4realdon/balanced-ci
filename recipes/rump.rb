
class Chef

  class Resource::RumpCiPipeline < Resource::BalancedCiPipeline

  end

  class Provider::RumpCiPipeline < Provider::BalancedCiPipeline

    def action_enable
      converge_by("create CI pipeline for #{new_resource.name}") do
        notifying_block do
          create_test_job
          create_build_quality_job
        end
      end
    end

  end

end


rump_ci_pipeline 'rump' do
  repository 'git@github.com:balanced/rump.git'
  package_name 'rump'
  project_url 'https://github.com/balanced/rump'
  branch 'ohaul'
  project_prefix 'src/'
  cobertura ({
  })
  mailer ({
      :address => "ci@balancedpayments.com"
  })
  test_command <<-COMMAND
cd src
pip install nose==1.3.0
pip install mock==0.8
pip install unittest2
nosetests -v -s --with-id --with-xunit --with-xcoverage --cover-package=rump --cover-erase
COMMAND
end

include_recipe 'balanced-ci'

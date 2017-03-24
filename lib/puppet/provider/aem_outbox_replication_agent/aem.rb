=begin
Copyright 2016 Shine Solutions
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

require_relative '../../../puppet_x/shinesolutions/puppet_aem_resources.rb'

Puppet::Type.type(:aem_outbox_replication_agent).provide(:aem, :parent => PuppetX::ShineSolutions::PuppetAemResources) do

  # Create a outbox replication agent.
  def create
    outbox_replication_agent = client().outbox_replication_agent(resource[:run_mode], resource[:name])
    opts = { user_id: resource[:user_id], log_level: resource[:log_level] }
    result = outbox_replication_agent.create_update(resource[:title], resource[:description], resource[:dest_base_url], opts)
    handle(result)
  end

  # Delete the outbox replication agent.
  def destroy
    outbox_replication_agent = client().outbox_replication_agent(resource[:run_mode], resource[:name])
    result = outbox_replication_agent.delete()
    handle(result)
  end

  # Check whether the outbox replication agent exists or not.
  # When force is set to true, outbox replication agent will be created if it doesn't exist or updated if it already exists.
  def exists?
    if resource[:force] == true
      return false
    else
      outbox_replication_agent = client().outbox_replication_agent(resource[:run_mode], resource[:name])
      outbox_replication_agent.exists().data
    end
  end

end
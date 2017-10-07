[![Build Status](https://img.shields.io/travis/shinesolutions/puppet-aem-resources.svg)](http://travis-ci.org/shinesolutions/puppet-aem-resources)
[![Published Version](https://img.shields.io/puppetforge/v/shinesolutions/aem_resources.svg)](http://forge.puppet.com/shinesolutions/aem_resources)
[![Downloads Count](https://img.shields.io/puppetforge/dt/shinesolutions/aem_resources.svg)](http://forge.puppet.com/shinesolutions/aem_resources)

Puppet AEM Resources
--------------------

A Puppet module for provisioning [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) resources.

Install
-------

    puppet module install shinesolutions-aem_resources

Or via a Puppetfile:

    mod 'shinesolutions/aem_resources'

If you want to use the master version:

    mod 'shinesolutions/aem_resources', :git => 'https://github.com/shinesolutions/puppet-aem-resources'

And because [PUP-3386](https://tickets.puppetlabs.com/browse/PUP-3386) hasn't been implemented, you have to install [ruby_aem](https://github.com/shinesolutions/ruby_aem) prior to using aem_resource Puppet module. [nokogiri](http://www.nokogiri.org/) needs to be installed explicitly to version 1.6.8.1 only if you are using ruby 2.0 (ruby 1.9 is no longer supported).

    package { 'nokogiri':
      ensure   => '1.6.8.1',
      provider => 'puppet_gem',
    } ->
    package { 'ruby_aem':
      ensure   => '1.4.0',
      provider => 'puppet_gem',
    }

Configuration
-------------

AEM username, password, protocol, host, port, and debug can be set via environment variables or a configuration file.

Environment variables have `aem_` prefix, e.g. `aem_username`, `aem_password`, `aem_protocol`, `aem_host`, `aem_port`, and `aem_debug`.

Configuration file should be named `aem.yaml` and be placed under [Puppet config directory](https://docs.puppet.com/puppet/latest/dirs_confdir.html). Example config file:

    ---
    :username: 'admin'
    :password: 'admin'
    :protocol: 'http'
    :host: 'localhost'
    :port: 4502
    :debug: False

If a configuration property is not set, then it will use the default value set in [ruby_aem](https://github.com/shinesolutions/ruby_aem).

However, if the invocation specifies an `aem_id` attribute, then the value of that attribute will be used to identify the environment variables and configuration file. For example:

    aem_bundle {
      ...
      aem_id => 'myaem',
      ...
    }

The invocation above will use environment variables with `myaem_` prefix, e.g. `myaem_username`, and it will use a configuration file named `myaem.yaml` under Puppet config directory.

Usage
-----

AEM

    aem_aem { 'Wait until login page is ready':
      ensure                     => login_page_is_ready,
      retries_max_tries          => 60,
      retries_base_sleep_seconds => 5,
      retries_max_sleep_seconds  => 5,
    }

    # this requires aem-healthcheck package to be installed
    # https://github.com/shinesolutions/aem-healthcheck
    aem_aem { 'Wait until health is ok':
      ensure                     => aem_health_check_is_ok,
      tags                       => 'deep',
      combine_tags_or            => false,
      retries_max_tries          => 60,
      retries_base_sleep_seconds => 5,
      retries_max_sleep_seconds  => 5,
    }

    aem_aem { 'Wait until install status is finished':
      ensure                     => install_status_is_finished,
      retries_max_tries          => 60,
      retries_base_sleep_seconds => 5,
      retries_max_sleep_seconds  => 5,
    }

    aem_aem { 'Remove all agents':
      ensure   => all_agents_removed,
      run_mode => 'author',
    }

Bundle

    aem_bundle { 'Stop webdav bundle':
      ensure => stopped,
      name   => 'org.apache.sling.jcr.webdav',
    }

    aem_bundle { 'Start webdav bundle':
      ensure => started,
      name   => 'org.apache.sling.jcr.webdav',
    }

Config property

    aem_config_property { 'Create https.enable property':
      ensure    => present,
      name      => 'org.apache.felix.https.enable',
      type      => 'Boolean',
      value     => true,
      run_mode  => 'author',
      node_name => 'org.apache.felix.http',
    }

Flush agent

    aem_flush_agent { 'Create flush agent':
      ensure        => present,
      name          => 'some-flush-agent',
      run_mode      => 'author',
      title         => 'Some Flush Agent Title',
      description   => 'Some flush agent description',
      dest_base_url => 'http://somehost:8080',
      log_level     => 'info',
      retry_delay   => 60000,
      force         => true,
    }

    aem_flush_agent { 'Delete flush agent':
      ensure   => absent,
      name     => 'some-flush-agent',
      run_mode => 'author',
    }

Group

    aem_group { 'Create staff group':
      ensure => present,
      name   => 'staff',
      path   => '/home/groups/s',
    }

    aem_group { 'Create contractor group':
      ensure => present,
      name   => 'contractor',
      path   => '/home/groups/c',
    }

    aem_group { 'Create contractor group as a member of staff group':
      ensure            => present,
      name              => 'contractor',
      path              => '/home/groups/c',
      parent_group_name => 'staff',
      parent_group_path => '/home/groups/s',
    }

    aem_group { 'Create staff group and add contractor group as a member':
      ensure            => present,
      name              => 'staff',
      path              => '/home/groups/s',
      member_group_name => 'contractor',
      member_group_path => '/home/groups/c',
    }

    aem_group { 'Delete staff group':
      ensure => absent,
      name   => 'staff',
      path   => '/home/groups/s',
    }

Node

    aem_node { 'Create http OSGI config node':
      ensure => present,
      name   => 'org.apache.felix.http',
      path   => '/apps/system/config.author',
      type   => 'sling:OsgiConfig',
    }

    aem_node { 'Delete http OSGI config node':
      ensure => absent,
      name   => 'org.apache.felix.http',
      path   => '/apps/system/config.author',
    }

Package

    aem_package { 'Install AEM6.2 hotfix 12785':
      ensure    => present,
      name      => 'cq-6.2.0-hotfix-12785',
      group     => 'adobe/cq620/hotfix',
      version   => '7.0',
      path      => '/tmp/',
      replicate => false,
      activate  => true,
      force     => true,
    }

    aem_package { 'Archive Geometrixx apps':
      ensure  => archived,
      name    => 'somearchivedpackage',
      group   => 'somepackagegroup',
      version => '1.2.3',
      path    => '/tmp/',
      filter  => '[{"root":"/apps/geometrixx","rules":[]},{"root":"/apps/geometrixx-common","rules":[]}]',
    }

Path

    aem_path { 'Activate /etc/designs/cloudservices/':
      ensure => is_activated,
      name   => '/etc/designs/cloudservices/',
    }

Replication agent

    aem_replication_agent { 'Create replication agent':
      ensure             => present,
      name               => 'some-replication-agent',
      run_mode           => 'author',
      title              => 'Some Replication Agent Title',
      description        => 'Some replication agent description',
      dest_base_url      => 'http://somehost:8080',
      transport_user     => 'someuser',
      transport_password => 'somepass',
      log_level          => 'info',
      retry_delay        => 60000,
      force              => true,
    }

    aem_replication_agent { 'Delete replication agent':
      ensure   => absent,
      name     => 'some-replication-agent',
      run_mode => 'author',
    }

Outbox replication agent

    aem_outbox_replication_agent { 'Create outbox replication agent':
      ensure      => present,
      name        => 'some-outbox-replication-agent',
      run_mode    => 'publish',
      title       => 'Some Outbox Replication Agent Title',
      description => 'Some outbox replication agent description',
      user_id     => 'admin',
      log_level   => 'info',
      force       => true,
    }

    aem_outbox_replication_agent { 'Delete outbox replication agent':
      ensure   => absent,
      name     => 'some-outbox-replication-agent',
      run_mode => 'publish',
    }

Repository

    aem_repository { 'Block repository writes':
      ensure => writes_blocked,
    }

    aem_repository { 'Unblock repository writes':
      ensure => writes_unblocked,
    }

User

    aem_user { 'Create user charlie without any group':
      ensure     => present,
      name       => 'charlie',
      path       => '/home/users/c',
      password   => 'somepassword',
      permission => {
        '/libs' => ['read:false', 'modify:false', 'create:false', 'delete:false', 'acl_read:false', 'acl_edit:false', 'replicate:false'],
        '/var'  => ['read:false', 'modify:false', 'create:false', 'delete:false', 'acl_read:false', 'acl_edit:false', 'replicate:false'],
        '/tmp'  => ['read:false', 'modify:false', 'create:false', 'delete:false', 'acl_read:false', 'acl_edit:false', 'replicate:false'],
      },
    }

    aem_user { 'Create user bob and add to administrators group':
      ensure     => present,
      name       => 'bob',
      path       => '/home/users/b',
      password   => 'somepassword',
      group_name => 'administrators',
      group_path => '/home/groups/a',
    }

    aem_user { 'Add user charlie to administrators group':
      ensure     => added_to_group,
      name       => 'charlie',
      path       => '/home/users/c',
      group_name => 'administrators',
      group_path => '/home/groups/a'
    }

    aem_user { 'Change user bob password':
      ensure       => password_changed,
      name         => 'bob',
      path         => '/home/users/b',
      old_password => 'somepassword',
      new_password => 'somenewpassword'
    }

    aem_user { 'Delete user':
      ensure => absent,
      name   => 'bob',
      path   => '/home/users/b',
    }

    aem_user { 'Update replication-service user permission':
      ensure     => has_permission,
      name       => 'replication-service',
      path       => '/home/users/system/',
      permission => {
        '/etc/replication/agents.author' => ['replicate:false'],
        '/etc/replication/agents.publish' => ['replicate:false']
      }
    }

Other than single AEM resource, this module also provides predefined classes for common AEM provisioning tasks.

Remove default agents on AEM Author:

    include aem_resources::author_remove_default_agents

Remove default agents on AEM Publish:

    include aem_resources::publish_remove_default_agents

Set AEM Author Standby configuration:

    class { 'aem_resources::author_standby_set_config':
      install_dir  => '/opt/aem/crx-quickstart/install',
      primary_host => 'somehost',
    }

Create system users (orchestrator, replicator, deployer, exporter, importer):

    include aem_resources::create_system_users

Create Puppet AEM Resources' configuration file:

    class { 'aem_resources::puppet_aem_resources_set_config':
      conf_dir => '/tmp/puppet-aem-resources/',
      username => 'admin',
      password => 'admin',
      protocol => 'http',
      host     => 'localhost',
      port     => 4502,
      debug    => false,
    }

Enable CRXDE:

    class { 'aem_resources::enable_crxde':
      run_mode => 'author',
    }

Multi AEM instances
-------------------

Starting from version 1.3.0, it is possible to use Puppet AEM Resources to provision multiple AEM instances on the same machine.

Let's say you have an AEM author instance at http://localhost:4502 and an AEM publish instance at https://localhost:5433 . Set up the following configuration files:

`<puppet-config-dir>/myaemauthor.yaml`

    ---
    :username: 'admin'
    :password: 'admin'
    :protocol: 'http'
    :host: 'localhost'
    :port: 4502
    :debug: False

`<puppet-config-dir>/myaempublish.yaml`

    ---
    :username: 'admin'
    :password: 'admin'
    :protocol: 'https'
    :host: 'localhost'
    :port: 5433
    :debug: False

Then specify `aem_id` attribute on resource invocation in Puppet manifest:

    aem_bundle { 'Stop webdav bundle':
      ensure => stopped,
      name   => 'org.apache.sling.jcr.webdav',
      aem_id => 'myaemauthor',
    }

    aem_bundle { 'Stop webdav bundle':
      ensure => stopped,
      name   => 'org.apache.sling.jcr.webdav',
      aem_id => 'myaempublish',
    }

The above example will stop webdav bundle on both your AEM author instance and AEM publish instance.

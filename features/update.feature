Feature: update
  ModuleSync needs to update module boilerplate

  Scenario: Adding a new file
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Files added:
      test
      """
    Given I run `cat modules/maestrodev/puppet-test/test`
    Then the output should contain "aruba"

  Scenario: Using skip_broken option and adding a new file to repo without write access
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: 'git@github.com:'
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update -s -m "Add test"`
    Then the exit status should be 0

  Scenario: Adding a new file to repo without write access
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: 'git@github.com:'
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update -m "Add test" -r`
    Then the exit status should be 1

  Scenario: Adding a new file, without the .erb suffix
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Warning: using './moduleroot/test' as template without '.erb' suffix
      """
    And the output should match:
      """
      Files added:
      test
      """
    Given I run `cat modules/maestrodev/puppet-test/test`
    Then the output should contain "aruba"

  Scenario: Adding a new file using global values
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      :global:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Files added:
      test
      """
    Given I run `cat modules/maestrodev/puppet-test/test`
    Then the output should contain "aruba"

  Scenario: Adding a new file overriding global values
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      :global:
        name: global

      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Files added:
      test
      """
    Given I run `cat modules/maestrodev/puppet-test/test`
    Then the output should contain "aruba"

  Scenario: Adding a new file ignoring global values
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      :global:
        key: global

      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Files added:
      test
      """
    Given I run `cat modules/maestrodev/puppet-test/test`
    Then the output should contain "aruba"

  Scenario: Adding a file that ERB can't parse
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <% @configs.each do |c| -%>
        <%= c['name'] %>
      <% end %>
      """
    When I run `msync update --noop`
    Then the exit status should be 1

  Scenario: Using skip_broken option with invalid files
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <% @configs.each do |c| -%>
        <%= c['name'] %>
      <% end %>
      """
    When I run `msync update --noop -s`
    Then the exit status should be 0

  Scenario: Using skip_broken and fail_on_warnings options with invalid files
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <% @configs.each do |c| -%>
        <%= c['name'] %>
      <% end %>
      """
    When I run `msync update --noop --skip_broken --fail_on_warnings`
    Then the exit status should be 1

  Scenario: Modifying an existing file
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      Gemfile:
        gem_source: https://somehost.com
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/Gemfile.erb" with:
      """
      source '<%= @configs['gem_source'] %>'
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Files changed:
      +diff --git a/Gemfile b/Gemfile
      """
    Given I run `cat modules/maestrodev/puppet-test/Gemfile`
    Then the output should contain:
      """
      source 'https://somehost.com'
      """

  Scenario: Modifying an existing file and committing the change
    Given a mocked git configuration
    And a remote module repository
    And a file named "config_defaults.yml" with:
      """
      ---
      Gemfile:
        gem_source: https://somehost.com
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/Gemfile.erb" with:
      """
      source '<%= @configs['gem_source'] %>'
      """
    When I run `msync update -m "Update Gemfile" -r test`
    Then the exit status should be 0
    Given I cd to "sources/puppet-test"
    And I run `git checkout test`
    Then the file "Gemfile" should contain:
      """
      source 'https://somehost.com'
      """

  Scenario: Setting an existing file to unmanaged
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      Gemfile:
        unmanaged: true
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/Gemfile.erb" with:
      """
      source '<%= @configs['gem_source'] %>'
      """
    When I run `msync update --noop`
    Then the output should not match:
      """
      Files changed:
      +diff --git a/Gemfile b/Gemfile
      """
    And the output should match:
      """
      Not managing Gemfile in puppet-test
      """
    And the exit status should be 0
    Given I run `cat modules/maestrodev/puppet-test/Gemfile`
    Then the output should contain:
      """
      source 'https://rubygems.org'
      """

  Scenario: Setting an existing file to deleted
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      Gemfile:
        delete: true
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/Gemfile.erb" with:
      """
      source '<%= @configs['gem_source'] %>'
      """
    When I run `msync update --noop`
    Then the output should match:
      """
      Files changed:
      diff --git a/Gemfile b/Gemfile
      deleted file mode 100644
      """
    And the exit status should be 0

  Scenario: Setting a non-existent file to deleted
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      doesntexist_file:
        delete: true
      """
    And a directory named "moduleroot"
    When I run `msync update -m 'deletes a file that doesnt exist!' -f puppet-test`
    And the exit status should be 0

  Scenario: Setting a directory to unmanaged
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppetlabs-apache
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: puppetlabs
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      spec:
        unmanaged: true
      """
    And a directory named "moduleroot/spec"
    And a file named "moduleroot/spec/spec_helper.rb.erb" with:
      """
      some spec_helper fud
      """
    And a directory named "modules/puppetlabs/puppetlabs-apache/spec"
    And a file named "modules/puppetlabs/puppetlabs-apache/spec/spec_helper.rb" with:
      """
      This is a fake spec_helper!
      """
    When I run `msync update --offline`
    Then the output should contain:
      """
      Not managing spec/spec_helper.rb in puppetlabs-apache
      """
    And the exit status should be 0
    Given I run `cat modules/puppetlabs/puppetlabs-apache/spec/spec_helper.rb`
    Then the output should contain:
      """
      This is a fake spec_helper!
      """
    And the exit status should be 0

  Scenario: Adding a new file in a new subdirectory
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      spec/spec_helper.rb:
        require:
          - puppetlabs_spec_helper/module_helper
      """
    And a file named "moduleroot/spec/spec_helper.rb.erb" with:
      """
      <% @configs['require'].each do |required| -%>
        require '<%= required %>'
      <% end %>
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Files added:
      spec/spec_helper.rb
      """
    Given I run `cat modules/maestrodev/puppet-test/spec/spec_helper.rb`
    Then the output should contain:
      """
      require 'puppetlabs_spec_helper/module_helper'
      """

  Scenario: Updating offline
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      spec/spec_helper.rb:
        require:
          - puppetlabs_spec_helper/module_helper
      """
    And a file named "moduleroot/spec/spec_helper.rb.erb" with:
      """
      <% @configs['require'].each do |required| -%>
        require '<%= required %>'
      <% end %>
      """
    When I run `msync update --offline`
    Then the exit status should be 0
    And the output should not match /Files (changed|added|deleted):/

  Scenario: Pulling a module that already exists in the modules directory
    Given a file named "managed_modules.yml" with:
      """
      ---
        - maestrodev/puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      spec/spec_helper.rb:
        require:
          - puppetlabs_spec_helper/module_helper
      """
    And a file named "moduleroot/spec/spec_helper.rb.erb" with:
      """
      <% @configs['require'].each do |required| -%>
        require '<%= required %>'
      <% end %>
      """
    Given I run `git init modules/maestrodev/puppet-test`
    Given a file named "modules/maestrodev/puppet-test/.git/config" with:
      """
      [core]
          repositoryformatversion = 0
          filemode = true
          bare = false
          logallrefupdates = true
          ignorecase = true
          precomposeunicode = true
      [remote "origin"]
          url = https://github.com/maestrodev/puppet-test.git
          fetch = +refs/heads/*:refs/remotes/origin/*
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Files added:
      spec/spec_helper.rb
      """

  Scenario: When running update with no changes
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a directory named "moduleroot"
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should not match /diff/

  Scenario: When specifying configurations in managed_modules.yml
    Given a file named "managed_modules.yml" with:
      """
      ---
        puppet-test:
          module_name: test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Files added:
      test
      """
    Given I run `cat modules/maestrodev/puppet-test/test`
    Then the output should contain "aruba"

  Scenario: When specifying configurations in managed_modules.yml and using a filter
    Given a file named "managed_modules.yml" with:
      """
      ---
        puppet-blacksmith:
        puppet-test:
          module_name: test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update --noop -f puppet-test`
    Then the exit status should be 0
    And the output should match:
      """
      Files added:
      test
      """
    Given I run `cat modules/maestrodev/puppet-test/test`
    Then the output should contain "aruba"
    And a directory named "modules/maestrodev/puppet-blacksmith" should not exist

  Scenario: When specifying configurations in managed_modules.yml and using a negative filter
    Given a file named "managed_modules.yml" with:
      """
      ---
        puppet-blacksmith:
        puppet-test:
          module_name: test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update --noop -x puppet-blacksmith`
    Then the exit status should be 0
    And the output should match:
      """
      Files added:
      test
      """
    Given I run `cat modules/maestrodev/puppet-test/test`
    Then the output should contain "aruba"
    And a directory named "modules/maestrodev/puppet-blacksmith" should not exist

  Scenario: Updating a module with a .sync.yml file
    Given a file named "managed_modules.yml" with:
      """
      ---
        - maestrodev/puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      spec/spec_helper.rb:
        require:
          - puppetlabs_spec_helper/module_helper
      """
    And a file named "moduleroot/spec/spec_helper.rb.erb" with:
      """
      <% @configs['require'].each do |required| -%>
        require '<%= required %>'
      <% end %>
      """
    Given I run `git init modules/maestrodev/puppet-test`
    Given a file named "modules/maestrodev/puppet-test/.git/config" with:
      """
      [core]
          repositoryformatversion = 0
          filemode = true
          bare = false
          logallrefupdates = true
          ignorecase = true
          precomposeunicode = true
      [remote "origin"]
          url = https://github.com/maestrodev/puppet-test.git
          fetch = +refs/heads/*:refs/remotes/origin/*
      """
    Given a file named "modules/maestrodev/puppet-test/.sync.yml" with:
      """
      ---
      spec/spec_helper.rb:
        unmanaged: true
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Not managing spec/spec_helper.rb in puppet-test
      """

  Scenario: Module with custom namespace
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
        - electrical/puppet-lib-file_concat
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      test:
        name: aruba
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/test.erb" with:
      """
      <%= @configs['name'] %>
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Files added:
      test
      """
    Given I run `cat modules/maestrodev/puppet-test/.git/config`
    Then the output should contain "url = https://github.com/maestrodev/puppet-test.git"
    Given I run `cat modules/electrical/puppet-lib-file_concat/.git/config`
    Then the output should contain "url = https://github.com/electrical/puppet-lib-file_concat.git"

  Scenario: Modifying an existing file with values exposed by the module
    Given a file named "managed_modules.yml" with:
      """
      ---
        - puppet-test
      """
    And a file named "modulesync.yml" with:
      """
      ---
        namespace: maestrodev
        git_base: https://github.com/
      """
    And a file named "config_defaults.yml" with:
      """
      ---
      README.md:
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/README.md.erb" with:
      """
      echo '<%= @configs[:git_base] + @configs[:namespace] %>'
      """
    When I run `msync update --noop`
    Then the exit status should be 0
    And the output should match:
      """
      Files changed:
      +diff --git a/README.md b/README.md
      """
    Given I run `cat modules/maestrodev/puppet-test/README.md`
    Then the output should contain:
      """
      echo 'https://github.com/maestrodev'
      """

  Scenario: Running the same update twice and pushing to a remote branch
    Given a mocked git configuration
    And a remote module repository
    And a file named "config_defaults.yml" with:
      """
      ---
      Gemfile:
        gem_source: https://somehost.com
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/Gemfile.erb" with:
      """
      source '<%= @configs['gem_source'] %>'
      """
    When I run `msync update -m "Update Gemfile" -r test`
    Then the exit status should be 0
    Given I remove the directory "modules"
    When I run `msync update -m "Update Gemfile" -r test`
    Then the exit status should be 0
    Then the output should not contain "error"
    Then the output should not contain "rejected"

  Scenario: Repository with a default branch other than master
    Given a mocked git configuration
    And a remote module repository with "develop" as the default branch
    And a file named "config_defaults.yml" with:
      """
      ---
      Gemfile:
        gem_source: https://somehost.com
      """
    And a directory named "moduleroot"
    And a file named "moduleroot/Gemfile.erb" with:
      """
      source '<%= @configs['gem_source'] %>'
      """
    When I run `msync update -m "Update Gemfile"`
    Then the exit status should be 0
    Then the output should contain "Using repository's default branch: develop"

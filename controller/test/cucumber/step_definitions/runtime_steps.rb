# Support steps for runtime-centric tests.
#
# IMPORTANT: The steps defined here are for basic sanity checks of a 
# SINGLE application with a SINGLE gear and cartridge, and all work 
# in the context of these assumptions. If your test needs more complex 
# setups, write some more steps which are more flexible.

require 'fileutils'
require 'openshift-origin-node/utils/application_state'
require 'openshift-origin-node/utils/shell_exec'

# These are provided to reduce duplication of code in feature files.
#   Scenario Outlines are not used as they interfer with the devenv retry logic (whole feature is retried no example line)
Given /^a new ([^ ]+) application, verify it using ([^ ]+)$/ do |cart_name, proc_name|
  steps %Q{
    Given a new #{cart_name} type application
    Then the http proxy will exist
    And a #{proc_name} process will be running
    And the application git repo will exist
    And the application source tree will exist
    And the application log files will exist
    When I stop the application
    Then a #{proc_name} process will not be running
    When I start the application
    Then a #{proc_name} process will be running
    When I status the application
    Then a #{proc_name} process will be running
    When I restart the application
    Then a #{proc_name} process will be running
    When I destroy the application
    Then the http proxy will not exist
    And a #{proc_name} process will not be running
    And the application git repo will not exist
    And the application source tree will not exist
  }
end

Given /^a new ([^ ]+) application, verify create and delete using ([^ ]+)$/ do |cart_name, proc_name|
  steps %Q{
    Given a new #{cart_name} type application
    Then the http proxy will exist
    And a #{proc_name} process will be running
    And the application git repo will exist
    And the application source tree will exist
    And the application log files will exist
    When I destroy the application
    Then the http proxy will not exist
    And a #{proc_name} process will not be running
    And the application git repo will not exist
    And the application source tree will not exist
  }
end

Given /^a new ([^ ]+) application, verify start, stop, restart using ([^ ]+)$/ do |cart_name, proc_name|
  steps %Q{
    Given a new #{cart_name} type application
    Then a #{proc_name} process will be running
    When I stop the application
    Then a #{proc_name} process will not be running
    When I start the application
    Then a #{proc_name} process will be running
    When I status the application
    Then a #{proc_name} process will be running
    When I restart the application
    Then a #{proc_name} process will be running
    When I destroy the application
    Then the http proxy will not exist
    And a #{proc_name} process will not be running
  }
end

Given /^a new ([^ ]+) application, verify its availability$/ do |cart_name|
  steps %{
    Given the libra client tools
    And an accepted node
    When 1 #{cart_name} applications are created
    Then the applications should be accessible
    Then the applications should be accessible via node-web-proxy
  }
end

Given /^an existing ([^ ]+) application, verify application aliases$/ do |cart_name|
  steps %{
    Given an existing #{cart_name} application
    When the application is aliased
    Then the application should respond to the alias
  }
end

Given /^a new ([^ ]+) application, verify application alias setup on the node$/ do |cart_name|
  steps %{
    Given a new #{cart_name} type application
    And I add an alias to the application
    Then the php application will be aliased
    And the php file permissions are correct
    When I remove an alias from the application
    Then the php application will not be aliased 
    When I destroy the application
    Then the http proxy will not exist
  }
end

Given /^an existing ([^ ]+) application, verify submodules$/ do |cart_name|
  steps %{
    Given an existing #{cart_name} application
    When the submodule is added
    Then the submodule should be deployed successfully
    And the application should be accessible
  }
end

Given /^an existing ([^ ]+) application, verify code updates$/ do |cart_name|
  steps %{
    Given an existing #{cart_name} application
    When the application is changed
    Then it should be updated successfully
    And the application should be accessible
  }
end

Given /^an existing ([^ ]+) application, verify it can be stopped$/ do |cart_name|
  steps %{
    Given an existing #{cart_name} application
    When the application is stopped
    Then the application should not be accessible
  }
end

Given /^an existing ([^ ]+) application, verify it can be started$/ do |cart_name|
  steps %{
    Given an existing #{cart_name} application
    When the application is started
    Then the application should be accessible
  }
end

Given /^an existing ([^ ]+) application, verify it can be restarted$/ do |cart_name|
  steps %{
    Given an existing #{cart_name} application
    When the application is restarted
    Then the application should be accessible
  }
end

Given /^an existing ([^ ]+) application, verify it can be tidied$/ do |cart_name|
  steps %{
    Given an existing #{cart_name} application
    When I tidy the application
    Then the application should be accessible
  }
end

Given /^an existing ([^ ]+) application, verify it can be snapshotted and restored$/ do |cart_name|
  steps %{
    Given an existing #{cart_name} application    
    When I snapshot the application
    Then the application should be accessible
    When I restore the application
    Then the application should be accessible
  }
end

Given /^an existing ([^ ]+) application, verify its namespace can be changed$/ do |cart_name|
  steps %{
    Given an existing #{cart_name} application
    When the application namespace is updated
    Then the application should be accessible
  }
end

Given /^an existing ([^ ]+) application, verify it can be destroyed$/ do |cart_name|
  steps %{
    Given an existing #{cart_name} application
    When the application is destroyed
    Then the application should not be accessible
    Then the application should not be accessible via node-web-proxy
  }
end

Given /^a new ([^ ]+) application, verify rhcsh$/ do |cart_name|
  steps %{
    Given a new #{cart_name} type application
    And the application is made publicly accessible

    Then I can run "ls / > /dev/null" with exit code: 0
    And I can run "this_should_fail" with exit code: 127
    And I can run "true" with exit code: 0
    And I can run "java -version" with exit code: 0
    And I can run "scp" with exit code: 1
  }
end

Given /^a new ([^ ]+) application, verify tail logs$/ do |cart_name|
  steps %{
    Given a new #{cart_name} type application
    And the application is made publicly accessible
    Then a tail process will not be running

    When I tail the logs via ssh
    Then a tail process will be running

    When I stop tailing the logs
    Then a tail process will not be running
  }
end

Given /^a new ([^ ]+) application, obtain disk quota information via SSH$/ do |cart_name|
  steps %{
    Given a new #{cart_name} type application
    And the application is made publicly accessible
    Then I can obtain disk quota information via SSH
  }
end

Given /^a new ([^ ]+) application, use ctl_all to start and stop it, and verify it using ([^ ]+)$/ do |cart_name, proc_name|
  steps %{
    Given a new #{cart_name} type application
    And the application is made publicly accessible

    When I stop the application using ctl_all via rhcsh
    Then a #{proc_name} process will not be running

    When I start the application using ctl_all via rhcsh
    Then a #{proc_name} process will be running
  }
end

Given /^a new ([^ ]+) application, with ([^ ]+) and ([^ ]+), verify that they are running using ([^ ]+) and ([^ ]+)$/ do |cart_name, db_type, management_app, proc_name, db_proc_name|
  steps %{
    Given a new #{cart_name} type application
    And I embed a #{db_type} cartridge into the application
    And I embed a #{management_app} cartridge into the application
    And the application is made publicly accessible

    When I stop the application using ctl_all via rhcsh
    Then a #{proc_name} process for #{cart_name} will not be running
    And a #{db_proc_name} process will not be running 
    And a httpd process for #{management_app} will not be running

    When I start the application using ctl_all via rhcsh
    Then a #{proc_name} process for #{cart_name} will be running
    And a #{db_proc_name} process will be running
    And a httpd process for #{management_app} will be running
  }
end

Given /^a new ([^ ]+) application, verify using socket file to connect to database$/ do |cart_name|
  steps %{  
    Given a new #{cart_name} type application
    And I embed a mysql-5.1 cartridge into the application
    And the application is made publicly accessible
  
    When I select from the mysql database using the socket file
    Then the select result from the mysql database should be valid
  }
end

Given /^a new ([^ ]+) application, verify when hot deploy is( not)? enabled, it does( not)? change pid of ([^ ]+) proc$/ do |cart_name, hot_deply_not_enabled, pid_not_changed, proc_name|
  steps %{
    Given a new #{cart_name} type application
    And the application is made publicly accessible
    And hot deployment is#{hot_deply_not_enabled} enabled for the application
    And the application cartridge PIDs are tracked
    When an update is pushed to the application repo
    Then a #{proc_name} process will be running
    And the tracked application cartridge PIDs should#{pid_not_changed} be changed
    When I destroy the application
    Then a #{proc_name} process will not be running
  }
end

# Creates a new account, application, gear, and cartridge in one shot.
# The cartridge is then configured. After running this step, subsequent
# steps will have access to three pieces of state:
#
#   @account: a TestAccount instance with randomly generated properties
#   @app: a TestApplication instance associated with @account
#   @gear: a TestGear instance associated with @app
#   @cart: a TestCartridge instance associated with @gear
#
# The type of cartridge created will be of type cart_name from the step
# matcher.
Given /^a(n additional)? new ([^ ]+) type application$/ do | additional, cart_name |
  record_measure("Runtime Benchmark: Creating cartridge #{cart_name}") do
    if additional 
      assert_not_nil @account, 'You must create a new application before an additional application can be created'
    else
      @account = OpenShift::TestAccount.new
      @app = @account.create_app
    end

    @gear = @app.create_gear

    @cart = @gear.add_cartridge(cart_name)
    @cart.configure
  end
end

Given /^a new cli-created ([^ ]+) type application$/ do |cart_name|
  record_measure("Runtime Benchmark: Creating cartridge #{cart_name} with CLI tools") do
    @account = OpenShift::TestAccount.new
    @app = @account.create_app
    @gear = @app.create_gear(true)
    @cart = @gear.add_cartridge(cart_name)
    @cart.configure(true)
  end
end

# Invokes destroy on the current application.
When /^I destroy the application$/ do
  record_measure("Runtime Benchmark: Destroying cartridge #{@cart.name}") do
    @app.destroy
  end
end

# Embeds a new cartridge to the current application's gear
# Calls configure on the embedded cartridge.
When /^I (fail to )?embed a ([^ ]+) cartridge into the application$/ do | negate, cart_name |
  record_measure("Runtime Benchmark: Configure #{cart_name} cartridge in cartridge #{@cart.name}") do
    cart = @gear.add_cartridge(cart_name)

    if negate
      assert_raise(OpenShift::Utils::ShellExecutionException) do
        exit_code = cart.configure
      end
    else
      cart.configure
    end
  end
end

# Un-embeds a cartridge from the current application's gear by 
# invoking deconfigure on the named cartridge.
When /^I remove the ([^ ]+) cartridge from the application$/ do | cart_name |
  record_measure("Runtime Benchmark: Deconfigure #{cart_name} cartridge in cartridge #{@cart.name}") do
    raise "No embedded cart named #{cart_name} associated with gear #{@gear.uuid}" unless @gear.carts.has_key?(cart_name)

    embedded_cart = @gear.carts[cart_name]

    embedded_cart.deconfigure
  end
end

# Verifies the existence of the httpd proxy
Then /^the http proxy ?([^ ]+)? will( not)? exist$/ do | path, negate |
  paths = @gear.list_http_proxy_paths

  if path == nil
    path = ""
  end

  $logger.info("Checking for #{negate} proxy #{path}")
  if negate
    assert_not_includes(paths, path)
  else
    assert_includes(paths, path)
  end
end

# Verifies the existence of a git repo associated with the current
# application.
Then /^the application git repo will( not)? exist$/ do | negate |
  git_repo = "#{$home_root}/#{@gear.uuid}/git/#{@app.name}.git"

  # TODO - need to check permissions and SELinux labels

  $logger.info("Checking for #{negate} git repo at #{git_repo}")
  if negate
    assert_directory_not_exists git_repo
  else
    assert_directory_exists git_repo
  end
end


# Verifies the existence of an exported source tree associated with
# the current application.
Then /^the application source tree will( not)? exist$/ do | negate |
  app_root = "#{$home_root}/#{@gear.uuid}/#{@cart.name}"

  # TODO - need to check permissions and SELinux labels

  $logger.info("Checking for app root at #{app_root}")
  if negate
    assert_directory_not_exists app_root
  else
    assert_directory_exists app_root
  end
end


# Verifies the existence of application log files associated with the
# current application.
Then /^the application log files will( not)? exist$/ do | negate |
  log_dir_path = "#{$home_root}/#{@gear.uuid}/#{@cart.name}/logs"

  $logger.info("Checking for log dir at #{log_dir_path}")

  begin
    log_dir = Dir.new log_dir_path
    status = (log_dir.count > 2)
  rescue
    status = false
  end

  if not negate
    status.should be_true
  else
    status.should be_false
  end
end


# Ensures that the root directory exists for the given embedded cartridge.
Then /^the embedded ([^ ]+) cartridge directory will( not)? exist$/ do | cart_name, negate |
  user_root = "#{$home_root}/#{@gear.uuid}/#{cart_name}"

  $logger.info("Checking for #{negate} cartridge root dir at #{user_root}")
  if negate
    assert_directory_not_exists user_root
  else
    assert_directory_exists user_root
  end
end


# Ensures that more than zero log files exist in the given embedded cartridge
# log directory.
Then /^the embedded ([^ ]+) cartridge log files will( not)? exist$/ do | cart_name, negate |
  log_dir_path = "#{$home_root}/#{@gear.uuid}/#{cart_name}/logs"

  $logger.info("Checking for #{negate} cartridge log dir at #{log_dir_path}")
  if negate
    assert_directory_not_exists log_dir_path
  else
    assert_directory_exists log_dir_path
  end
end


# Simple verification of arbitrary cartridge directory existence.
Then /^the embedded ([^ ]+) cartridge subdirectory named ([^ ]+) will( not)? exist$/ do | cart_name, dir_name, negate |
  dir_path = "#{$home_root}/#{@gear.uuid}/#{cart_name}/#{dir_name}"

  $logger.info("Checking for #{negate} cartridge subdirectory at #{dir_path}")
  if negate
    assert_directory_not_exists dir_path
  else
    assert_directory_exists dir_path
  end
end


# Ensures that the named control script exists for the given embedded cartridge of the
# current application.
Then /^the embedded ([^ ]+)\-([\d\.]+) cartridge control script will( not)? exist$/ do |cart_type, cart_version, negate|
  # rewrite for 10gen-mms-agent
  cooked = cart_type.gsub('-', '_')
  startup_file = File.join($home_root,
                           @gear.uuid,
                           "#{cart_type}-#{cart_version}",
                          "#{@app.name}_#{cooked}_ctl.sh")

  $logger.info("Checking for #{negate} cartridge control script at #{startup_file}")
  if negate
    assert_file_not_exists startup_file
  else
    assert_file_exists startup_file
  end
end


# Used to control the runtime state of the current application.
#
# IMPORTANT: As mentioned in the general comments, this step assumes
# a single application/gear/cartridge, and does its work by controlling
# the single cartridge directly. There will be no recursive actions for
# multiple carts associated with an app/gear.
When /^I (start|stop|status|restart|call tidy on) the application$/ do |action|
  # XXX FIXME: hack necessary due to ambiguous step definition
  # w/ application_steps.rb
  if ('call tidy on' == action)
    action = 'tidy'
  end

  OpenShift::timeout(60) do
    record_measure("Runtime Benchmark: Hook #{action} on application #{@cart.name}") do
      @cart.send(action)
    end
  end
end


# Controls carts within the current gear directly, by cartridge name.
# The same comments from the similar matcher apply.
When /^I (start|stop|status|restart) the ([^ ]+) cartridge$/ do |action, cart_name|
  record_measure("Runtime Benchmark: Hook #{action} on cart #{@cart.name}") do
    @gear.carts[cart_name].send(action)
  end
end


# Verifies that a process named proc_name and associated with the current
# application will be running (or not). The step will retry up to max_tries
# times to verify the expectations, as some cartridge stop hooks are
# asynchronous. This doesn't outright eliminate timing issues, but it helps.
Then /^a (.+) process will( not)? be running$/ do | proc_name, negate |
  exit_test = negate ? lambda { |tval| tval == 0 } : lambda { |tval| tval > 0 }
  exit_test_desc = negate ? "0" : ">0"

  num_node_processes = num_procs @gear.uuid, proc_name
  $logger.info("Expecting #{exit_test_desc} pid(s) named #{proc_name}, found #{num_node_processes}")
  OpenShift::timeout(20) do
    while (not exit_test.call(num_node_processes))
      $logger.info("Waiting for #{proc_name} process count to be #{exit_test_desc}")
      sleep 1 
      num_node_processes = num_procs @gear.uuid, proc_name
    end
  end

  if not negate
    num_node_processes.should be > 0
  else
    num_node_processes.should be == 0
  end
end


# Verifies that a process named proc_name and associated with the current
# application will be running (or not). The step will retry up to max_tries
# times to verify the expectations, as some cartridge stop hooks are
# asynchronous. This doesn't outright eliminate timing issues, but it helps.
Then /^a (.+) process for ([^ ]+) will( not)? be running$/ do | proc_name, label, negate |
  exit_test = negate ? lambda { |tval| tval == 0 } : lambda { |tval| tval > 0 }
  exit_test_desc = negate ? "0" : ">0"

  num_node_processes = num_procs @gear.uuid, proc_name, label
  $logger.info("Expecting #{exit_test_desc} pid(s) named #{proc_name}, found #{num_node_processes}")
  OpenShift::timeout(20) do
    while (not exit_test.call(num_node_processes))
      $logger.info("Waiting for #{proc_name} process count to be #{exit_test_desc}")
      sleep 1 
      num_node_processes = num_procs @gear.uuid, proc_name, label
    end
  end

  if not negate
    num_node_processes.should be > 0
  else
    num_node_processes.should be == 0
  end
end

# Verifies that exactly the specified number of the named processes
# are currently running.
#
# Could maybe be consolidated with the other similar step with some
# good refactoring.
Then /^(\d+) process(es)? named ([^ ]+) will be running$/ do | proc_count, junk, proc_name |
  proc_count = proc_count.to_i

  num_node_processes = num_procs @gear.uuid, proc_name
  $logger.info("Expecting #{proc_count} pid(s) named #{proc_name}, found #{num_node_processes}")
  OpenShift::timeout(20) do
    while (num_node_processes != proc_count)
      $logger.info("Waiting for #{proc_name} process count to equal #{proc_count}")
      sleep 1
      num_node_processes = num_procs @gear.uuid, proc_name
    end
  end
  
  num_node_processes.should be == proc_count
end

# Verifies that exactly the specified number of the named processes
# with arguments matching 'label' are currently running.
#
# Could maybe be consolidated with the other similar step with some
# good refactoring.
Then /^(\d+) process(es)? named ([^ ]+) for ([^ ]+) will be running$/ do | proc_count, junk, proc_name, label |
  proc_count = proc_count.to_i

  num_node_processes = num_procs @gear.uuid, proc_name, label
  $logger.info("Expecting #{proc_count} pid(s) named #{proc_name}, found #{num_node_processes}")
  OpenShift::timeout(20) do
    while (num_node_processes != proc_count)
      $logger.info("Waiting for #{proc_name} process count to equal #{proc_count}")
      sleep 1
      num_node_processes = num_procs @gear.uuid, proc_name, label
    end
  end
  
  num_node_processes.should be == proc_count
end


# Makes the application publicly accessible.
#
#   - Adds an /etc/hosts entry for the application to work around
#     the lack of DNS
#   - Adds the test pubkey to the authorized key list for the host
#   - Disables strict host key checking for the host to suppress
#     interactive prompts on push
#
# This is not pretty. If it can be made less hackish and faster, it
# could be moved into the generic application setup step.
When /^the application is made publicly accessible$/ do
  ssh_key = IO.read($test_pub_key).chomp.split[1]
  run "echo \"127.0.0.1 #{@app.name}-#{@account.domain}.#{$cloud_domain} # Added by cucumber\" >> /etc/hosts"
  run "oo-authorized-ssh-key-add -a #{@gear.uuid} -c #{@gear.uuid} -s #{ssh_key} -t ssh-rsa -m default"
  run "echo -e \"Host #{@app.name}-#{@account.domain}.#{$cloud_domain}\n\tStrictHostKeyChecking no\n\" >> ~/.ssh/config"
end

When /^the application is prepared for git pushes$/ do
  @app.git_repo = "#{$temp}/#{@account.name}-#{@app.name}-clone"
  run "git clone ssh://#{@gear.uuid}@#{@app.name}-#{@account.domain}.#{$cloud_domain}/~/git/#{@app.name}.git #{@app.git_repo}"
end


# Captures the current cartridge PID hash for the test application and
# makes it accessible to other steps via @current_cart_pids.
When /^the application cartridge PIDs are tracked$/ do 
  @current_cart_pids = @app.current_cart_pids

  $logger.info("Tracking current cartridge pids for application #{@app.name}: #{@current_cart_pids.inspect}")
end


# Toggles hot deployment for the current application.
When /^hot deployment is( not)? enabled for the application$/ do |negate|
  @app.hot_deploy_enabled = negate ? false : true
  $logger.info("Hot deployment #{@app.hot_deploy_enabled ? 'enabled' : 'disabled'} for application #{@app.name}")
end


# Expands the "simple update" step and adds hot deployment stuff for legacy carts.
When /^an update (is|has been) pushed to the application repo$/ do |junk|
  record_measure("Runtime Benchmark: Updating #{$temp}/#{@account.name}-#{@app.name} source") do
    steps %{
    When the application is prepared for git pushes
    }

    marker_file = File.join(@app.git_repo, '.openshift', 'markers', 'hot_deploy')

    if @app.hot_deploy_enabled
      FileUtils.touch(marker_file)
    else
      FileUtils.rm_f(marker_file)
    end

    steps %{
    When a simple update is pushed to the application repo
    }
  end
end

# Performs a trivial update to the test application source by appending
# some random stuff to a dummy file. The change is then committed and 
# pushed to the app's Git repo.
When /^a simple update is pushed to the application repo$/ do
  record_measure("Runtime Benchmark: Pushing random change to app repo at #{@app.git_repo}") do
    Dir.chdir(@app.git_repo) do
      # Make a change to the app repo
      run "echo $RANDOM >> cucumber_update_test"
      run "git add ."
      run "git commit -m 'Test change'"
      push_output = `git push`
      $logger.info("Push output:\n#{push_output}")
    end
  end
end

# Adds/removes aliases from the application
When /^I add an alias to the application/ do
  server_alias = "#{@app.name}.#{$alias_domain}"

  @gear.add_alias(server_alias)
end


# Adds/removes aliases from the application
When /^I remove an alias from the application/ do
  server_alias = "#{@app.name}.#{$alias_domain}"

  @gear.remove_alias(server_alias)
end


# Asserts the 'cucumber_update_test' file exists after an update
Then /^the application repo has been updated$/ do
  assert_file_exists File.join($home_root,
                              @gear.uuid,
                              'app-root',
                              'runtime',
                              'repo',
                              'cucumber_update_test')
end

# Compares the current PID set for the test application to whatever state
# was last captured and stored in @current_cart_pids. Raises exceptions
# depending on the expectations configured by the matcher.
Then /^the tracked application cartridge PIDs should( not)? be changed$/ do |negate|
  diff_expected = !negate # better way to do this?

  new_cart_pids = @app.current_cart_pids

  $logger.info("Comparing old and new PIDs for #{@app.name}, diffs are #{diff_expected ? 'expected' : 'unexpected' }." \
    " Old PIDs: #{@current_cart_pids.inspect}, new PIDs: #{new_cart_pids.inspect}")

  diffs = []

  @current_cart_pids.each do |proc_name, old_pid|
    new_pid = new_cart_pids[proc_name]

    if !new_pid || (new_pid != old_pid)
      diffs << proc_name
    end
  end

  if !diff_expected && diffs.length > 0
    raise "Expected no PID differences, but found #{diffs.length}. Old PIDs: #{@current_cart_pids.inspect},"\
      " new PIDs: #{new_cart_pids.inspect}"
  end

  if diff_expected && diffs.length == 0
    raise "Expected PID differences, but found none. Old PIDs: #{@current_cart_pids.inspect},"\
      " new PIDs: #{new_cart_pids.inspect}"
  end

  # verify BZ852268 fix
  state_file = File.join($home_root, @gear.uuid, 'app-root', 'runtime', '.state')
  state = File.read(state_file).chomp
  assert_equal 'started', state
end

Then /^the web console for the ([^ ]+)\-([\d\.]+) cartridge at ([^ ]+) is( not)? accessible$/ do |cart_type, version, uri, negate|

  url = "https://127.0.0.1#{uri}"

  finished = negate ? lambda { |s| s == "503" } : lambda { |s| s == "200"}
  cmd = "curl -L -k -w %{http_code} -s -o /dev/null -H 'Host: #{@app.name}-#{@account.domain}.#{$domain}' #{url}"
  res = `#{cmd}`
  OpenShift::timeout(300) do
    while not finished.call res
      res = `#{cmd}`
      $logger.debug { "Waiting on #{cart_type} to#{negate} be accessible: status #{res}" }
      sleep 1
    end 
  end

  msg = "Unexpected response from #{cmd}"
  if negate
    assert_equal "503", res, msg
  else
    assert_equal "200", res, msg
  end
end

#####################
# V2-focused steps
#####################

def app_env_var_will_exist(var_name, prefix = true)
  if prefix
    var_name = "OPENSHIFT_#{var_name}"
  end

  var_file_path = File.join($home_root, @gear.uuid, '.env', var_name)

  assert_file_exists var_file_path
end

def app_env_var_will_not_exist(var_name, prefix = true)
  if prefix
    var_name = "OPENSHIFT_#{var_name}"
  end

  var_file_path = File.join($home_root, @gear.uuid, '.env', var_name)

  assert_file_not_exists var_file_path
end


def cart_env_var_will_exist(cart_name, var_name, negate = false)
  var_name = "OPENSHIFT_#{var_name}"

  cartridge = @gear.container.cartridge_model.get_cartridge(cart_name)

  var_file_path = File.join($home_root, @gear.uuid, cartridge.directory, 'env', var_name)

  if negate
    assert_file_not_exists var_file_path
  else
    assert_file_exists var_file_path
    assert((File.stat(var_file_path).size > 0), "#{var_file_path} is empty")
  end
end

# Used to control the runtime state of the current application.
When /^I (start|stop|status|restart|tidy) the newfangled application$/ do |action|
  OpenShift::timeout(60) do
    record_measure("Runtime Benchmark: Hook #{action} on application #{@cart.name}") do
      @app.send(action)
    end
  end
end


Given /^a v2 default node$/ do
  assert_file_exists '/var/lib/openshift/.settings/v2_cartridge_format'
end

Then /^the "(.*)" content does( not)? exist(s)? for ([^ ]+)$/ do |path, negate, _, cartridge_name|
  cartridge = @gear.container.cartridge_model.get_cartridge(cartridge_name)
  entry = File.join($home_root, @gear.uuid, path)

  if negate
    assert_file_not_exists entry
  else
    assert_file_exists entry
  end
end

Then /^the ([^ ]+) cartridge will support threaddump/ do |cartridge_name|
    @gear.container.threaddump(cartridge_name)
end

Then /^the ([^ ]+) cartridge instance directory will( not)? exist$/ do |cartridge_name, negate|
  cartridge = @gear.container.cartridge_model.get_cartridge(cartridge_name)

  cartridge_dir = File.join($home_root, @gear.uuid, cartridge.directory)

  if negate
    assert_directory_not_exists cartridge_dir
  else
    assert_directory_exists cartridge_dir
  end
end

Then /^the ([^ ]+) ([^ ]+) env entry will( not)? exist$/ do |cartridge_name, variable, negate|
  cart_env_var_will_exist(cartridge_name, variable, negate)
end

Then /^the platform-created default environment variables will exist$/ do
  app_env_var_will_exist('APP_DNS')
  app_env_var_will_exist('APP_NAME')
  app_env_var_will_exist('APP_UUID')
  app_env_var_will_exist('DATA_DIR')
  app_env_var_will_exist('REPO_DIR')
  app_env_var_will_exist('GEAR_DNS')
  app_env_var_will_exist('GEAR_NAME')
  app_env_var_will_exist('GEAR_UUID')
  app_env_var_will_exist('TMP_DIR')
  app_env_var_will_exist('HOMEDIR')
  app_env_var_will_exist('HISTFILE', false)
  app_env_var_will_exist('PATH', false)
end

Then /^the ([^ ]+) cartridge private endpoints will be (exposed|concealed)$/ do |cart_name, action|
  cartridge = @gear.container.cartridge_model.get_cartridge(cart_name)

  cartridge.endpoints.each do |endpoint|
    $logger.info("Validating private endpoint #{endpoint.private_ip_name}:#{endpoint.private_port_name} "\
                 "for cartridge #{cart_name}")
    case action
    when 'exposed'
      app_env_var_will_exist(endpoint.private_ip_name, false)
      app_env_var_will_exist(endpoint.private_port_name, false)
    when 'concealed'
      app_env_var_will_not_exist(endpoint.private_ip_name, false)
      app_env_var_will_not_exist(endpoint.private_port_name, false)
    end
  end
end

Then /^the application state will be ([^ ]+)$/ do |state_value|
  state_const = OpenShift::State.const_get(state_value.upcase)

  raise "Invalid state '#{state_value}' provided to step" unless state_const

  assert_equal @gear.container.state.value, state_const
end

Then /^the ([^ ]+) cartridge status should be (running|stopped)$/ do |cart_name, expected_status|
  begin
    @gear.carts[cart_name].status
    # If we're here, the cart status is 'running'
    raise "Expected #{cart_name} cartridge to be stopped" if expected_status == "stopped"
  rescue OpenShift::Utils::ShellExecutionException
    # If we're here, the cart status is 'stopped'
    raise if expected_status == "running"
  end
end

Then /^the application stoplock should( not)? be present$/ do |negate|
  stop_lock = File.join($home_root, @gear.uuid, 'app-root', 'runtime', '.stop_lock')

  if negate
    assert_file_not_exists stop_lock
  else
    assert_file_exists stop_lock
  end 
end

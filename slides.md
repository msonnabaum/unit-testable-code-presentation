---
.main-title
# WRITING UNIT TESTABLE CODE IN DRUPAL 8

### by Mark Sonnabaum and Kat Bailey

---

## 👋, I'm Mark Sonnabaum

### [@msonnabaum](http://twitter.com/msonnabaum)

### Performance engineer at [Acquia](//acquia.com)

---
.title

# What is a
# unit test?

---

## Verifies the behavior
## of a **unit** of code
---

## in **isolation**
---

## independent of 
## application **context**

---

## Unit tests are **fast**
# 🐇
---
## Fast tests are not
## always **unit** tests
---
## Unit tests do not
## replace **integration** 🐢 and
## **acceptance** 🐌 tests
---
.title2
# Why unit test?

---
.title3
# Code quality
---
## Context independence
---
## Documentation
---
## Refactoring
---
## Feedback
---
.title2
# What does it mean to be testable?

---
.quote
> …for a class to be easy to unit-test, the class must have explicit dependencies that can easily be substituted and clear responsibilities that can easily be invoked and verified.

<cite>Freeman, Steve; Pryce, Nat (2009-10-12). Growing Object-Oriented Software, Guided by Tests</cite>

---
.title3

# D7
---
.code .blah data-selection=1-5

```php
function user_multiple_role_edit($accounts, $operation, $rid) {
  // The role name is not necessary as user_save() will reload the user
  // object, but some modules' hook_user() may look at this first.
  $role_name = db_query('SELECT name FROM {role} WHERE rid = :rid',
    array(':rid' => $rid))->fetchField();

  switch ($operation) {
    case 'add_role':
      $accounts = user_load_multiple($accounts);
      foreach ($accounts as $account) {
        // Skip adding the role to the user if they already have it.
        if ($account !== FALSE && !isset($account->roles[$rid])) {
          $roles = $account->roles + array($rid => $role_name);
          // For efficiency manually save the original account
          // before applying any changes.
          $account->original = clone $account;
          user_save($account, array('roles' => $roles));
        }
      }
      break;
```
---
.dependency-tree .tree1

- user_multiple_role_edit
  - db_query
  - user_load_multiple
  - user_save
---
.dependency-tree .tree2

- user_multiple_role_edit
  - db_query
    - Database
  - user_load_multiple
    - entity_load
  - user_save
    - db_transaction
    - user_hash_password
    - entity_load_unchanged
    - user_module_invoke
    - field_attach_presave
    - module_invoke_all
    - drupal_write_record
    - db_delete
    - db_insert
    - DRUPAL_ANONYMOUS_RID
    - DRUPAL_AUTHENTICATED_RID
    - field_attach_update

---
.dependency-tree .tree3

- user_multiple_role_edit
  - db_query
    - Database
      - global $databases
  - user_load_multiple
    - entity_load
      - entity_get_controller
        - drupal_static
        - entity_get_info
          - global $language
          - cache_get
          - module_invoke_all
          - drupal_alter
          - cache_set
  - user_save
    - db_transaction
    - user_hash_password
    - entity_load_unchanged
    - user_module_invoke
    - field_attach_presave
    - module_invoke_all
    - drupal_write_record
    - db_delete
    - db_insert
    - DRUPAL_ANONYMOUS_RID
    - DRUPAL_AUTHENTICATED_RID
    - field_attach_update

---
.dependency-tree .tree4

- user_multiple_role_edit
  - db_query
    - Database
      - global $databases
  - user_load_multiple
    - entity_load
      - entity_get_controller
        - drupal_static
        - entity_get_info
          - global $language
          - cache_get
            - _cache_get_object
              - variable_get
                - global $conf
          - module_invoke_all
            - module_implements
              - drupal_static_reset
              - cache_clear_all
                - module_exists
                  - module_list
                    - drupal_get_filename
                      - DRUPAL_ROOT
                      - DRUPAL_PHP_FUNCTION_PATTERN
                      - drupal_system_listing
                        - conf_path
                        - drupal_get_profile
                          - global $install_state
                        - drupal_valid_test_ua
                          - global $drupal_hash_salt
                        - file_scan_directory
                          - file_stream_wrapper_uri_normalize
                            - file_uri_scheme
                            - file_stream_wrapper_valid_scheme
                              - file_stream_wrapper_get_class
                                - file_get_stream_wrappers
                                  - STREAM_WRAPPERS_*
                            - file_uri_target
                          - PATHINFO_FILENAME
                        - drupal_parse_info_file
                          - drupal_parse_info_format
                        - DRUPAL_CORE_COMPATIBILITY
                    - system_list
              - module_hook_info
                - drupal_bootstrap
                - DRUPAL_BOOTSTRAP_FULL
              - module_load_include
                - drupal_get_path
          - drupal_alter
          - cache_set
  - user_save
    - db_transaction
    - user_hash_password
    - entity_load_unchanged
    - user_module_invoke
    - field_attach_presave
    - module_invoke_all
    - drupal_write_record
    - db_delete
    - db_insert
    - DRUPAL_ANONYMOUS_RID
    - DRUPAL_AUTHENTICATED_RID
    - field_attach_update

---

# 🙈
---
.title3

# D8

---
.code

```php
class AddRoleUser extends ChangeUserRoleBase {
  public function execute($account = NULL) {
    $rid = $this->configuration['rid'];
    // Skip adding the role to the user if they already have it.
    if ($account !== FALSE && !$account->hasRole($rid)) {
      // For efficiency manually save the original account before applying
      // any changes.
      $account->original = clone $account;
      $account->addRole($rid);
      $account->save();
    }
  }
}
```
---
.code

```php
  public function testExecuteAddExistingRole() {
    $account = $this
      ->getMockBuilder('Drupal\user\Entity\User')
      ->disableOriginalConstructor()
      ->getMock();

                                     
                          

                                   
                         
                                           
                                       

                                            
                                                                 
                                                                    

                                   
  }
```
---
.code

```php
  public function testExecuteAddExistingRole() {
    $account = $this
      ->getMockBuilder('Drupal\user\Entity\User')
      ->disableOriginalConstructor()
      ->getMock();

    $account->expects($this->never())
      ->method('addRole');

                                   
                         
                                           
                                       

                                            
                                                                 
                                                                    

                                   
  }
```
---
.code

```php
  public function testExecuteAddExistingRole() {
    $account = $this
      ->getMockBuilder('Drupal\user\Entity\User')
      ->disableOriginalConstructor()
      ->getMock();

    $account->expects($this->never())
      ->method('addRole');

    $account->expects($this->any())
      ->method('hasRole')
      ->with($this->equalTo('test_role_1'))
      ->will($this->returnValue(TRUE));

                                            
                                                                 
                                                                    

                                   
  }
```
---
.code

```php
  public function testExecuteAddExistingRole() {
    $account = $this
      ->getMockBuilder('Drupal\user\Entity\User')
      ->disableOriginalConstructor()
      ->getMock();

    $account->expects($this->never())
      ->method('addRole');

    $account->expects($this->any())
      ->method('hasRole')
      ->with($this->equalTo('test_role_1'))
      ->will($this->returnValue(TRUE));

    $config = array('rid' => 'test_role_1');
    $role_adder = new AddRoleUser($config,'user_add_role_action',
                                           array('type' => 'user'));

                                   
  }
```
---
.code

```php
  public function testExecuteAddExistingRole() {
    $account = $this
      ->getMockBuilder('Drupal\user\Entity\User')
      ->disableOriginalConstructor()
      ->getMock();

    $account->expects($this->never())
      ->method('addRole');

    $account->expects($this->any())
      ->method('hasRole')
      ->with($this->equalTo('test_role_1'))
      ->will($this->returnValue(TRUE));

    $config = array('rid' => 'test_role_1');
    $role_adder = new AddRoleUser($config,'user_add_role_action',
                                           array('type' => 'user'));

    $role_adder->execute($account);
  }
```
---
.title3
## Clear responsibilities,
## easily invoked and verified
---
.title3
## Explicit, easily
## substituted dependencies
# 🐒
---
.title
# Test doubles
---
.code
```php
class SomeStuff {
  function __construct(StuffStorageInterface $stuff_storage) {
    $this->stuffstorage = $stuff_storage;
  }

  function getStuff($this_stuff) {
    return $this->stuffstorage->get($this_stuff);
  }
}

interface StuffStorageInterface {
  function set($id, $value);
  function get($id);
}
```
---
.title2
# Fakes
---
.code
```php
class FakeStuffstorage implements StuffStorageInterface {
  public $stuffs = array();

  function set($id, $value) {
    $this->stuffs[$id] = $value;
  }

  function get($id) {
    return $this->stuffs[$id];
  }
}
```
---
.code
```php
  function testStuffWithFake() {
    $stuff_storage = new FakeStuffStorage;
    $stuff_storage->set('blah', 'asdf');

    $somestuff = new SomeStuff($stuff_storage);

    $stuff = $somestuff->getStuff('blah');
    $this->assertEquals('asdf', $stuff);
  }
```
---
.title2
# Stubs
---
.code
```php
  
  function testStuffWithStubb() {
    $stuff_storage = $this->getMock('StuffstorageInterface');
    $stuff_storage->expects($this->any())
                  ->method('get')
                  ->will($this->returnValue('asdf'));

    $somestuff = new SomeStuff($stuff_storage);

    $stuff = $somestuff->getStuff('blah');
    $this->assertEquals('asdf', $stuff);
  }

```
---

## Used for **indirect input** 👈
## Asserts on **state**
---
.title2
# Mocks
---


## Haven't we always used mocks in Drupal?
---

    Drupal\Component\Reflection\MockFileFinder
    Drupal\edit_test\MockEditEntityFieldAccessCheck
    Drupal\system\Tests\FileTransfer\MockTestConnection
    Drupal\system\Tests\Routing\MockAliasManager
    Drupal\system\Tests\Routing\MockController
    Drupal\system\Tests\Routing\MockMatcher
    Drupal\system\Tests\Routing\MockRouteProvider
    Drupal\plugin_test\Plugin\CachedMockBlockManager
    Drupal\plugin_test\Plugin\MockBlockManager
    Drupal\plugin_test\Plugin\plugin_test\mock_block\MockComplexContextBlock
    Drupal\plugin_test\Plugin\plugin_test\mock_block\MockLayoutBlock
    Drupal\plugin_test\Plugin\plugin_test\mock_block\MockLayoutBlockDeriver
    Drupal\plugin_test\Plugin\plugin_test\mock_block\MockMenuBlock
    Drupal\plugin_test\Plugin\plugin_test\mock_block\MockMenuBlockDeriver
    Drupal\plugin_test\Plugin\plugin_test\mock_block\MockTestBlock
    Drupal\plugin_test\Plugin\plugin_test\mock_block\MockUserLoginBlock
    Drupal\plugin_test\Plugin\plugin_test\mock_block\MockUserNameBlock
---

## Not actually mocks
# 😿
---
.code
```php
  function testStuffWithMock() {
    $stuff_storage = $this->getMock('StuffstorageInterface');
    $stuff_storage->expects($this->once())
                  ->method('get');

    $somestuff = new SomeStuff($stuff_storage);

    $stuff = $somestuff->getStuff('blah');
  }


```
---

## Used for **indirect output** 👉
## Asserts on **behavior**
---
.title3
# Only mock what you own
---
.quote

> Mock Objects is a design technique, so programmers should only write mocks for types that they can change. Otherwise they cannot change the design to respond to requirements that arise from the process.

<cite>Steve Freeman, Tim Mackinnon, Nat Pryce, Joe Walnes - Mock roles, not objects OOPSLA '04</cite>

---
.title2
# Drupal 8
---
.code
```php
$processed_path = drupal_lookup_path('source',
                                     $base_path,
                                     $path_language));
if ($processed_path !== $path) {
  $path = $processed_path . '/' . implode('/', $subpath);
  return $path;
}
```
---
.dependency-tree .tree2

- drupal_lookup_path
  - global $language_url
  - drupal_static
  - variable_get
  - drupal_path_alias_whitelist_rebuild
  - current_path
  - cache_get
  - LANGUAGE_NONE
  - db_query

---
.code
```php
$processed_path = $this->pathProcessor->processInbound($path,
                                                       $request);

if ($processed_path !== $path) {
  $path = $processed_path . '/' . implode('/', $subpath);
  return $path;
}
```
---
.code
```yaml
# subpathauto.services.yml
services:
  path_processor_subpathauto:
    class: Drupal\subpathauto\PathProcessor
    arguments: ['@path_processor_alias']
    tags:
      - { name: path_processor_inbound }
```
---
.code
```php
public function testInboundSubPath() {
  $alias_processor = $this
    ->getMockBuilder('Drupal\Core\PathProcessor\PathProcessorAlias')
    ->disableOriginalConstructor()
    ->getMock();

                                         
                              
                                 
                                        
      

                                                           

                                                         
                                                  
                           
                                           
    
                                              
}
```
---
.code
```php
public function testInboundSubPath() {
  $alias_processor = $this
    ->getMockBuilder('Drupal\Core\PathProcessor\PathProcessorAlias')
    ->disableOriginalConstructor()
    ->getMock();

  $alias_processor->expects($this->once())
    ->method('processInbound')
    ->with('content/first-node')
    ->will($this->returnValue('node/1'));




                                                         
                                                  
                           
                                           
    
                                              
}
```
---
.code
```php
public function testInboundSubPath() {
  $alias_processor = $this
    ->getMockBuilder('Drupal\Core\PathProcessor\PathProcessorAlias')
    ->disableOriginalConstructor()
    ->getMock();

  $alias_processor->expects($this->once())
    ->method('processInbound')
    ->with('content/first-node')
    ->will($this->returnValue('node/1'));

  $subpath_processor = new PathProcessor($alias_processor);

                                                         

                                                  
                           
                                           
    
                                              
}
```
---
.code
```php
public function testInboundSubPath() {
  $alias_processor = $this
    ->getMockBuilder('Drupal\Core\PathProcessor\PathProcessorAlias')
    ->disableOriginalConstructor()
    ->getMock();

  $alias_processor->expects($this->once())
    ->method('processInbound')
    ->with('content/first-node')
    ->will($this->returnValue('node/1'));

  $subpath_processor = new PathProcessor($alias_processor);

  // Look up a subpath of the 'content/first-node' alias.
  $processed = $subpath_processor->processInbound(
    'content/first-node/a',
    Request::create('content/first-node/a')
  );
                                              

}
```
---
.code
```php
public function testInboundSubPath() {
  $alias_processor = $this
    ->getMockBuilder('Drupal\Core\PathProcessor\PathProcessorAlias')
    ->disableOriginalConstructor()
    ->getMock();

  $alias_processor->expects($this->once())
    ->method('processInbound')
    ->with('content/first-node')
    ->will($this->returnValue('node/1'));

  $subpath_processor = new PathProcessor($alias_processor);

  // Look up a subpath of the 'content/first-node' alias.
  $processed = $subpath_processor->processInbound(
    'content/first-node/a',
    Request::create('content/first-node/a')
  );

  $this->assertEquals('node/1/a', $processed);
}
```

<!-- TODO: Better transition here? -->

---
## So testable classes need to be defined as services?
# 💆

---
.title2
# NO
---
.code
```php

function somemodule_somehook() {
  return array('someid' => array());
}

class HookDiscoveryTest extends PHPUnit_Framework_TestCase {
  function testGetDefinitions() {
    /** Setup goes here **/

    $discovery = new HookDiscovery('somehook');
    $expected = array(
      'someid' => array('module' => 'somemodule')
    );
    $this->assertEquals($expected, $discovery->getDefinitions());
  }
}
```
---
.code
```php
namespace Drupal\Core\Plugin\Discovery;

class HookDiscovery implements DiscoveryInterface {

  public function getDefinitions() {
    $definitions = array();
    $modules = module_implements($this->hook);
    foreach ($modules as $module) {
```
---
.code
```
PHP Fatal error:  Call to undefined function module_implements()
in core/lib/Drupal/Core/Plugin/Discovery/HookDiscovery.php
on line 48
```
---

.title2
# Untestable*
---
## **Functions**

### No autoload
### `require` pollutes test environment
### Unpredictable dependencies

# 🛀📻

---
.code
```diff
- $modules = module_implements($this->hook);
+ $modules = \Drupal::moduleHandler()
+              ->getImplementations($this->hook);
```
---
## Is code that uses \Drupal testable?

---
.code
```php
  function testGetDefinitions() {
    $module_handler = $this
      ->getMock('Drupal\Core\Extension\ModuleHandler');
    $module_handler->expects($this->once())
      ->method('getImplementations')
      ->with('somehook')
      ->will($this->returnValue(array('somemodule')));

    $container = new ContainerBuilder();
    $container->set('module_handler', $module_handler);
    \Drupal::setContainer($container);

```
---
.code
```
OK (1 test, 2 assertions)
```
---
.title2
# Testable,
# but painful

---

## **Replace singleton**
<!-- replace with "Replace singleton?"-->

### Autoload
### Non-object-under-test code running
### Must include setter
# 👨🔨

---
.code

```php
namespace Drupal\Core\Plugin\Discovery;

class HookDiscovery implements DiscoveryInterface {

  protected function moduleHandler() {
    if (!$this->moduleHandler) {
      $this->moduleHandler = \Drupal::moduleHandler();
    }
    return $this->moduleHandler;
  }

  public function getDefinitions() {
    $definitions = array();
    $modules = $this->moduleHandler()
                 ->getImplementations($this->hook);
    foreach ($modules as $module) {

  ```
---
.code
```php
class TestHookDiscovery extends HookDiscovery {
  function setTestModuleHandler($module_handler) {
    $this->moduleHandler = $module_handler;
  }
}

class HookDiscoveryTest extends PHPUnit_Framework_TestCase {
  function testGetDefinitions() {
    $module_handler = $this
      ->getMock('Drupal\Core\Extension\ModuleHandler');
    $module_handler->expects($this->once())
      ->method('getImplementations')
      ->with('somehook')
      ->will($this->returnValue(array('somemodule')));

    $discovery = new TestHookDiscovery('somehook');
    $discovery->setTestModuleHandler($module_handler);
```
---
.code
```
OK (1 test, 2 assertions)
```
---
.title2

# Testable

---
## **Local dependency accessor**

### Mocks via inheritance/test-only setter

# 👧🐶

---
.code
```php
namespace Drupal\Core\Plugin\Discovery;

class HookDiscovery implements DiscoveryInterface {

  function __construct($hook, $module_handler) {
    $this->hook = $hook;
    $this->moduleHandler = $module_handler;
  }

  public function getDefinitions() {
    $definitions = array();
    $modules = $this->moduleHandler
                 ->getImplementations($this->hook);
    foreach ($modules as $module) {

  ```
---
.code
```php
function testGetDefinitions() {
  $module_handler = $this
    ->getMock('Drupal\Core\Extension\ModuleHandler');
  $module_handler->expects($this->once())
    ->method('getImplementations')
    ->with('somehook')
    ->will($this->returnValue(array('somemodule')));

  $discovery = new HookDiscovery('somehook', $module_handler);
```
---
.code
```
OK (1 test, 2 assertions)
```
---
.title2

# Very testable

---
## **Constructor injection**

### Mocks via `new`
### Requires service definition
### or
### Factory method*
# 👮🍩🍩
---
.title2
# Which method should I use?
---
.title3
## 1. Constructor injection

### Default
### Domain collaborators
# 🙆

---
.title3
## 2. Test-only setter

### Dependencies with safe defaults
### Bloated constructor
# 🙋
---
.title3
## 3. Replace singleton

### Avoid
# 🙅
---
.fakequote
> But it takes so much work to setup my unit test!

<cite>People writing tests for poorly designed classes</cite>

---
.title3
## All dependencies are
## not created equal

---
.quote
> Elements are coupled if a change in one forces a change in the other…
> <br> An element’s cohesion is a measure of whether its responsibilities form a meaningful unit.

<cite>Freeman, Steve; Pryce, Nat (2009-10-12). Growing Object-Oriented Software, Guided by Tests</cite>

<!--
# Combine dependencies
---
## Inject optionally/setter
## Fallback to a safe default

---

# ModuleHandler
---
-->

---
.code
```php
class LocalTaskManager extends DefaultPluginManager {

  function __construct(ControllerResolverInterface $cr,
                        Request $request,
                        RouteProviderInterface $route_provider,
                        ModuleHandlerInterface $module_handler,
                        CacheBackendInterface $cache,
                        LanguageManager $language_manager,
                        AccessManager $access_manager) {

    $this->controllerResolver = $cr;
    $this->request = $request;
    $this->routeProvider = $route_provider;
    $this->accessManager = $access_manager;
    $this->alterInfo($module_handler, 'local_tasks');
    $this->setCacheBackend($cache,
                           $language_manager,'local_task',
                           array('local_task' => TRUE));
  }
```
---
.code
```php
class LocalTaskManager extends DefaultPluginManager {

  function __construct(
                        Request $request,
                        RouteProviderInterface $route_provider,



                        AccessManager $access_manager) {


    $this->request = $request;
    $this->routeProvider = $route_provider;
    $this->accessManager = $access_manager;




  }
```

---
.code
```php
class LocalTaskManager extends DefaultPluginManager {

  function __construct(


                        ModuleHandlerInterface $module_handler,


                                                     ) {





    $this->alterInfo($module_handler, 'local_tasks');



  }
```
---
.code
```php
  // DefaultPluginManager
  protected function findDefinitions() {
    $definitions = $this->discovery->getDefinitions();
    foreach ($definitions as $plugin_id => &$definition) {
      $this->processDefinition($definition, $plugin_id);
    }
    if ($this->alterHook) {
      $this->moduleHandler->alter($this->alterHook, $definitions);
    }
    return $definitions;
  }
```
---
.code
```php
  // DefaultPluginManager
  protected function findDefinitions() {
    $definitions = $this->discovery->getDefinitions();
    foreach ($definitions as $plugin_id => &$definition) {
      $this->processDefinition($definition, $plugin_id);
    }
    if ($this->event) {
      $this->events()->dispatch($this->event,
                                new PluginEvent($definitions);
    }
    return $definitions;
  }

  protected function events() {
    if (!$this->eventDispatcher) {
      $this->eventDispatcher = \Drupal::eventDispatcher();
    }
    return $this->eventDispatcher;
  }

```
---
.title2
# TDD
---
.quote
> We write our tests before we write the code. Instead of just using testing to verify our work after it’s done, TDD turns testing into a design activity. We use the tests to clarify our ideas about what we want the code to do.

<cite>Freeman, Steve; Pryce, Nat (2009-10-12). Growing Object-Oriented Software, Guided by Tests</cite>

---
.references
# References
- Steve Freeman and Nat Pryce, *Growing Object-Oriented Software, Guided by Tests*, 2009
- Gerard Meszaros, *xUnit Test Patterns: Refactoring Test Code*, 2007
- Steve Freeman, Tim Mackinnon, Nat Pryce, and Joe Walnes, *Mock roles, not objects OOPSLA '04*, 2004
- Sandi Metz, *Practical Object-Oriented Design in Ruby*, 2012

---
# THANKS
## 🐶🐺	🐱🐭	🐹	🐰	🐸	🐯	🐨	🐻

---
## **Questions?**

## Feedback:
### Locate this session at the DrupalCon Prague website:
#### http://prague2013.drupal.org/schedule
#### (Click the “Take the survey” link)
---

<!--
![goos](images/goos.jpg)
![xunit patterns](images/xunit.jpg)
-->


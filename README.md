# Debug Bar for Liferay 7.0.x
A freemarker script that helps you in writing freemarker templates or ADTs code. Not tested on liferay versions above the 7.0.x. For security purposes the debug bar is visible only to Omniadmin.

<img width="691" height="225" alt="image" src="https://github.com/user-attachments/assets/623fdae1-b1f8-4d9d-9675-efd6bbdaf813" />

# Available tabs

The bar appears in the bottom of the page and has the following tabs:

- Logs: to show messages produced by `logger()` function;
- Request: a dump of keys and values of the data in the request object;
- Session: keys and values of the session object
- Cookies: page cookies
- Data Model: keys and values of `.data_model` object;

The Data Model page use a modified code of the <a href="https://liferay.dev/b/the-magic-template-variable-dumper-script-for-liferay-7" target="_blank">Magic Template Variable Dumper</a>.

# Usage
1. Save this template as a Liferay template (name it `DEBUGBAR`, for example);

2. Include this file AT THE BEGINNING of your main template:
   ```ftl
   <#include "${templatesPath}/DEBUGBAR" />
   ```

4. Use the `logger()` function anywhere in the template to add logs:
   ```ftl
   ${logger("My log message", "info")}
   ```

   By default, `info` is set by default, so you can also write:
   ${logger("My log message")}
6. At the END of the template, call the macro to render the debug bar:
   ```ftl
   <@liferay_util["body-bottom"]>
     <@renderDebugBar />
   </@>
   ```

# EXAMPLE

```ftl
<#include "debug-bar.ftl" />

${logger("Starting template processing", "info")}

${logger("User: " + user.fullName, "success")}
    
    <h1>My Content</h1>
    
    <#if someCondition>
        ${logger("Condition verified", "info")}
    <#else>
        ${logger("Warning: condition not met", "warning")}
    </#if>

<@liferay_util["body-bottom"]>
    <@renderDebugBar />
</@>
```

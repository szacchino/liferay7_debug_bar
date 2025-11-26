# 🦜 Debug Bar for Liferay 7.0.x
A freemarker script that renders a Debug Bar (like <a href="https://github.com/php-debugbar/php-debugbar" target="_blank">PHP Debug Bar</a>) and helps you in writing freemarker templates' or ADTs' code, allowing you to display user's log message, request parameters, session attributes and a dump of `.data_model` object. Not tested on liferay versions above the 7.0.x. 

> [!IMPORTANT]
> For security purposes the debug bar is visible only to Omniadmin.

<img width="698" height="233" alt="how Liferay Debug Bar appears on screen" src="https://github.com/user-attachments/assets/1bb0c17e-8710-4187-975b-482a832662be" />

# Available tabs

The bar appears in the bottom of the page and has the following tabs:

- Logs: to show messages produced by `logger()` function;
- Request: a dump of keys and values of the data in the request object;
- Session: keys and values of the session object
- Cookies: page cookies
- Data Model: keys and values of `.data_model` object;

<img width="499" height="235" alt="The Logs tab of Liferay Debug Bar" src="https://github.com/user-attachments/assets/be6c3068-e4c5-437b-8e9a-3a8348f902f9" />

The Data Model page use a modified code of the <a href="https://liferay.dev/b/the-magic-template-variable-dumper-script-for-liferay-7" target="_blank">Magic Template Variable Dumper</a>.

# Usage
1. Save this template as a Liferay template (name it `DEBUGBAR`, for example, and let's say that `DEBUGBAR` is also the template's `templatekey`);

2. Include this file AT THE BEGINNING of your main template using the template's `templatekey`:
   ```ftl
   <#include "${templatesPath}/DEBUGBAR" />
   ```

4. Use the `logger()` function anywhere in the template to add logs:
   ```ftl
   ${logger("My log message", "info")}
   ```

   By default, `info` is set by default, so you can also write:
   ```ftl
   ${logger("My log message")}
   ```
6. At the END of the template, call the macro to render the debug bar:
   ```ftl
   <@liferay_util["body-bottom"]>
     <@renderDebugBar />
   </@>
   ```

# Example

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

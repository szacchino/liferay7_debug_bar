<#--
Debug Bar for Liferay 7.0.6

USAGE:

1. Include this file AT THE BEGINNING of your main template:
```ftl
<#include "debug-bar.ftl" />
```

2. Use the `logger()` function anywhere in the template to add logs:
   ```ftl
   ${logger("My log message", "info")}
   ```
   

3. At the END of the template, call the macro to render the debug bar:
   ```ftl
   <@liferay_util["body-bottom"]>
     <@renderDebugBar />
   </@>
   ```

EXAMPLE:

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
-->

<#-- ============================================================ -->
<#-- INIZIALIZZAZIONE VARIABILI                                   -->
<#-- ============================================================ -->

<#if !debugLogs??>
    <#assign debugLogs = [] />
</#if>

<#-- ============================================================ -->
<#-- FUNZIONE PER AGGIUNGERE LOG                                  -->
<#-- ============================================================ -->

<#function logger message level="info">
    <#local timestamp = .now?string("HH:mm:ss.SSS") />
    <#local logEntry = {
        "timestamp": timestamp,
        "level": level,
        "message": message
    } />
    <#assign debugLogs = debugLogs + [logEntry] />
    <#return "" />
</#function>

<#-- ============================================================ -->
<#-- MACRO PER RENDERIZZARE LA DEBUG BAR                          -->
<#-- Da chiamare alla fine del template: <@renderDebugBar />     -->
<#-- ============================================================ -->

<#macro renderDebugBar>
<#if !permissionChecker.isOmniadmin()>
    <#return>
</#if>
<#-- Recupera informazioni sulla request -->
<#local requestInfo = {
    "method": httpServletRequest.getMethod()!"N/A",
    "url": httpServletRequest.getRequestURL()!"N/A",
    "queryString": httpServletRequest.getQueryString()!"",
    "protocol": httpServletRequest.getProtocol()!"N/A",
    "remoteAddr": httpServletRequest.getRemoteAddr()!"N/A",
    "serverName": httpServletRequest.getServerName()!"N/A",
    "serverPort": httpServletRequest.getServerPort()?string!"N/A",
    "contextPath": httpServletRequest.getContextPath()!"N/A"
} />

<#-- Recupera parametri della request -->
<#local requestParams = {} />
<#if httpServletRequest.getParameterMap()??>
    <#local paramMap = httpServletRequest.getParameterMap() />
    <#list paramMap?keys as key>
        <#local values = paramMap[key] />
        <#if values?size == 1>
            <#local requestParams = requestParams + {key: values[0]} />
        <#else>
            <#local requestParams = requestParams + {key: values} />
        </#if>
    </#list>
</#if>

<#-- Recupera headers della request -->
<#local requestHeaders = {} />
<#if httpServletRequest.getHeaderNames()??>
    <#local headerNames = httpServletRequest.getHeaderNames() />
    <#list headerNames as headerName>
        <#local requestHeaders = requestHeaders + {headerName: httpServletRequest.getHeader(headerName)!""} />
    </#list>
</#if>

<#-- Recupera attributi di sessione -->
<#local sessionData = {} />
<#if httpServletRequest.getSession(false)??>
    <#local session = httpServletRequest.getSession(false) />
    <#local sessionAttrs = session.getAttributeNames() />
    <#list sessionAttrs as attrName>
        <#attempt>
            <#local attrValue = session.getAttribute(attrName) />
            <#local sessionData = sessionData + {attrName: attrValue?string} />
        <#recover>
            <#local sessionData = sessionData + {attrName: "[Complex Object]"} />
        </#attempt>
    </#list>
</#if>

<#-- Recupera cookies -->
<#local cookiesData = {} />
<#if httpServletRequest.getCookies()??>
    <#list httpServletRequest.getCookies() as cookie>
        <#local cookiesData = cookiesData + {cookie.getName(): cookie.getValue()} />
    </#list>
</#if>

<style>
    #liferay-debug-bar {
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        background: #1e1e1e;
        color: #d4d4d4;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 11px;
        z-index: 999999;
        box-shadow: 0 -2px 10px rgba(0,0,0,0.5);
        height: 300px;
        display: flex;
        flex-direction: column;
    }
    
    #liferay-debug-bar.minimized {
        height: 40px;
    }
    
    .debug-bar-resize-handle {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 6px;
        cursor: ns-resize;
        background: transparent;
        z-index: 10;
    }
    
    .debug-bar-resize-handle:hover {
        background: #569cd6;
    }
    
    .debug-bar-resize-handle::before {
        content: '';
        position: absolute;
        top: 2px;
        left: 50%;
        transform: translateX(-50%);
        width: 40px;
        height: 2px;
        background: #3e3e42;
        border-radius: 2px;
    }
    
    #liferay-debug-bar.resizing {
        user-select: none;
    }
    
    .debug-bar-header {
        background: #252526;
        padding: 0px 10px;
        border-bottom: 1px solid #3e3e42;
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-family: sans-serif;
    }
    
    .debug-bar-title {
        font-weight: bold;
        color: #569cd6;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .debug-bar-toggle {
        background: none;
        border: none;
        color: #d4d4d4;
        cursor: pointer;
        font-size: 12px;
        padding: 0;
        width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .debug-bar-toggle:hover {
        color: #569cd6;
    }
    
    .debug-bar-tabs {
        display: flex;
        background: #2d2d30;
        border-bottom: 1px solid #3e3e42;
    }
    
    .debug-bar-minimized .debug-bar-tabs,
    .debug-bar-minimized .debug-bar-content {
        display: none;
    }
    
    .debug-tab {
        padding: 2px 10px;
        cursor: pointer;
        border-right: 1px solid #3e3e42;
        transition: background 0.2s;
        font-family: sans-serif;
    }
    
    .debug-tab:hover {
        background: #37373d;
    }
    
    .debug-tab.active {
        background: #1e1e1e;
        color: #569cd6;
        border-bottom: 2px solid #569cd6;
    }
    
    .debug-bar-content {
        overflow-y: auto;
        flex: 1;
        padding: 5px;

        label {
            font-size: .9em !important;
            padding: 0 !important;
            margin: 0: !important;
            font-family: sans-serif;
        }
    }
    
    .debug-content-panel {
        display: none;
    }
    
    .debug-content-panel.active {
        display: block;
    }
    
    .debug-log-entry {
        padding: 5px 5px;
        border-left: 3px solid #858585;
        margin-bottom: 8px;
        background: #252526;
        border-radius: 3px;
    }
    
    .debug-log-entry.info {
        border-left-color: #569cd6;
    }
    
    .debug-log-entry.warning {
        border-left-color: #dcdcaa;
    }
    
    .debug-log-entry.error {
        border-left-color: #f48771;
    }
    
    .debug-log-entry.success {
        border-left-color: #4ec9b0;
    }
    
    .debug-log-timestamp {
        color: #d5d5d5ff;
        font-size: 11px;
        margin-right: 10px;
    }
    
    .debug-log-level {
        display: inline-block;
        padding: 2px 5px;
        border-radius: 3px;
        font-size: 10px;
        font-weight: bold;
        margin-right: 10px;
        text-transform: uppercase;
    }
    
    .debug-log-level.info {
        background: #264f78;
        color: #569cd6;
    }
    
    .debug-log-level.warning {
        background: #4d4d1a;
        color: #dcdcaa;
    }
    
    .debug-log-level.error {
        background: #5a1d1d;
        color: #f48771;
    }
    
    .debug-log-level.success {
        background: #1a4d3d;
        color: #4ec9b0;
    }
    
    .debug-table {
        width: 100%;
        border-collapse: collapse;
    }
    
    .debug-table th {
        background: #2d2d30;
        padding: 3px;
        text-align: left;
        border-bottom: 2px solid #3e3e42;
        color: #569cd6;
        font-weight: bold;
        font-family: sans-serif;
    }
    
    .debug-table td {
        padding: 3px;
        border-bottom: 1px solid #3e3e42;
        word-break: break-word;
    }
    
    .debug-table tr:hover {
        background: #2d2d30;
    }
    
    .debug-key {
        color: #9cdcfe;
        font-weight: bold;
        width: 30%;
    }
    
    .debug-value {
        color: #f2db96;
        width: 70%;
        strong {
            color: white;
        }
    }
    
    .debug-empty {
        color: #858585;
        font-style: italic;
        text-align: center;
        padding: 20px;
    }
    
    .debug-section-title {
        color: #569cd6;
        margin-top: 0px;
        margin-bottom: 10px;
        font-size: 12px;
        font-weight: bold;
        font-family: sans-serif;
    }
    
    .debug-section-title:first-child {
        margin-top: 0;
    }


    .searchInput {
        border: 0 !important;
        background-color: aliceblue !important;
        margin: 0 !important;
        font-size: 0.9em !important;
        padding: 2px !important;
        font-family: sans-serif;
    }

</style>

<div id="liferay-debug-bar">
    <div class="debug-bar-resize-handle" id="liferay-debug-resize-handle"></div>
    <div class="debug-bar-header" onclick="toggleLiferayDebugBar()">
        <div class="debug-bar-title">
            <span>🦜 Liferay Debug Bar</span>
            <span style="font-size: 11px; color: #858585;">v1.0</span>
        </div>
        <button class="debug-bar-toggle" id="liferay-debug-toggle-btn">▼</button>
    </div>
    
    <div class="debug-bar-tabs">
        <div class="debug-tab active" onclick="switchLiferayDebugTab('logs')">
            📝 Logs <span style="color: #858585;">(${debugLogs?size})</span>
        </div>
        <div class="debug-tab" onclick="switchLiferayDebugTab('request')">
            🌐 Request
        </div>
        <div class="debug-tab" onclick="switchLiferayDebugTab('session')">
            👤 Session <span style="color: #858585;">(${sessionData?size})</span>
        </div>
        <div class="debug-tab" onclick="switchLiferayDebugTab('cookies')">
            🍪 Cookies <span style="color: #858585;">(${cookiesData?size})</span>
        </div>
        <div class="debug-tab" onclick="switchLiferayDebugTab('datamodel')">
            𝒙 Data Model <span style="color: #858585;">(${.data_model?keys?size})</span>
        </div>
    </div>
    
    <div class="debug-bar-content">
        <!-- Logs Panel -->
        <div id="liferay-logs-panel" class="debug-content-panel active">
            <#if debugLogs?size == 0>
                <div class="debug-empty">
                    Nessun log disponibile.<br>
                    Usa <code>logger("messaggio", "livello")</code> per aggiungere log.<br>
                    Livelli disponibili: info, success, warning, error
                </div>
            <#else>
                <label>Filtro:</label>&nbsp;<input type="text" class="searchInput" oninput="searchTable(this, 'liferay-logs-panel', 'debug-log-entry')"><br>
                <#list debugLogs as log>
                    <div class="debug-log-entry ${log.level}">
                        <span class="debug-log-timestamp">${log.timestamp}</span>
                        <span class="debug-log-level ${log.level}">${log.level}</span>
                        <span class="debug-log-message">${log.message}</span>
                    </div>
                </#list>
            </#if>
        </div>
        
        <!-- Request Panel -->
        <div id="liferay-request-panel" class="debug-content-panel">
            <label>Filtro:</label>&nbsp;<input type="text" class="searchInput" oninput="searchTable(this, 'liferay-request-panel', 'debug-tr')"><br>
            <div class="debug-section-title">Informazioni Request</div>
            <table class="debug-table">
                <thead>
                    <tr>
                        <th>Chiave</th>
                        <th>Valore</th>
                    </tr>
                </thead>
                <tbody>
                    <#list requestInfo?keys?sort as key>
                        <tr class="debug-tr">
                            <td class="debug-key">${key}</td>
                            <td class="debug-value">${requestInfo[key]}</td>
                        </tr>
                    </#list>
                </tbody>
            </table>
            
            <div class="debug-section-title">Parametri Request</div>
            <#if requestParams?size == 0>
                <div class="debug-empty">Nessun parametro nella request</div>
            <#else>
                <table class="debug-table">
                    <thead>
                        <tr>
                            <th>Parametro</th>
                            <th>Valore</th>
                        </tr>
                    </thead>
                    <tbody>
                        <#list requestParams?keys?sort as key>
                            <tr class="debug-tr">
                                <td class="debug-key">${key}</td>
                                <td class="debug-value">${requestParams[key]?string}</td>
                            </tr>
                        </#list>
                    </tbody>
                </table>
            </#if>
            
            <div class="debug-section-title">Headers Request</div>
            <table class="debug-table">
                <thead>
                    <tr>
                        <th>Header</th>
                        <th>Valore</th>
                    </tr>
                </thead>
                <tbody>
                    <#list requestHeaders?keys?sort as key>
                        <tr class="debug-tr">
                            <td class="debug-key">${key}</td>
                            <td class="debug-value">${requestHeaders[key]}</td>
                        </tr>
                    </#list>
                </tbody>
            </table>
        </div>
        
        <!-- Session Panel -->
        <div id="liferay-session-panel" class="debug-content-panel">
            <div class="debug-section-title">Dati di Sessione</div>
            <#if sessionData?size == 0>
                <div class="debug-empty">Nessun dato in sessione</div>
            <#else>
                <label>Filtro:</label>&nbsp;<input type="text" class="searchInput" oninput="searchTable(this, 'liferay-session-panel', 'debug-tr')"><br>
                <table class="debug-table">
                    <thead>
                        <tr>
                            <th>Attributo</th>
                            <th>Valore</th>
                        </tr>
                    </thead>
                    <tbody>
                        <#list sessionData?keys?sort as key>
                            <tr class="debug-tr">
                                <td class="debug-key">${key}</td>
                                <td class="debug-value">${sessionData[key]}</td>
                            </tr>
                        </#list>
                    </tbody>
                </table>
            </#if>
        </div>
        
        <!-- Cookies Panel -->
        <div id="liferay-cookies-panel" class="debug-content-panel">
            <div class="debug-section-title">Cookies</div>
            <#if cookiesData?size == 0>
                <div class="debug-empty">Nessun cookie disponibile</div>
            <#else>
                <label>Filtro:</label>&nbsp;<input type="text" class="searchInput" oninput="searchTable(this, 'liferay-cookies-panel', 'debug-tr')"><br>
                <table class="debug-table">
                    <thead>
                        <tr>
                            <th>Nome</th>
                            <th>Valore</th>
                        </tr>
                    </thead>
                    <tbody>
                        <#list cookiesData?keys?sort as key>
                            <tr class="debug-tr">
                                <td class="debug-key">${key}</td>
                                <td class="debug-value">${cookiesData[key]}</td>
                            </tr>
                        </#list>
                    </tbody>
                </table>
            </#if>
        </div>

        <!-- Data Model Panel -->
        <div id="liferay-datamodel-panel" class="debug-content-panel">
            <div class="debug-section-title">Data Model</div>
            <#if .data_model?keys?size == 0>
                <div class="debug-empty">Nessuna variabile Liferay disponibile</div>
            <#else>
                <label>Filtro:</label>&nbsp;<input type="text" class="searchInput" oninput="searchTable(this, 'liferay-datamodel-panel', 'debug-tr')"><br>
                <table class="debug-table">
                    <thead>
                        <tr>
                            <th>Nome</th>
                            <th>Valore</th>
                        </tr>
                    </thead>
                    <tbody>
                        <#list .data_model?keys?sort as key>
                            <tr class="debug-tr">
                                <td class="debug-key">${key}</td>
                                <#if key?index_of("writer") lt 0>
                                    <td class="debug-value"><@dump key, .data_model[key] /></td>
                                </#if>
                            </tr>
                        </#list>
                    </tbody>
                </table>
            </#if>
        </div>
    </div>
</div>


<script id="__us_debugbar_script">
    /* Resize functionality */
    (function() {
        var debugBar = document.getElementById('liferay-debug-bar');
        var resizeHandle = document.getElementById('liferay-debug-resize-handle');
        var isResizing = false;
        var startY = 0;
        var startHeight = 0;
        
        resizeHandle.addEventListener('mousedown', function(e) {
            isResizing = true;
            startY = e.clientY;
            startHeight = debugBar.offsetHeight;
            debugBar.classList.add('resizing');
            e.preventDefault();
        });
        
        document.addEventListener('mousemove', function(e) {
            if (!isResizing) return;
            
            var deltaY = startY - e.clientY;
            var newHeight = startHeight + deltaY;
            
            /* Limiti min e max */
            if (newHeight < 100) newHeight = 100;
            if (newHeight > window.innerHeight - 50) newHeight = window.innerHeight - 50;
            
            debugBar.style.height = newHeight + 'px';
        });
        
        document.addEventListener('mouseup', function() {
            if (isResizing) {
                isResizing = false;
                debugBar.classList.remove('resizing');
            }
        });
    })();
    
    function toggleLiferayDebugBar() {
        var debugBar = document.getElementById('liferay-debug-bar');
        var toggleBtn = document.getElementById('liferay-debug-toggle-btn');
        
        if (debugBar.classList.contains('minimized')) {
            debugBar.classList.remove('minimized');
            toggleBtn.textContent = '▼';
        } else {
            debugBar.classList.add('minimized');
            toggleBtn.textContent = '▲';
        }
    }
    
    function switchLiferayDebugTab(tabName) {
        /* Nascondi tutti i pannelli */
        var panels = document.querySelectorAll('#liferay-debug-bar .debug-content-panel');
        panels.forEach(function(panel) {
            panel.classList.remove('active');
        });
        
        /* Rimuovi classe active da tutti i tab */
        var tabs = document.querySelectorAll('#liferay-debug-bar .debug-tab');
        tabs.forEach(function(tab) {
            tab.classList.remove('active');
        });
        
        /* Mostra il pannello selezionato */
        document.getElementById('liferay-' + tabName + '-panel').classList.add('active');
        
        /* Aggiungi classe active al tab selezionato */
        event.target.closest('.debug-tab').classList.add('active');
    }

    function searchTable(textinput, elemId, classId) {
      const input = textinput.value.toLowerCase();
      const cells = document.querySelectorAll(${r"`#${elemId} .${classId}`"});
      cells.forEach(cell => {
        cell.style.display = cell.textContent.toLowerCase().includes(input) ? '' : 'none';
      })
    }
</script>

</#macro>

<#assign maxdepth = 2>
<#assign black_list = ["class", "request", "downloadURL", "getDownloadURL", "getreader", "getinputstream", "writer"] />

<#macro dump key data>
    <#if data?is_enumerable>
        <@printList data, [], 0 />
    <#elseif data?is_hash_ex>
        <@printHashEx data,[] />
    <#else>
        <@printItem data!,[], key, false, 0 />
    </#if>
</#macro>

<#macro printList list has_next_array depth>
  <#local counter=0 />
[<#list list as item>
<@printItem item!"unk",has_next_array+[item_has_next], counter, false, depth />,&nbsp;
<#local counter = counter + 1/>
</#list>]
</#macro>

<#macro printJson hash level>
    <#local tabs = "">
    <#list 0..level as dt>
        <#local tabs = tabs + "&nbsp;&nbsp;">
    </#list>
    <#if hash?is_hash_ex>
        <#if hash?keys?seq_contains("getClass") && hash.class.name == "org.json.JSONObject">
            ${tabs}{<br>
            <#list hash.keys() as key>
                ${tabs}&nbsp;&nbsp;"${key}:"&nbsp;<@printJson hash.get(key), level+1 />
            </#list>
            ${tabs}}<br>
        <#elseif hash?keys?seq_contains("getClass") && hash.class.name == "org.json.JSONArray">
            ${tabs}[<br>
            <#list hash as key>
                ${key},&nbsp;
            </#list>
            ${tabs}]<br>
        </#if>
    <#else>
        <@printItem hash!,[], "", false, 0 />
    </#if>
</#macro>

<#macro printHashEx hash has_next_array>
<#if hash?keys?seq_contains("getClass") && hash.class.name == "org.json.JSONObject">
    <#--  <@printJson hash, 0 />  -->
    ${hash.toString(2)?replace("\n","<br>")?replace(" ","&nbsp;")}
<#else>
<strong>Callable methods:&nbsp;</strong>
<#list hash?keys?sort as key>
${key}&nbsp;|&nbsp;
</#list>
</#if>
</#macro>

<#macro printHashExFull hash has_next_array depth>
(hash+)
  <#list hash?keys as key>
    <#list has_next_array+[true] as has_next><#if !has_next>&nbsp;&nbsp;&nbsp;&nbsp;<#else>&nbsp;&nbsp;|&nbsp;</#if></#list>
    <#list has_next_array as has_next><#if !has_next>&nbsp;&nbsp;&nbsp;&nbsp;<#else>&nbsp;&nbsp;|&nbsp;</#if></#list><#t>
    <#t><@printItem hash[key]!,has_next_array+[key_has_next], key, true, depth />
  </#list>
</#macro>

<#macro printItem item has_next_array key full depth>
    <#if (depth gt maxdepth) >
        <#return>
    </#if>
    <#assign tabs = "">
    <#if depth gt 0>
        <#list 0..depth as dt>
            <#assign tabs = tabs + "&nbsp;&nbsp;">
        </#list>
        <#assign tabs = tabs + "+-&nbsp;">
    </#if>
    <#if depth gt 0>${tabs}|<br></#if>
        <#attempt>
            <#if item?is_method>
${tabs}= ?? (method)
            <#elseif item?is_enumerable>
${tabs}[<@printList item, has_next_array, depth+1 />]
  <#elseif item?is_hash_ex && omit(key?string)><#-- omit bean-wrapped java.lang.Class objects -->
${tabs}<b>(map)</b> (omitted)
  <#elseif item?is_hash_ex>
${tabs}<b>(map)</b>
    <#if full>
      <@printHashExFull item, has_next_array, depth+1 /><#t>
    <#else>
      <@printHashEx item, has_next_array /><#t>
    </#if>
  <#elseif item?is_number>
${tabs}<code>${item}</code>
  <#elseif item?is_string>
${tabs}<code>"${item}"</code>
  <#elseif item?is_boolean>
${tabs}<b>(boolean)</b> <code>${item?string}</code>
  <#elseif item?is_date>
${tabs}<b>(date)</b> <code>${item?string("yyyy-MM-dd HH:mm:ss zzzz")}</code>
  <#elseif item?is_transform>
${tabs}?? (transform)
  <#elseif item?is_macro>
${tabs}?? (macro)
  <#elseif item?is_hash>
${tabs}?? (hash)
  <#elseif item?is_node>
${tabs}?? (node)
  </#if>
<#recover>
${tabs}###
</#attempt>
</#macro>

<#function omit key>
  <#local what = key?lower_case>
  <#list black_list as item>
    <#if what?index_of(item) gte 0>
      <#return true>
    </#if>
  </#list>
  <#return false>
</#function>

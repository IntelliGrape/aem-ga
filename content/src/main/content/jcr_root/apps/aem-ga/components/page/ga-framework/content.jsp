<%@page session="false"%><%--
  Copyright 1997-2009 Day Management AG
  Barfuesserplatz 6, 4001 Basel, Switzerland
  All Rights Reserved.

  This software is the confidential and proprietary information of
  Day Management AG, ("Confidential Information"). You shall not
  disclose such Confidential Information and shall use it only in
  accordance with the terms of the license agreement you entered into
  with Day.

  ==============================================================================



--%><%@page session="false" 
			contentType="text/html"
            pageEncoding="utf-8"
            import="org.apache.sling.api.resource.Resource"%><%
%><%@taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><cq:defineObjects/>
<div id='CQ'> <!-- Create CQ div first, so tabs render on top -->
    <div id="CqScTabs" style="float:left; width:55%;">
    <div id="topPanel"></div>
        <script type="text/javascript">
            var rsidVarNames = {};
            var provider = {
                map: { },

                onAvailable: function(key, callback, scope, options) {
                    this.generateEntry(key);
                    var entry = this.map[key];
                    entry.obs.on('change', callback, scope, options);
                    if (entry.value != null)
                        entry.obs.fireEvent('change', entry.value, null);
                },

                unAvailable: function(key, callback, scope, options) {
                    var entry = this.map[key];
                    if (entry) {
                        entry.obs.un('change', callback, scope, options);
                    }
                },

                getValue: function(key) {
                    var entry = this.map[key];
                    return entry ? entry.value : null;
                },

                setValue: function(key, value) {
                    this.generateEntry(key);
                    var entry = this.map[key];
                    var oldValue = entry.value;
                    entry.value = value;
                    entry.obs.fireEvent('change', value, oldValue);
                },

                generateEntry: function(key) {
                    if (this.map[key]) {
                        return true;
                    } else {
                        entry = {
                            value: null,
                            obs: new CQ.Ext.util.Observable()
                        };
                        entry.obs.addEvents({
                            change: true
                        });
                        this.map[key] = entry;
                        return false;
                    }
                }
            };
            
            var variableMappingsStore = new CQ.Ext.data.JsonStore({
                mode: "local",
                fields: [{
                    name: "gaVar",
                    type: "string"
                }, {
                    name: "componentName",
                    type: "string"
                }, {
                    name: "componentIcon",
                    type: "string"
                }, {
                    name: "componentFrameworkPath",
                    type: "string"
                }, {
                    name: "cqVar",
                    type: "string"
                }]
            });
            var jsonStore = { };
            // TODO use same function in cqmappings
            var getShortScVar = function(scVar, arr) {
                var title = '';
                if (typeof arr != 'undefined' && typeof arr.length != 'undefined' && arr.length > 0) {
                    title = arr[0].name;
                    if (arr.length > 1)
                        title += '...';
                }
                return title + " (" + scVar + ")";
            };
            variableMappingsStore.on('load', function(store, records, options) {
                provider.onAvailable("gaVariables", function(variables) {
                    var mappingData = { };
                    CQ.Ext.each(records, function(item) {
                        var gaVar = item.get('gaVar');
                        if (gaVar) {
                            if (!mappingData[gaVar])
                                mappingData[gaVar] = [];
                            mappingData[gaVar].push(item);
                        }
                    });
                    CQ.Ext.each(variables, function(variable) {
                        var gaVar = variable.name;
                        var type = variable.type;
                        var varData = {
                            names: []
                        };
                        try {
                            varData.names = CQ.Ext.util.JSON.decode(variable.title);
                        } catch (e) {
                            console.log(e);
                        }
                        var store = jsonStore[type];
                        var shortScVar = getShortScVar(gaVar, varData.names);
                        if (store) {
                            var baseRec = {
                                gaVar: gaVar,
                                title: shortScVar
                            };
                            var dataArray = mappingData[gaVar];
                            if (dataArray) {
                                CQ.Ext.each(dataArray, function(data) {
                                    var rec = { };
                                    for (var idx in baseRec)
                                        rec[idx] = baseRec[idx];
                                    data.fields.each(function(recordField) {
                                        var fieldName = recordField.name;
                                        if (!(fieldName in rec))
                                            rec[fieldName] = data.get(fieldName);
                                    });
                                    conflictManager.addVariable(gaVar, rec.cqVar, rec.componentName, varData);
                                    store.push(rec);
                                });
                            } else {
                                conflictManager.addNewVariable(gaVar, varData);
                                store.push(baseRec);
                            }
                        }
                        else {
                            rsidVarNames[gaVar] = varData.names;
                        }
                    });
                }, this, { single: true });
            });

            var path = "<%= xssAPI.encodeForJSString(currentPage.getPath()) %>";
            var variablesUrl = '/bin/getDimensions';
            variablesUrl = CQ.HTTP.addParameter(variablesUrl, "resourcePath", path);
            variablesUrl = CQ.HTTP.externalize(variablesUrl);
            CQ.HTTP.get(variablesUrl,
                function(options, success, response) {
                    var variables;
                    if (success) {
                        try {
                            var jsonObj = CQ.HTTP.eval(response);
                            if (jsonObj)
                                variables = jsonObj.all;
                        } catch (e) {
                            CQ.Ext.Msg.alert(CQ.I18n.getMessage("Error"),
                                CQ.I18n.getMessage("Unable to parse Analytics variables"));
                        }
                    } else {
                        CQ.Ext.Msg.alert(CQ.I18n.getMessage("Error"),
                            CQ.I18n.getMessage("Unable to load Analytics variables"));
                    }
                    provider.setValue("gaVariables", variables || []);
                   });

            var conflictManager = new CQ.analytics.ConflictManager({
                provider: provider
            });
        </script>
        <div id="tabsHeader"></div>   
        <div id="tabContent"> 
        <%@include file="cqview.jsp"%>
        </div>
    </div>
    <div id='RightSide' style="float:left; width:300px; margin:0px 0px 0px 20px;">
        <script type="text/javascript">            
            CQ.Ext.onReady(function() {
                // remove CF and Sidekick when navigating to welcome page
                $CQ("a.home").on('click', function() { window.top.location=this.href; });
        </script>
    </div>
</div>

<%--

  GA-mapping component.

  This component renders all components which have analytics node

--%><%
%>
<%@page session="false" 
			contentType="text/html"
            pageEncoding="utf-8"
            import="javax.jcr.Node,
                    com.day.cq.wcm.api.WCMMode,
                    org.apache.sling.api.resource.Resource"%><%
%><%@include file="/libs/foundation/global.jsp"%><%

	String divForMappingsGrid = "div-" + resource.getPath();
	String componentPath = properties.get("cq:componentPath", "");
	String componentTag = componentPath.replace('/', '-');
	String componentName = properties.get("cq:componentName", "");
	String componentIcon = properties.get("cq:componentIcon", "");

%>
<div id="<%= xssAPI.encodeForHTMLAttr(divForMappingsGrid) %>"></div>
<style type="text/css">
/* Override height */
#CQ .taglabel { padding: 0px !important;  margin: 0px 1px 1px 0px !important;}
#CQ .taglabel td.taglabel-tool-cell { height: auto !important;}
#CQ .taglabel .no-parentpath { font-size: 11px;}
#CQ .x-grid3-col-1 { padding: 0px !important;  margin: 0px !important;}
#CQ .x-tip .x-tip-header-text {
    font: 11px tahoma,arial,helvetica,sans-serif;
    color:#444; 
} 
#cq .x-grid3-cell-first { height: 24px !important;}
.<%=componentTag%>-icon { background: url(<%=componentIcon%>) no-repeat !important; }
.<%=componentTag%>-lock-icon { background: url(<%= request.getContextPath() %>/libs/cq/ui/widgets/themes/default/icons/16x16/lock.png) no-repeat !important; cursor: pointer;}
</style> 
<script type="text/javascript">
    CQ.Ext.onReady(function() {
        var url = CQ.HTTP.addParameter("/bin/servlets/GAComponents", "componentPath", "<%= xssAPI.encodeForJSString(componentPath) %>");
        url = CQ.HTTP.addParameter(url, "resourcePath", "<%= xssAPI.encodeForJSString(resource.getPath()) %>");
        url = CQ.HTTP.addParameter(url, "_charset_", "utf-8");
        url = CQ.shared.HTTP.externalize(url);

        var mappingstore = new CQ.Ext.data.JsonStore({
            "url": url,
            "root": "",
            "fields": [{
                name: "cqVar",
                type: "string"
            },{
                name: "gaVar",
                type: "array"
            }],
            "listeners":{
                "beforeload":function(store, options) {
                },
                "load":function(store, records, options) {
                },
                "loadexception": function(proxy, options, response) {
                }
            }
        });
        mappingstore.on('load', function(store, records, options) {
            CQ.Ext.each(records, function(record) {
                var gaVarList = record.get('gaVar');
                var cqVar = record.get('cqVar');
                CQ.Ext.each(gaVarList, function(gaVar) {
                    var varData = {
                        names: rsidVarNames[gaVar]
                    };
                    conflictManager.addVariable(gaVar, cqVar, "<%= xssAPI.encodeForJSString(componentName) %>", varData);
                });
            });
            var value = provider.getValue("numMappingStoresLoaded") || 0;
            provider.setValue("numMappingStoresLoaded", value + 1);
        }, this, { single: true });

        // Revision 90901 escapes cell content to guard against XSS; reverting to original tpl to render tags
        CQ.Ext.override(CQ.Ext.grid.GridView, {
            cellTpl: new CQ.Ext.XTemplate(
                   '<td class="x-grid3-col x-grid3-cell x-grid3-td-{id} {css}" style="{style}" tabIndex="0" {cellAttr}>',
                   '<div class="x-grid3-cell-inner x-grid3-col-{id}" unselectable="on" {attr}>{value}</div>',
               '</td>'
            )});
        var cqMappings = new CQ.Ext.grid.EditorGridPanel({            
            viewConfig: {
                forceFit: true
            },
            cls: 'variablegrid',
            autoHeight: true,
            store: mappingstore,
            loadMask:{
                msg:CQ.I18n.getMessage("Loading configuration...")
            },
            listeners: {
                columnresize: function(colIdx,newSize) {
                    var grids = CQ.analytics.SiteCatalyst.getMappings(cqMappings);
                    for(var i=0; i<grids.length; i++) {
                        if(grids[i] instanceof CQ.Ext.grid.GridPanel) {
                            grids[i].getColumnModel().setColumnWidth(colIdx, newSize, false);
                            grids[i].doLayout();
                        }
                    }
                }
            },
            cm: new CQ.Ext.grid.ColumnModel([
                {
                    dataIndex: 'cqVar',
                    header: CQ.I18n.getMessage('CQ variable'),
                    sortable: true,
                    resizeable: true,
                    width: '210',
                    renderer: function(value, metaData, record, rowIndex, colIndex, store) {
                        return value;
                    }
                },
                {
                    dataIndex: 'gaVar',
                    header: CQ.I18n.getMessage('Google Analytics variable(s)'),
                    sortable: true,
                    resizeable: true,
                    width: '490',
                    warningIconPath: '<%= request.getContextPath() %>/libs/cq/ui/widgets/themes/default/icons/16x16/warning.png',
                    createLabel: function(title, value, record, names) {
                        var id = CQ.Ext.id();
                        (function(){
                            var tagLabel = new CQ.tagging.TagLabel({
                                renderTo: id,
                                text: title,
                                embedTextAsHTML: true,
                                varValue: value,
                                recordRef: record,
                                iconClickHandler: function() {
                                    var tip = this.tip;
                                    if (tip) {
                                        tip.show();
                                        tip.autoHide = false;
                                        var close = tip.tools.close;
                                        if (close) {
                                            close.show();
                                        }
                                    }
                                }
                            <%if (WCMMode.EDIT.equals(request.getAttribute(WCMMode.REQUEST_ATTRIBUTE_NAME))) {%>,
                                listeners: {
                                    remove: function() {
                                        var rec = this.recordRef;
                                        var arr = rec.get('gaVar');
                                        arr.remove(this.varValue);
                                        rec.set('gaVar',arr);
                                        rec.commit();
                                        // save the mapping
                                        var delta = {};
                                        delta[this.varValue+ "@Delete"] = ' '; //TODO: if parent framework or baseline component does not set this var, should remove property rather than set to ''
                                        CQ.HTTP.post(
                                                "<%= xssAPI.encodeForJSString(resource.getPath()) %>",
                                                function(options, success, response) {
                                                    if (success) {
                                                        conflictManager.loadConflicts(this.varValue);
                                                    } else {
                                                        //TODO: put tag back
                                                        CQ.Notification.notify(null, 'Could not remove mapping');
                                                    }
                                                },
                                                delta, this
                                            );
                                        
                                        this.destroy();
                                    }
                                }
                            <% } else { %>,
                                readOnly: true
                            <% } %>
                            });
                            tagLabel.conflictIcon = tagLabel.getEl().child("img");
                            if (tagLabel.tip) {
                                tagLabel.tip.destroy();
                                tagLabel.tip = null;
                            }
                            provider.onAvailable("mappingConflict." + value, function(conflict) {
                                var conflictIcon = tagLabel.conflictIcon;
                                if (conflictIcon.isVisible())
                                    conflictIcon.un('click', tagLabel.iconClickHandler, tagLabel);
                                if (tagLabel.tip) {
                                    tagLabel.tip.destroy();
                                    tagLabel.tip = null;
                                }
                                if (!conflict || conflict.length <= 0) {
                                    conflictIcon.hide();
                                    return;
                                }
                                tagLabel.tip = new CQ.Ext.ToolTip({
                                    target: tagLabel.getEl().child(".taglabel-body"),
                                    dismissDelay: 0,
                                    width: 410,
                                    closable: true,
                                    listeners: {
                                        show: function() {
                                            this.autoHide = true;
                                            var close = this.tools.close;
                                            if (close) {
                                                close.hide();
                                            }
                                        }
                                    },
                                    title: conflict[0],
                                    html: conflict.slice(1).join("<br>")
                                });
                                conflictIcon.on('click', tagLabel.iconClickHandler, tagLabel);
                                conflictIcon.show();
                            });
                        }).defer(25);
                        return (String.format('<div id="{0}"></div>', id));
                    },
                    renderer: function(value, metaData, record, rowIndex, colIndex, store) {
                        if(CQ.Ext.isArray(value) && value.length > 0) {
                            var labels="";
                            for(var i=0; i<value.length; i++){
                                var arr = rsidVarNames[value[i]];
                                var label = getShortScVar(value[i], arr);
                                var imgTag = String.format("<img src='{0}' style='visibility: hidden;'/>",
                                    this.warningIconPath);
                                label = "<table cellpadding=0 cellspacing=0 style='border: none' ><tr><td align=center valign=middle style='padding: 0px'>" + label + "</td><td align=center valign=middle style='padding: 0px'>" + imgTag + "</td></tr></table>";
                                labels += this.createLabel(label, value[i], record, arr);
                            }
                            return labels;
                        }
                    }             
                }
            ])
        });
        var cqPanelItems = [];
        if (mappingSet.dummyPanel) {
            cqPanelItems.push(mappingSet.dummyPanel);
            delete mappingSet.dummyPanel;
        }
        cqPanelItems.push(cqMappings);

		//Stateful panel
        CQ.Ext.state.Manager.setProvider(new CQ.Ext.state.CookieProvider());
        var cqPanel = new CQ.Ext.Panel({
            iconCls: '<%= xssAPI.encodeForJSString(componentTag) %>-icon',
            title: CQ.I18n.getMessage('<b><%=componentName%></b>') + ' (<%=componentPath%>)', //TODO: only show path if there is ambiguity
            renderTo: '<%= xssAPI.encodeForJSString(divForMappingsGrid) %>',
            inherited: <%= !WCMMode.EDIT.equals(request.getAttribute(WCMMode.REQUEST_ATTRIBUTE_NAME)) %>,
            collapsible: true,
            stateful: true,
            stateId: '<%= xssAPI.encodeForJSString(componentName) %>',
            stateEvents: ['expand','collapse'],
            getState: function() {
              return {
                 collapsed: this.collapsed
              };
            },
            items: cqPanelItems
        });
        var resourcePath = "<%= xssAPI.encodeForJSString(resource.getPath()) %>";
        mappingSet.grids[resourcePath] = cqMappings;
        if (!mappingSet.panels["<%= componentPath %>"]) {
            mappingSet.panels["<%= componentPath %>"] = cqPanel;
        } else {
            mappingSet.panels["<%= componentPath %>"].hide();
        }
        <%if (WCMMode.EDIT.equals(request.getAttribute(WCMMode.REQUEST_ATTRIBUTE_NAME))) {%>
        cqMappings.getDropTargets = function() {
            var col = 1;
            var dt = [];
            var grid = this;
            var gridStore = this.getStore();
            var gridView = this.getView();

            for(var row=0; row<gridStore.getTotalCount(); row++) {
                var dd = new CQ.Ext.dd.DropTarget(gridView.getCell(row,col),{
                    ddGroup: "googleanalyticsVars",
                    store: gridStore,
                    view: gridView,
                    normalize: function(){},
                    flash: function() {},
                    notifyDrop: function(dd, e, data){
                            var rowIndex = this.view.findRowIndex(this.el.dom);
                            var columnIndex = this.view.findCellIndex(this.el.dom);
                            if ((rowIndex !== false) && (columnIndex !== false)) {
                                var rec = this.store.getAt(rowIndex);
                                if(rec) {
                                    var arr = rec.get('gaVar');
                                    var dropData = data.records[0].data;
                                    if(arr.indexOf(dropData.idName) == -1){
                                        arr.push(dropData.idName);
                                        // save the mapping
                                        var delta = {};
                                        delta[dropData.idName] = rec.get('cqVar');
                                        CQ.HTTP.post(
                                                "<%= xssAPI.encodeForJSString(resource.getPath()) %>",
                                                function(options, success, response) {
                                                    if (success) {
                                                        conflictManager.loadConflicts(dropData.name);
                                                    } else {
                                                        //TODO: remove tag
                                                        CQ.Notification.notify(null, 'Could not save mapping');
                                                    }
                                                },
                                                delta
                                            );
                                    }
                                    rec.set('gaVar', arr);
                                    rec.commit();
                                }
                        }                       
                    }
                });
                dt.push(dd);
            }
            return dt;
        };
        <% } else { %>
            cqPanel.setIconClass('<%= xssAPI.encodeForJSString(componentTag) %>-lock-icon');
            $CQ(".<%= xssAPI.encodeForJSString(componentTag) %>-lock-icon").each(function(index, item) {
                var nodePath = "'<%= xssAPI.encodeForJSString(resource.getPath()) %>'";
                var pagePath = "'<%= xssAPI.encodeForJSString(currentPage.getPath()) %>'";
                var handler = "CQ.analytics.SiteCatalystPanel.statics.unlockComponent";
                handler += String.format("({0})", [ pagePath, nodePath ].join(', '));
                item.setAttribute('ondblclick', handler);
                new CQ.Ext.ToolTip({
                    target: item,
                    dismissDelay: 0,
                    width: 305,
                    title: "Double-click to overwrite inherited tracking rules for this component"
                });
            });
        <% } %>
    
        /* load store when data is ready, so we can fetch 'nice' variable names */
        var store;
        var cf = CQ.WCM.getContentFinder();
        if (cf) {
			var cfTab = cf.findById("cfTab-gaAllVars");
        }
		if (cfTab && cfTab.dataView) {
		    store = cfTab.dataView.store;
		}

        if (store) {    
            //is store loaded
            if(store && store.getTotalCount() > 0) {
                cqMappings.getStore().load();
            } else {
                store.on('load', function(){
                    cqMappings.getStore().load();
                });
                store.on('exception', function(proxy,type,action,options,response,args){
                    cqMappings.getStore().load();
                });
            }
        } else {
            cqMappings.getStore().load();
        }
        
        CQ.analytics.SiteCatalyst.registerMapping(cqMappings);
        CQ.WCM.registerDropTargetComponent(cqMappings);
    });
</script>
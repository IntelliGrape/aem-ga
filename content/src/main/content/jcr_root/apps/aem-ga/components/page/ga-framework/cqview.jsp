<%--
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
            import="javax.jcr.Node,
                    org.apache.sling.api.resource.Resource"%><%
%><%@taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><cq:defineObjects/>
<script type="text/javascript">
	// Change the Edit button text for framework edit bar
	CQ.Ext.override(CQ.wcm.EditBar, {
	    _initI18n: CQ.wcm.EditBase.initI18n,
	    
	    initI18n: function(config) {
	        this._initI18n(config);
	        this.editText = CQ.I18n.getMessage("Configure inheritance");
	    }
	});
    // Transform any component dropped onto maparsys into cqmappings
    CQ.Ext.override(CQ.wcm.EditRollover, {
        _constructorEnd: CQ.wcm.EditBase.constructorEnd,
        _createParagraph: CQ.wcm.EditBase.createParagraph,
        _buildElement: CQ.wcm.EditRollover.prototype.buildElement,

        constructorEnd: function(config) {
            this._constructorEnd(config);
            this.on(CQ.wcm.EditBase.EVENT_BEFORE_DELETE, function(item) {
                var component = CQ.HTTP.eval(item.path + ".json");
                if (component)
                    item.componentPath = component["cq:componentPath"];
            });
            this.on(CQ.wcm.EditBase.EVENT_AFTER_DELETE, function(item) {
                if (item.componentPath) {
                    var cqPanel = mappingSet.panels[item.componentPath];
                    if (cqPanel && cqPanel.inherited) {
                        var cqInherited = $CQ("#cq-inherited-frameworks");
                        cqInherited.show();
                        cqInherited.children().show();
                        cqPanel.show();
                    }
                }
            });
        },

        createParagraph: function(definition, extraParams, noEvent, loadAnnotations, ignoreTemplate, preventUndo) {
            var rt = definition.resourceType;
            var component = CQ.HTTP.eval(definition.path + ".json");
            definition.virtual = true;
            definition.virtualResourceType = rt; // allow insertion even if cqmappings isn't explicitly allowed
            if (!extraParams)
                extraParams = {};
            extraParams[":name"] = rt.replace(/\//g, '_');
            extraParams["./cq:componentPath"] = definition.path;
            extraParams["./cq:componentName"] = definition.title;
            extraParams["./cq:componentIcon"] = definition.icon;
            extraParams["./jcr:primaryType"] = "cq:Component";
            var mappingComponent = component["cq:mappingComponent"] || "cq";
            definition.resourceType = "aem-ga/components/content/gamapping";
            if (null == this._createParagraph(definition, extraParams, noEvent, loadAnnotations, ignoreTemplate, preventUndo)) {
                CQ.Notification.notify(null, 'Could not insert component (twice?)', 8, true);
            }
        },
        
        buildElement: function() {
            this.emptyText = CQ.I18n.getMessage("Drag components here to include them in the analytics framework");
            return this._buildElement();
        }
    });

    CQ.wcm.EditBase.showDialog = function(editComponent, type) {
        if (!editComponent) {
            return;
        }
        var dialog;
        var showInsidePanel;
        if (type && type == CQ.wcm.EditBase.INSERT) {
            dialog = editComponent.getInsertDialog();
            dialog.processPath(editComponent.path);
        } else {
            if (editComponent.fireEvent(CQ.wcm.EditBase.EVENT_BEFORE_EDIT, editComponent) === false) {
                return;
            }
            dialog = editComponent.getEditDialog();
            dialog.loadContent(editComponent.path);
            if (dialog.items.getCount() >= 1) {
                var dialogItems = dialog.items.first();
                if (dialogItems.items.getCount() <= 0)
                    return;
            }
            showInsidePanel = dialog.showInsidePanel;

            if (editComponent.enableLiveRelationship) {
                var fct = function() {
                    editComponent.switchLock(dialog);
                };

                dialog.on("beforeeditlocked", fct);
                dialog.on("beforeeditunlocked", fct);

                dialog.on("beforeshow", function() {
                    dialog.editLock = this.liveStatusLocked;
                }, editComponent);
            }

            if (dialog.hidden && editComponent.element && editComponent.element.getWidth() > editComponent.getInlineConfig().size && !CQ.wcm.EditBase.isInlineDialogChildOpened(editComponent.path)) {
                var inlinePlaceholder = editComponent.getInlinePlaceholder();
                if (inlinePlaceholder) {
                    var inlinePlaceholderIntialHeight = editComponent.getInlinePlaceholderInitialHeight();

                    dialog.setWidth(inlinePlaceholder.getWidth());
                    dialog.anchorTo(inlinePlaceholder, "tl", [0, inlinePlaceholderIntialHeight], true);

                    dialog.on("resize", editComponent.resizeDialogListener, editComponent);
                    dialog.on("hide", editComponent.hideDialogListener, editComponent);

                    dialog.anchoredTo = editComponent;
                    CQ.Util.observeComponent(dialog);

                    inlinePlaceholder.setHeight(dialog.getFrameHeight() + dialog.getInnerHeight() + inlinePlaceholder.getHeight() + CQ.themes.wcm.EditBase.INLINE_BOTTOM_PADDING);

                    if (editComponent.disableDrag) {
                        editComponent.disableDrag();
                    }

                    CQ.wcm.EditBase.registerInlineDialog(dialog);

                    dialog.disableOverridePosition = true;
                }
            }
    
        }
        if (!showInsidePanel) {
            CQ.WCM.deselect(); // clear current selection
        }
        dialog.show();

        if (!showInsidePanel) {
            editComponent.suspendDropTargets();
            dialog.on("hide", editComponent.hideDialogListenerToResumeDropTargets, editComponent);
        }
    };

    provider.setValue("numMappingStoresLoaded", 0);
    var mappingSet = {
        grids: { },
        panels: { }
    };
</script>
<cq:include path="mappings" resourceType="cq/analytics/components/mappings/maparsys"/>
<script type="text/javascript">
    CQ.Ext.onReady(function() {
        var anyInherited = false;
        var panels = mappingSet.panels;
        for (var idx in panels) {
            var cqPanel = panels[idx];
            if (cqPanel.inherited && cqPanel.isVisible()) {
                anyInherited = true;
                break;
            }
        }
        if (!anyInherited) {
            var cqInherited = $CQ("#cq-inherited-frameworks");
            cqInherited.hide();
            cqInherited.children().hide();
        }
        var totalMappings = 0;
        if (mappingSet) {
            for (var idx in mappingSet.grids)
                totalMappings++;
        }
        provider.onAvailable("numMappingStoresLoaded", function(value) {
            // Run conflict detection only after all components have been loaded
            if (value == totalMappings)
                conflictManager.loadAllConflicts();
        });
    });
</script>

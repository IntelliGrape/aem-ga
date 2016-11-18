{
    "tabTip": CQ.I18n.getMessage("GA Variables"),
    "id": "cfTab-gaAllVars",
    "iconCls": "cq-cft-tab-icon products",
    "xtype": "contentfindertab",
    "ranking": 99,
    "allowedPaths": [
       "/etc/cloudservices/googleanalytics/.*",
        "/etc/cloudservices/tagmanager/.*"
    ],
    "items": [
        CQ.wcm.ContentFinderTab.getQueryBoxConfig({
            "id": "cfTab-GAVariables-QueryBox",
            "items": [
                CQ.wcm.ContentFinderTab.getSuggestFieldConfig({
                    "minTermLength": 1000, /*disable search*/
                    "url": CQ.shared.HTTP.externalize("/libs/cq/analytics/googleanalytics/variables.json"),
                    "search": function() {
                        var tab = this.findParentByType("contentfindertab");
                        var query = tab.getQueryValue();
                        tab.dataView.store.filterBy(function(rec){
                            if(query && query.length > 0) {
                                var regex = new RegExp('.*?'+query+'.*?','i');
                                var matchesTitle = (rec.get('idName').match(regex));
                                var matchesName = (rec.get('name').match(regex));
                                return (matchesTitle || matchesName); 
                            }
                            return true;
                        });
                    }                                     
                })
            ]
        }),
        CQ.wcm.ContentFinderTab.getResultsBoxConfig({
            "itemsDDGroups": ["googleanalyticsVars"],
			"itemsDDNewParagraph": {
                "path": "cq/analytics/components/ga",
                "propertyName": "./variable"
            },
            "disableContinuousLoading": true,
            "items": {
                    "cls": "cq-cft-dataview cq-cft-sitecatalystvars-view",
                    "loadingText": CQ.I18n.getMessage("Loading variables..."),
                    "emptyText": CQ.I18n.getMessage("No GA variables found."),
                    "tpl": new CQ.Ext.XTemplate(
                        '<tpl for=".">'
                        	+'<div class="cq-cft-search-item">'
                            + '<div class="cq-cft-sitecatalystvars-item cq-cft-sitecatalystvars-ddproxy-wrapper">'
                                + '<div class="cq-cft-sitecatalystvars-title">{[values.name]}'
                                + '<div class="cq-cft-sitecatalystvars-description">{values.idName}</div></div>'
                                + '<div class="cq-cft-participant-separator"></div></div>'
                            + '</div>'
                        + '</tpl>'),
                    "itemSelector":  CQ.wcm.ContentFinderTab.DETAILS_ITEMSELECTOR
                },
            "tbar": [ CQ.wcm.ContentFinderTab.REFRESH_BUTTON ]
        },{
            "url": CQ.shared.HTTP.externalize("/bin/getDimensions")
        },{
            "reader": new CQ.Ext.data.JsonReader({
                "totalProperty": "results",
                "root": "all",
                "fields": [{name: 'idName', mapping: 'id'}, "name"],
                "id": "id"
            }),
            "baseParams": {
				"resourcePath": CQ.HTTP.getPath(CQ.HTTP.getAnchor(CQ.WCM.getContentUrl())),
                "dimensionType":'all',
            }
        })
    ]

}
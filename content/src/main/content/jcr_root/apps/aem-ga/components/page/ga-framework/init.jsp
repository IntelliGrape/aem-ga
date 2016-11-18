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

  Init script.

  Draws the WCM initialization code. This is usually called by the head.jsp
  of the page. If the WCM is disabled, no output is written.

  ==============================================================================

--%><%@page session="false" 
		    import="javax.jcr.Node,
		    		org.apache.sling.api.resource.Resource,

                    com.day.cq.wcm.api.WCMMode" %><%
%><%@taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><cq:defineObjects/><%
if (WCMMode.fromRequest(request) != WCMMode.DISABLED) {
    %><cq:includeClientLib categories="cq.analytics,cq.tagging,cq.personalization"/><%

    String dlgPath = null;
    if (editContext != null && editContext.getComponent() != null) {
        dlgPath = editContext.getComponent().getDialogPath();
    }
    %>
    <script type="text/javascript" >
        var topWindow = CQ.WCM.getTopWindow();
        var Sidekick = topWindow.CQ.wcm.Sidekick;
        if (Sidekick && !topWindow.CQ_Sidekick) {
            Sidekick.prototype._addButtons = Sidekick.prototype.addButtons;
            CQ.Ext.override(Sidekick, {
                addButtons: function() {
                    this._addButtons.apply(this, arguments);
                    var bbar = this.getBottomToolbar();
                    bbar.remove(this.previewButton, true);
                    bbar.remove(this.scaffoldingButton, true);
                }
            });
        } else if (Sidekick) {
            // If topWindow.CQ_Sidekick already exists we need to overwrite addButtons again
            // because IE (including IE9) would throw an error if a javascript function is 
            // called that has been defined in an iframe that does not exist anymore.
            // ("SCRIPT5011: Can't execute code from a freed script")
            topWindow.CQ_Sidekick.addButtons = function() {
                    Sidekick.prototype._addButtons.apply(this, arguments);
                    var bbar = this.getBottomToolbar();
                    bbar.remove(this.previewButton, true);
                    bbar.remove(this.scaffoldingButton, true);
                };
        }
        
        var launchSidekick = function() {
            CQ.WCM.launchSidekick("<%= xssAPI.encodeForJSString(currentPage.getPath()) %>", {
                propsText: CQ.I18n.getMessage("Framework Properties..."),
                createChildPageText: CQ.I18n.getMessage("Create Child Framework"),
                copyPageText: CQ.I18n.getMessage("Copy Framework"),
                movePageText: CQ.I18n.getMessage("Move Framework"),
                deleteText: CQ.I18n.getMessage("Delete Framework"),
                publishText: CQ.I18n.getMessage("Activate Framework"),
                lockText: CQ.I18n.getMessage("Lock Framework"),
                rolloutText: CQ.I18n.getMessage("Rollout Framework"),
                propsDialog: "<%= dlgPath == null ? "" : xssAPI.encodeForJSString(dlgPath) %>",
                locked: <%= currentPage.isLocked() %>
            });
        };

        launchSidekick();

    </script><%
}
%>

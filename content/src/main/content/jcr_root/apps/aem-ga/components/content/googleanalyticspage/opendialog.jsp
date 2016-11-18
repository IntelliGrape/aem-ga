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



--%>
<%--
    Open configuration dialog if the property designated by "connectedWhen" is filled in.
    Derived components may override this to change the opening condition.
    --%>
<%@include file="/libs/foundation/global.jsp"%>
<%@include
	file="/libs/cq/cloudserviceconfigs/components/configpage/init.jsp"%>
<%@ page import="com.tothenew.ga.service.GADimensionsListService,com.tothenew.ga.service.UserResourceResolverService"%>
<%
	GADimensionsListService gaDimensionsListService = sling.getService(GADimensionsListService.class);
      UserResourceResolverService userResourceResolverService = sling.getService(UserResourceResolverService.class);
%>
<script type="text/javascript">
	<%if (properties.get("trackingCode") == null) {%>
	        CQ.WCM.onEditableReady("<%=resource.getPath()%>", function(editable){
	            CQ.wcm.EditBase.showDialog(editable);
	        }, this);
	<%} else if (!gaDimensionsListService.verifyAccountDetail(resource.getPath(), userResourceResolverService.getUserResourceResolver())) {%>
	            CQ.Ext.Msg.show({
					title:'Save configuration ?',
	                msg: 'Configuration you have provided does not seems correct. Would you like to save the same ?',
	                buttons: CQ.Ext.Msg.YESNO,
	                fn: function (btn) {
	                    if (btn == 'no') {
	                        CQ.wcm.EditBase.showDialog(CQ.WCM.getEditable("<%=resource.getPath()%>"));
						}
					},
					icon : CQ.Ext.Msg.QUESTION
				});
	<%} else {%>
		$CQ(".when-config-successful").show();
	<%}%>
</script>

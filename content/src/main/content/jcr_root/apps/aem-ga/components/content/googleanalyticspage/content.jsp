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



--%>
<%@include file="/libs/foundation/global.jsp"%>
<%@page session="false"
      contentType="text/html"
      pageEncoding="utf-8"
      import="com.day.cq.i18n.I18n"%><%
%><%@taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><cq:defineObjects/>
<%@include file="/libs/cq/cloudserviceconfigs/components/configpage/init.jsp"%>
<cq:includeClientLib categories="cq.analytics,cq.personalization" />
<% 
	I18n i18n = new I18n(request);
	String resPath = resource.getPath().replace("/jcr:content", "");
	String createLink = "<a href=\"javascript: CQ.cloudservices.editNewConfiguration('"+ resPath + "','"+ resPath +"', false, '"+ i18n.get("Create Framework") +"')\">" +
						i18n.get("create") + "</a>";
%>
<div>
    <h3><%= i18n.get("Google Analytics Settings") %></h3>
    <img src="<%= xssAPI.encodeForHTMLAttr(thumbnailPath) %>" alt="<%= xssAPI.encodeForHTMLAttr(serviceName) %>" style="float: left;" />
    <ul style="float: left; margin: 0px;">
        <li><div class="li-bullet"><strong><%= i18n.get("account ID") %>: </strong><%= xssAPI.encodeForHTML(properties.get("accountID", "")) %></div></li>
        <li><div class="li-bullet"><strong><%= i18n.get("Application") %>: </strong><%= xssAPI.encodeForHTML(properties.get("applicationName", "")) %></div></li>
        <li><div class="li-bullet"><strong><%= i18n.get("Keystore Type") %>: </strong><%= xssAPI.encodeForHTML(properties.get("keystoreType", "")) %></div></li>
        <li><div class="li-bullet"><strong><%= i18n.get("Key Provider") %>: </strong><%= xssAPI.encodeForHTML(properties.get("keyProvider", "")) %></div></li>
        <li><div class="li-bullet"><strong><%= i18n.get("Tracking Code") %>: </strong><%= xssAPI.encodeForHTML(properties.get("trackingCode", "")) %></div></li>
        <li><div class="li-bullet"><strong><%= i18n.get("Password") %>: </strong><%= xssAPI.encodeForHTML(properties.get("password", "").replaceAll(".", "*")) %></div></li>
        <li><div class="li-bullet"><strong><%= i18n.get("Key Alias Name") %>: </strong><%= xssAPI.encodeForHTML(properties.get("keyAliasName", "")) %></div></li>
        <li><div class="li-bullet"><strong><%= i18n.get("Service Account Email") %>: </strong><%= xssAPI.encodeForHTML(properties.get("serviceAccountEmail", "")) %></div></li>
        <li class="config-successful-message when-config-successful" style="display: none">
        	<%= i18n.get("Google Analytics configuration is successful.<br> Please {0} or edit an analytics framework, and apply it to your <a href='/siteadmin'>website</a>.","Analytics successful configuration HTML message", createLink) %>
        </li>
    </ul>
    <div class="when-config-successful" style="display: none">
        <h2 style="border: none; margin-top: 10px; padding-left:0px;"><%= i18n.get("Available Frameworks") %>
        [<a href="javascript: CQ.cloudservices.editNewConfiguration('<%= xssAPI.encodeForJSString(resPath) %>','<%= xssAPI.encodeForJSString(resPath) %>', false, '<%= i18n.get("Create Framework") %>')" 
            style="color: #336600;" title="<%= i18n.get("Create Framework") %>"><b>+</b></a>]
        </h2>
        <%= printChildren(i18n, currentPage, request) %>
    </div>
</div>
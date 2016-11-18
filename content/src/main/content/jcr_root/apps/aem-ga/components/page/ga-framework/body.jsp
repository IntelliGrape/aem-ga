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
                    java.util.Iterator,
                    com.day.cq.wcm.webservicesupport.Configuration,
                    org.apache.sling.api.resource.Resource"%><%
%><%@taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><cq:defineObjects/><%

    String id = currentPage.getName();
    String title = properties.get("jcr:title", id); 
    String description = properties.get("jcr:description", "");
          
%><body>
    <p class="cq-clear-for-ie7"></p>
    <h1><%= xssAPI.encodeForHTML(title) %></h1>
    <p><%= xssAPI.encodeForHTML(description) %></p>
    <cq:include script="content.jsp" />
    <p>&nbsp;</p>
</body>

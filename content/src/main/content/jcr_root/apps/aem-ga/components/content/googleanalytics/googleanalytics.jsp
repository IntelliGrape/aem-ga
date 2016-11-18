<%@include file="/libs/foundation/global.jsp"%>
<%@ page
        import="org.apache.sling.api.resource.ValueMap,
				com.day.cq.commons.inherit.HierarchyNodeInheritanceValueMap,
				com.day.cq.commons.inherit.InheritanceValueMap"%>
<cq:includeClientLib categories="apps.aem-ga.framework" />
<%
    String[] cloudConfig = pageProperties.getInherited("cq:cloudserviceconfigs", String[].class);
    String webPropertyId = null;
    String mappingPath = "";
    if (cloudConfig != null) {
        for (String path : cloudConfig) {
            if (path.startsWith("/etc/cloudservices/googleanalytics")) {
                mappingPath = path;
                Resource mappingPageResource = resourceResolver.getResource(path);
                InheritanceValueMap parentPageProperties = new HierarchyNodeInheritanceValueMap(
                        mappingPageResource);
                webPropertyId = parentPageProperties.getInherited("trackingCode", String.class);
            }
        }
    }
%>
<script>
    var webPropertyId = '<%=webPropertyId%>';
    if('null' != webPropertyId){
        gaHandler.gaScript(webPropertyId);
        gaHandler.mappingPath = "<%=mappingPath%>";
    } else {
        console.error('Please apply google analytics cloud service configuration on root page');
    }
</script>

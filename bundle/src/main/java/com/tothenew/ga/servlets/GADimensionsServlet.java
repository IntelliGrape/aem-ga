/*
 * 
 */
package com.tothenew.ga.servlets;

import java.io.IOException;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Properties;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.http.HttpStatus;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.servlets.SlingSafeMethodsServlet;

import com.google.api.services.analytics.Analytics;
import com.google.gson.Gson;
import com.tothenew.ga.service.GADimensionsListService;

@Component(immediate = true, metatype = true, label = "GA Dimension Servlet", name = "com.tothenew.ga.GADimensionServlet", description = "Get dimensions of GA")
@Service
@Properties({
		@Property(name = "service.description", value = "Return dimensions and events of GA"),
		@Property(name = "sling.servlet.paths", value = "/bin/getDimensions"),
		@Property(name = "sling.servlet.methods", value = "GET") })
public class GADimensionsServlet extends SlingSafeMethodsServlet {

	private static final long serialVersionUID = 1L;
	@Reference
	GADimensionsListService gaDimensionsList;

	@Override
	protected void doGet(final SlingHttpServletRequest request,
			final SlingHttpServletResponse response) throws ServletException,
			IOException {

		response.setContentType("application/json");
		response.setCharacterEncoding("utf-8");
		final String resourcePath = URLDecoder.decode(
				request.getParameter("resourcePath"), "UTF-8");
		final Analytics analytics = gaDimensionsList
				.getInitializedAnalytics(resourcePath,request.getResourceResolver());
		if (analytics != null) {
			final String dimensionType = request.getParameter("dimensionType");
			String json = "";
			List<Map<String, String>> dimensionList = null;
			final Map<String, List<Map<String, String>>> dimensionsMap = new HashMap<String, List<Map<String, String>>>();
			if ("predefined".equals(dimensionType)) {
				dimensionList = gaDimensionsList
						.getPredefinedDimensionList(analytics);
				dimensionList.addAll(gaDimensionsList.gethitType());
				dimensionsMap.put("predefined", dimensionList);
			} else if ("custom".equals(dimensionType)) {
				dimensionList = gaDimensionsList.getCustomDimensionList(analytics);
				dimensionList.addAll(gaDimensionsList.gethitType());
				dimensionsMap.put("custom",dimensionList);
			} else {
				dimensionList = gaDimensionsList.getAllDimensions(analytics);
				dimensionList.addAll(gaDimensionsList.gethitType());
				dimensionsMap.put("all",dimensionList);
			}
			json = new Gson().toJson(dimensionsMap);
			response.getWriter().write(json);
		} else {
			response.sendError(HttpStatus.SC_BAD_REQUEST, "bad configuration");
		}

	}
}

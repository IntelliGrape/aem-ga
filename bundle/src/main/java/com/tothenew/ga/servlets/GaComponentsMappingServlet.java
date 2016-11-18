/*
 * 
 */
package com.tothenew.ga.servlets;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.sling.SlingServlet;
import org.apache.http.HttpStatus;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.servlets.SlingSafeMethodsServlet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.gson.Gson;
import com.tothenew.ga.service.ComponentMappingService;

/**
 * Servlet to return a list of all the components containing the 'analytics'
 * node under them.
 *
 */
@SlingServlet(label = "GaComponentsServlet", description = "GaComponentsServlet", paths = "/bin/servlets/GAComponents", methods = "GET", metatype = true)
public class GaComponentsMappingServlet extends SlingSafeMethodsServlet {

	
	private static final long serialVersionUID = 1L;
	private final Logger logger = LoggerFactory.getLogger(GaComponentsMappingServlet.class);
	
	@Reference
	ComponentMappingService componentMappingService;

	@Override
	public void doGet(final SlingHttpServletRequest request, final SlingHttpServletResponse response) {

		final String resourcePath = request.getParameter("resourcePath");
		final String componentPath = request.getParameter("componentPath");
		final ResourceResolver resourceResolver = request.getResourceResolver();
		if (resourcePath == null || componentPath == null) {
			sendError(response, HttpStatus.SC_BAD_REQUEST, "Missing Path Parameter");
		}else{
			List<Map<String, Object>> mappingList = componentMappingService.getComponentsMappingList(resourcePath,
					componentPath, resourceResolver);
			writeResultingListToResponseAsJson(response, mappingList);
		}

	}

	private void sendError(final SlingHttpServletResponse response, final int statusCode, final String message) {
		try {
			response.sendError(statusCode, message);
		} catch (final IOException ioExp) {
			logger.error(ioExp.getMessage(), ioExp);
		}
	}

	private void writeResultingListToResponseAsJson(final SlingHttpServletResponse response, final List<Map<String, Object>> mappingList) {
		final String json = new Gson().toJson(mappingList);
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		try {
			response.getWriter().write(json);
		} catch (final IOException ioExp) {
			logger.error(ioExp.getMessage(), ioExp);
		}
	}
}

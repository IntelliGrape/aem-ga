package com.tothenew.ga.servlets;

import java.io.IOException;

import javax.servlet.ServletException;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Properties;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.http.HttpStatus;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.resource.ValueMap;
import org.apache.sling.api.servlets.SlingSafeMethodsServlet;

import com.google.gson.Gson;
import com.tothenew.ga.service.ComponentMappingService;

@Component(immediate = true, metatype = true, label = "Mapping node Servlet", name = "com.tothenew.ga.MappingNodeServlet", description = "Get valueMap of mapping noed")
@Service
@Properties({ @Property(name = "service.description", value = "Return all properties of mapping node"),
		@Property(name = "sling.servlet.paths", value = "/bin/getMappedNode"),
		@Property(name = "sling.servlet.methods", value = "GET") })
public class MappingNodeServlet extends SlingSafeMethodsServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Reference
	ComponentMappingService componentMappingService;

	@Override
	protected void doGet(SlingHttpServletRequest request, SlingHttpServletResponse response)
			throws ServletException, IOException {
		response.setContentType("application/json");
		response.setCharacterEncoding("utf-8");
		String mappingNodePath = request.getParameter("mappingNodePath");
		ValueMap map = componentMappingService.getMappingNode(mappingNodePath);
		if (map != null) {
			String json = new Gson().toJson(map);
			response.getWriter().write(json);
		} else {
			response.sendError(HttpStatus.SC_BAD_REQUEST, "No mapping node at given path");
		}

	}

}

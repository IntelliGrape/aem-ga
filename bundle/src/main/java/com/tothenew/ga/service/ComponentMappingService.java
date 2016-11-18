package com.tothenew.ga.service;

import java.util.List;
import java.util.Map;

import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ValueMap;

public interface ComponentMappingService {
	public List<Map<String, Object>> getComponentsMappingList(String resourcePath, String componentPath,
			ResourceResolver resourceResolver);

	ValueMap getMappingNode(String mappingNodePath);
}

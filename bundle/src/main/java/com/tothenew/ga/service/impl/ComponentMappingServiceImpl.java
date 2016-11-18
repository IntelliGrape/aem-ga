package com.tothenew.ga.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Objects;
import java.util.Set;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.api.resource.LoginException;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ValueMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.tothenew.ga.constant.Constant;
import com.tothenew.ga.service.ComponentMappingService;
import com.tothenew.ga.service.UserResourceResolverService;

@Component(immediate = true, metatype = true, label = "Get mapping of cq variables with GA dimensions", enabled = true, name = "ComponentMappingService")
@Service(value = ComponentMappingService.class)
public class ComponentMappingServiceImpl implements ComponentMappingService {

	@Reference
	UserResourceResolverService userResourceResolverService;

	private final Logger LOGGER = LoggerFactory.getLogger(this.getClass());

	@Property(name = Constant.PROP_KEY_GA_NODE_NAME, label = Constant.PROP_LABEL_GA_NODE_NAME)
	private String CONS_PROP_VAL = "analytics";

	public List<Map<String, Object>> getComponentsMappingList(String resourcePath, String componentPath,
			ResourceResolver resourceResolver) {

		ArrayList<Map<String, Object>> mappingList = new ArrayList<Map<String, Object>>();
		ValueMap resourceValueMap;
		Map<String, Object> map;
		ValueMap componentValueMap;
		Resource componentResource = resourceResolver.getResource(componentPath + "/" + CONS_PROP_VAL);
		Resource mappingResource = resourceResolver.getResource(resourcePath);
		if (componentResource != null && mappingResource != null) {
			componentValueMap = componentResource.adaptTo(ValueMap.class);
			resourceValueMap = mappingResource.adaptTo(ValueMap.class);
			String[] trackVars = componentValueMap.get(Constant.PROP_CQ_ANALYTICS_VAR, String[].class);
			String[] trackEvents = componentValueMap.get(Constant.PROP_CQ_ANALYTICS_EVENT, String[].class);
			Set<Entry<String, Object>> mappingEntrySet = resourceValueMap.entrySet();
			for (String trackVar : trackVars) {
				map = new HashMap<String, Object>();
				map.put("cqVar", trackVar);
				Set<String> keys = new HashSet<String>();
				for (Entry<String, Object> entry : mappingEntrySet) {
					if (Objects.equals(trackVar, entry.getValue())) {
						keys.add(entry.getKey());
					}
				}
				map.put("gaVar", keys);
				mappingList.add(map);
			}
			for (String trackEvent : trackEvents) {
				map = new HashMap<String, Object>();
				map.put("cqVar", trackEvent);
				Set<String> keys = new HashSet<String>();
				for (Entry<String, Object> entry : mappingEntrySet) {
					if (Objects.equals(trackEvent, entry.getValue())) {
						keys.add(entry.getKey());
					}
				}
				map.put("gaVar", keys);
				mappingList.add(map);
			}
		}
		return mappingList;
	}

	public ValueMap getMappingNode(String mappingNodePath) {
		try {
			ResourceResolver resolver = userResourceResolverService.getUserResourceResolver();
			Resource mappingNode = resolver.resolve(mappingNodePath);
			return mappingNode.adaptTo(ValueMap.class);
		} catch (LoginException e) {
			LOGGER.error("error in getting admin resource resolver", e);
		}
		return null;
	}

}

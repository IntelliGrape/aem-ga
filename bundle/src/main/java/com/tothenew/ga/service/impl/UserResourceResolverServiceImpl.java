/*
 * 
 */
package com.tothenew.ga.service.impl;

import java.util.Dictionary;
import java.util.HashMap;
import java.util.Map;

import org.apache.felix.scr.annotations.Activate;
import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.api.resource.LoginException;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ResourceResolverFactory;
import org.osgi.service.component.ComponentContext;

import com.tothenew.ga.service.UserResourceResolverService;

@Component(immediate = true, metatype = true, label = "Get user specific resource resolver", enabled = true, name = "UserResourceResolverImpl")
@Service(value = UserResourceResolverService.class)
@Property(name = "USER_MAPPER", value = "readService", description = "user who has read permission")
public class UserResourceResolverServiceImpl implements UserResourceResolverService {
	private String userMapper = "readService";

	@Reference
	private ResourceResolverFactory resourceResolverFactory;

	@Activate
	private void activate(final ComponentContext componentContext) {
		final Dictionary<?, ?> properties = componentContext.getProperties();
		userMapper = (String) properties.get("USER_MAPPER");
	}

	/**
	 * 
	 * @return {ResourceResolver}
	 * @throws LoginException
	 */
	public ResourceResolver getUserResourceResolver() throws LoginException {
		final Map<String, Object> param = new HashMap<String, Object>();
		param.put(ResourceResolverFactory.SUBSERVICE, userMapper);
		return resourceResolverFactory.getServiceResourceResolver(param);
	}
}

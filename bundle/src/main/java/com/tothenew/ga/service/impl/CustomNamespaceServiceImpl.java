package com.tothenew.ga.service.impl;

import javax.jcr.NamespaceRegistry;
import javax.jcr.RepositoryException;
import javax.jcr.Session;

import org.apache.felix.scr.annotations.Activate;
import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.api.resource.LoginException;
import org.apache.sling.api.resource.ResourceResolver;
import org.osgi.service.component.ComponentContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.tothenew.ga.service.CustomNamespaceService;
import com.tothenew.ga.service.UserResourceResolverService;

@Component(immediate = true, metatype = true, label = "create custom name spacce in crx", enabled = true, name = "CreateCustomNamespace")
@Service(value = CustomNamespaceService.class)
public class CustomNamespaceServiceImpl implements CustomNamespaceService {

	@Reference
	UserResourceResolverService userResourceResolverService;

	private ResourceResolver resourceResolver;
	private final Logger LOGGER = LoggerFactory.getLogger(this.getClass());

	@Activate
	protected void activate(ComponentContext componentContext) {
		createCustomNamespace("ga", "ga");
	}

	public void createCustomNamespace(String uri, String namespace) {

		try {
			resourceResolver = userResourceResolverService.getUserResourceResolver();
			Session session = resourceResolver.adaptTo(Session.class);
			NamespaceRegistry ns = session.getWorkspace()
					.getNamespaceRegistry();
			ns.registerNamespace(namespace, uri);
			session.save();
			resourceResolver.close();
		} catch (LoginException le) {
			LOGGER.error("Unable to get admin user", le);
		} catch (RepositoryException re) {
			LOGGER.error("Unable to create namespace", re);
		} 

	}

}

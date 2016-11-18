/*
 * 
 */
package com.tothenew.ga.service;

import org.apache.sling.api.resource.LoginException;
import org.apache.sling.api.resource.ResourceResolver;

public interface UserResourceResolverService {
	ResourceResolver getUserResourceResolver() throws LoginException;
}

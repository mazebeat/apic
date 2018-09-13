/**
 * My RESTFul Event Handler
 */
component extends="Base"{
	
	any function index(event, rc, prc) {
		/* 
			-- Quantity group by IP Address
			SELECT SQL_NO_CACHE
			COUNT(id) AS qTotal, 
			SUM(user_request_count) AS qRequest, 
			ip_address, last_attempt, last_event, http_user_agent
			FROM sige.apic_currentUser
			WHERE ip_address = '176.87.56.40'
			GROUP BY ip_address
			ORDER BY last_attempt DESC
		*/

		/* 
			-- Quantity group by month
			SELECT SQL_NO_CACHE
			COUNT(id) AS qTotal, 
			SUM(user_request_count) AS qRequest, 
			ip_address, last_attempt, last_event, http_user_agent
			FROM sige.apic_currentUser
			WHERE ip_address = '176.87.56.40'
			GROUP BY MONTH(last_attempt), ip_address, last_event
			ORDER BY last_attempt DESC
		*/

		/* 
			-- Quantity group by user_agent
			SELECT SQL_NO_CACHE
			COUNT(id) AS qTotal, 
			SUM(user_request_count) AS qRequest, 
			ip_address, last_attempt, last_event, http_user_agent
			FROM sige.apic_currentUser
			WHERE ip_address = '176.87.56.40'
			GROUP BY http_user_agent
			ORDER BY last_attempt DESC
		*/

		/* 
			-- Total of rows without token 
			SELECT SQL_NO_CACHE
			COUNT(id) AS qTotal,
			last_attempt, 
			last_event, 
			http_user_agent
			FROM sige.apic_currentUser
			WHERE token IS NULL
			GROUP BY MONTH(created_at), ip_address
			ORDER BY last_attempt DESC			

		*/
		prc.response.addMessage(getResource(resource='welcome'));
	}
}
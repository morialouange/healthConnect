package com.burundihealthconnect.filter;

import com.burundihealthconnect.util.SessionKeys;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Locale;

/**
 * LocaleFilter — @WebFilter("/*")
 * Détecte la langue via le paramètre "lang" dans la requête ou via la session,
 * puis configure le Locale pour les ressources JSTL fmt:message.
 */
@WebFilter("/*")
public class LocaleFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(true);
        String lang = request.getParameter("lang");

        if (lang != null && (lang.equals("fr") || lang.equals("en"))) {
            session.setAttribute(SessionKeys.LANGUE, lang);
        } else if (session.getAttribute(SessionKeys.LANGUE) == null) {
            Locale locale = request.getLocale();
            String browserLang = locale.getLanguage();
            session.setAttribute(SessionKeys.LANGUE, browserLang.equals("en") ? "en" : "fr");
        }

        String sessionLang = (String) session.getAttribute(SessionKeys.LANGUE);
        if (sessionLang != null) {
            request.setAttribute("jakarta.servlet.jsp.jstl.fmt.locale", sessionLang);
            request.setAttribute("jakarta.servlet.jsp.jstl.fmt.fallbackLocale", "fr");
        }

        chain.doFilter(req, res);
    }
}

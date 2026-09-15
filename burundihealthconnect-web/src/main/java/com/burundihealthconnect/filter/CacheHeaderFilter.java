package com.burundihealthconnect.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * CacheHeaderFilter — @WebFilter("/*")
 * Interdit la mise en cache navigateur des PAGES HTML afin que chaque rechargement
 * récupère la dernière version servie (la CSS/JS versionnée gardent, elles, un cache normal).
 * Sans ces en-têtes, le navigateur pouvait réafficher une ancienne page HTML — donc
 * d'anciens liens vers la CSS — et l'utilisateur voyait toujours l'ancien design.
 */
@WebFilter("/*")
public class CacheHeaderFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String chemin = uri.substring(contextPath.length());

        if (!estRessourceStatique(chemin)) {
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
        }

        chain.doFilter(req, res);
    }

    /** Ressources immuables versionnées (?v=) : on les laisse "cacheable" sans restriction. */
    private boolean estRessourceStatique(String chemin) {
        return chemin.startsWith("/resources/") || chemin.startsWith("/css/")
                || chemin.startsWith("/js/") || chemin.startsWith("/images/")
                || chemin.startsWith("/img/") || chemin.equals("/favicon.ico")
                || chemin.equals("/WEB-INF/");
    }
}
package com.hknp;

import org.eclipse.jetty.annotations.AnnotationConfiguration;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.DefaultServlet;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.util.resource.Resource;
import org.eclipse.jetty.webapp.Configuration;
import org.eclipse.jetty.webapp.WebAppContext;

import java.io.File;
import java.net.URL;
import java.nio.file.Files;

public class EmbeddedJetty {
    public static void main(String[] args) throws Exception {
        int port = getPort();
        Server server = new Server(port);

        WebAppContext webapp = new WebAppContext();
        webapp.setContextPath("/");
        webapp.setParentLoaderPriority(true);

        // Include annotation scanning so @WebServlet, etc. are detected
        Configuration.ClassList classlist = Configuration.ClassList.setServerDefault(server);
        classlist.addBefore("org.eclipse.jetty.webapp.JettyWebXmlConfiguration", AnnotationConfiguration.class.getName());

        // Point to webapp/ shipped inside the shaded JAR (configured via pom resources)
        URL webappUrl = EmbeddedJetty.class.getClassLoader().getResource("webapp");
        if (webappUrl == null) {
            throw new IllegalStateException("Could not find 'webapp' resources on classpath. Ensure build copied src/main/webapp to resources.");
        }
        webapp.setBaseResource(Resource.newResource(webappUrl));

        // Temp dir for JSP compilation
        File tmpDir = Files.createTempDirectory("jetty-jsp").toFile();
        tmpDir.deleteOnExit();
        webapp.setAttribute("javax.servlet.context.tempdir", tmpDir);

        // Enable JSP via Jetty's JSP servlet
        ServletHolder jsp = new ServletHolder("jsp", org.eclipse.jetty.apache.jsp.JettyJspServlet.class);
        jsp.setInitOrder(0);
        jsp.setInitParameter("logVerbosityLevel", "INFO");
        jsp.setInitParameter("fork", "false");
        jsp.setInitParameter("xpoweredBy", "false");
        jsp.setInitParameter("compilerTargetVM", "1.8");
        jsp.setInitParameter("compilerSourceVM", "1.8");
        jsp.setInitParameter("keepgenerated", "false");
        webapp.addServlet(jsp, "*.jsp");

        // Default servlet for static content
        ServletHolder defaultServlet = new ServletHolder("default", new DefaultServlet());
        defaultServlet.setInitParameter("dirAllowed", "false");
        webapp.addServlet(defaultServlet, "/");

        // Help scanning of taglibs / jsp jars
        webapp.setAttribute(
                "org.eclipse.jetty.server.webapp.ContainerIncludeJarPattern",
                ".*/[^/]*taglibs.*\\.jar$|.*/[^/]*javax\\.servlet.*\\.jar$|.*/.*jsp.*\\.jar$|.*/.*jstl.*\\.jar$"
        );

        server.setHandler(webapp);
        server.start();
        System.out.println("[eCommerceWebsite] Embedded Jetty started on http://localhost:" + port);
        server.join();
    }

    private static int getPort() {
        String env = System.getenv("PORT");
        if (env != null) {
            try { return Integer.parseInt(env.trim()); } catch (NumberFormatException ignored) {}
        }
        String prop = System.getProperty("port");
        if (prop != null) {
            try { return Integer.parseInt(prop.trim()); } catch (NumberFormatException ignored) {}
        }
        return 8080;
    }
}

